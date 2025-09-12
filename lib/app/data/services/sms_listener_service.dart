import 'dart:async';

import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/fraud_result.dart';
import '../models/sms_message.dart' as app_models;
import 'fraud_detection_service.dart';

/// Background message handler for incoming SMS
@pragma('vm:entry-point')
backgroundMessageHandler(SmsMessage message) async {
  // Handle background SMS - for now just log it
  print('📱 Background SMS: ${message.address} - ${message.body}');
}

class SmsListenerService extends GetxService {
  final FraudDetectionService _fraudService = Get.find<FraudDetectionService>();
  final Telephony telephony = Telephony.instance;

  final RxBool isListening = false.obs;
  final RxList<app_models.SmsMessage> incomingMessages =
      <app_models.SmsMessage>[].obs;
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
    final hasPermissions = await telephony.requestPhoneAndSmsPermissions;
    return hasPermissions ?? false;
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

      // Start listening to incoming SMS using another_telephony
      telephony.listenIncomingSms(
        onNewMessage: _handleIncomingSms,
        onBackgroundMessage: backgroundMessageHandler,
        listenInBackground: true,
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
    isListening.value = false;
    print('📱 Stopped SMS listener');
  }

  /// Handle incoming SMS message
  void _handleIncomingSms(SmsMessage sms) async {
    try {
      final bodyPreview = (sms.body ?? '').length > 50
          ? '${(sms.body ?? '').substring(0, 50)}...'
          : (sms.body ?? '');
      print('📱 Received SMS from: ${sms.address}, body: $bodyPreview');

      // Convert to our SmsMessage model
      final smsMessage = app_models.SmsMessage(
        id:
            sms.id?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        sender: sms.address ?? 'Unknown',
        body: sms.body ?? '',
        timestamp: sms.date != null
            ? DateTime.fromMillisecondsSinceEpoch(sms.date as int)
            : DateTime.now(),
        address: sms.address,
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
  Future<void> _analyzeInBackground(app_models.SmsMessage message) async {
    try {
      print('🔍 Analyzing SMS in background: ${message.id}');

      final result = await _fraudService.analyzeSmsMessage(
        message: message,
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
    app_models.SmsMessage message,
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
  void _showDetailedFraudDialog(
    app_models.SmsMessage message,
    FraudResult result,
  ) {
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
