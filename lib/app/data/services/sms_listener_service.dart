import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readsms/readsms.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sms_message.dart';
import '../models/fraud_result.dart';
import 'fraud_detection_service.dart';

class SmsListenerService extends GetxService {
  final Readsms _plugin = Readsms();
  final FraudDetectionService _fraudService = Get.find<FraudDetectionService>();

  StreamSubscription<SMS>? _smsSubscription;
  final RxBool isListening = false.obs;
  final RxList<SmsMessage> incomingMessages = <SmsMessage>[].obs;
  final RxList<FraudResult> backgroundResults = <FraudResult>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSmsListener();
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }

  /// Initialize SMS listener
  Future<void> _initializeSmsListener() async {
    try {
      // Check permissions
      final hasPermission = await _checkSmsPermissions();
      if (!hasPermission) {
        print('📱 SMS permissions not granted, cannot start listener');
        return;
      }

      print('📱 SMS Listener Service initialized');
    } catch (e) {
      print('❌ Error initializing SMS listener: $e');
    }
  }

  /// Check and request SMS permissions
  Future<bool> _checkSmsPermissions() async {
    final status = await Permission.sms.status;
    if (status.isGranted) {
      return true;
    }

    // Request permission if not granted
    final result = await Permission.sms.request();
    return result.isGranted;
  }

  /// Start listening for incoming SMS messages
  Future<bool> startListening() async {
    try {
      if (isListening.value) {
        print('📱 SMS listener already running');
        return true;
      }

      final hasPermission = await _checkSmsPermissions();
      if (!hasPermission) {
        print('📱 Cannot start SMS listener - no permissions');
        return false;
      }

      // Start listening to incoming SMS using the correct API
      _smsSubscription = _plugin.smsStream.listen(
        _handleIncomingSms,
        onError: (error) {
          print('❌ SMS listener error: $error');
        },
      );

      isListening.value = true;
      print('📱 Started listening for SMS messages');

      return true;
    } catch (e) {
      print('❌ Error starting SMS listener: $e');
      return false;
    }
  }

  /// Stop listening for SMS messages
  void stopListening() {
    _smsSubscription?.cancel();
    _smsSubscription = null;
    isListening.value = false;
    print('📱 Stopped SMS listener');
  }

  /// Handle incoming SMS message
  void _handleIncomingSms(SMS sms) async {
    try {
      print(
        '📱 Received SMS from: ${sms.sender}, body: ${sms.body.substring(0, sms.body.length > 50 ? 50 : sms.body.length)}...',
      );

      // Convert to our SmsMessage model
      final smsMessage = SmsMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: sms.sender,
        body: sms.body,
        timestamp: sms.timeReceived,
        address: sms
            .sender, // Use sender as address since readsms doesn't have address field
      );

      // Only process mobile money related messages
      if (!smsMessage.isMobileMoneyTransaction) {
        print('📱 Skipping non-mobile money SMS');
        return;
      }

      print('💰 Processing mobile money SMS from: ${smsMessage.sender}');

      // Add to incoming messages list
      incomingMessages.insert(0, smsMessage);

      // Analyze for fraud in background
      await _analyzeInBackground(smsMessage);
    } catch (e) {
      print('❌ Error handling incoming SMS: $e');
    }
  }

  /// Analyze message in background
  Future<void> _analyzeInBackground(SmsMessage message) async {
    try {
      print('🔍 Analyzing SMS in background: ${message.id}');

      final result = await _fraudService.analyzeSmsMessage(
        message,
        source: 'BACKGROUND_SCAN',
      );

      // Add result to background results
      backgroundResults.insert(0, result);

      // Show fraud alert if detected
      if (result.isFraud) {
        await _showBackgroundFraudAlert(message, result);
      }

      print(
        '✅ Background analysis complete for ${message.id}: ${result.isFraud ? 'FRAUD' : 'SAFE'}',
      );
    } catch (e) {
      print('❌ Error in background analysis: $e');
    }
  }

  /// Show fraud alert for background detection
  Future<void> _showBackgroundFraudAlert(
    SmsMessage message,
    FraudResult result,
  ) async {
    try {
      // Show notification-style alert
      Get.snackbar(
        '⚠️ Fraud Alert',
        'Suspicious message detected from ${message.sender}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        isDismissible: true,
        showProgressIndicator: true,
        progressIndicatorBackgroundColor: Colors.red.withOpacity(0.3),
        progressIndicatorValueColor: const AlwaysStoppedAnimation<Color>(
          Colors.white,
        ),
        onTap: (_) {
          // Navigate to SMS scanner view
          Get.toNamed('/sms-scanner');
        },
        mainButton: TextButton(
          onPressed: () {
            Get.closeCurrentSnackbar();
            Get.toNamed('/sms-scanner');
          },
          child: const Text(
            'View Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Also show a more detailed dialog if app is in foreground
      if (Get.isDialogOpen != true) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showDetailedFraudDialog(message, result);
        });
      }
    } catch (e) {
      print('❌ Error showing fraud alert: $e');
    }
  }

  /// Show detailed fraud dialog
  void _showDetailedFraudDialog(SmsMessage message, FraudResult result) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('Fraud Detected!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suspicious message detected from ${message.sender}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Risk Level: ${result.riskLevelText}'),
            Text(
              'Confidence: ${(result.confidenceScore * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 12),
            if (result.redFlags.isNotEmpty) ...[
              const Text(
                'Risk Factors:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...result.redFlags.map(
                (flag) => Text('• $flag', style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 12),
            ],
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.body,
                style: const TextStyle(fontSize: 12),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Dismiss')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/sms-scanner');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
            ),
            child: const Text(
              'View All Results',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Get recent background scan results
  List<FraudResult> getRecentBackgroundResults({int limit = 10}) {
    return backgroundResults.take(limit).toList();
  }

  /// Clear background results
  void clearBackgroundResults() {
    backgroundResults.clear();
    incomingMessages.clear();
  }

  /// Get statistics for background monitoring
  Map<String, dynamic> getBackgroundStats() {
    final totalScanned = backgroundResults.length;
    final fraudDetected = backgroundResults.where((r) => r.isFraud).length;

    return {
      'totalScanned': totalScanned,
      'fraudDetected': fraudDetected,
      'isListening': isListening.value,
      'lastScan': backgroundResults.isNotEmpty
          ? backgroundResults.first.analyzedAt
          : null,
    };
  }
}
