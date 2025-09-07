import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:sms_advanced/sms_advanced.dart'; // Temporarily disabled
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../../data/models/sms_message.dart';
import '../../../data/models/fraud_result.dart';
import '../../../data/services/fraud_detection_service.dart';

class SmsScannerController extends GetxController {
  // Services
  final FraudDetectionService _fraudService = Get.find<FraudDetectionService>();
  final GetStorage _storage = GetStorage();

  // Observables
  final isScanning = false.obs;
  final hasPermission = false.obs;
  final scannedMessages = <SmsMessage>[].obs;
  final fraudResults = <FraudResult>[].obs;
  final isAnalyzing = false.obs;
  final selectedNavIndex = 0.obs;

  // Statistics
  final totalScanned = 0.obs;
  final fraudDetected = 0.obs;
  final lastScanTime = Rxn<DateTime>();

  // SMS receiver - temporarily disabled for demo
  // SmsReceiver? _smsReceiver;
  // StreamSubscription<SmsMessage>? _smsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeStorage();
    _checkPermissions();
    _loadStoredData();
  }

  @override
  void onReady() {
    super.onReady();
    if (hasPermission.value) {
      _startBackgroundMonitoring();
    }
  }

  @override
  void onClose() {
    // _smsSubscription?.cancel(); // Temporarily disabled
    super.onClose();
  }

  void _initializeStorage() {
    GetStorage.init();
  }

  /// Check and request SMS permissions
  Future<void> _checkPermissions() async {
    final status = await Permission.sms.status;
    hasPermission.value = status.isGranted;

    if (!hasPermission.value) {
      await requestPermissions();
    }
  }

  /// Request SMS permissions
  Future<void> requestPermissions() async {
    final status = await Permission.sms.request();
    hasPermission.value = status.isGranted;

    if (hasPermission.value) {
      Get.snackbar(
        'Permission Granted',
        'SMS scanning is now enabled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      _startBackgroundMonitoring();
    } else {
      Get.snackbar(
        'Permission Required',
        'SMS permission is needed for fraud detection',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  /// Start background SMS monitoring
  void _startBackgroundMonitoring() {
    if (!hasPermission.value) return;

    // Temporarily disabled - will implement with working SMS library
    print('📱 Background SMS monitoring ready (demo mode)');

    // For demo, create some sample data
    _createSampleData();
  }

  /// Handle incoming SMS messages (disabled in demo mode)
  // void _handleIncomingSms(SmsMessage message) async {
  //   // Only process mobile money transactions
  //   if (!message.isMobileMoneyTransaction) return;
  //
  //   print('💰 Mobile money SMS detected: ${message.sender}');
  //
  //   // Add to scanned messages
  //   scannedMessages.insert(0, message);
  //   totalScanned.value++;
  //
  //   // Analyze for fraud
  //   await _analyzeMessage(message);
  //
  //   // Save to storage
  //   _saveToStorage();
  //
  //   // Update last scan time
  //   lastScanTime.value = DateTime.now();
  // }

  /// Manually scan recent SMS messages
  Future<void> scanRecentMessages() async {
    if (!hasPermission.value) {
      await requestPermissions();
      return;
    }

    isScanning.value = true;

    try {
      // For demo purposes, create sample mobile money SMS messages
      final sampleMessages = _createSampleMessages();

      print('📱 Found ${sampleMessages.length} mobile money messages (demo)');

      // Clear previous results
      scannedMessages.clear();
      fraudResults.clear();

      // Add and analyze each message
      for (SmsMessage message in sampleMessages) {
        scannedMessages.add(message);
        await _analyzeMessage(message);
      }

      totalScanned.value = scannedMessages.length;
      lastScanTime.value = DateTime.now();
      _saveToStorage();

      Get.snackbar(
        'Scan Complete',
        'Analyzed ${sampleMessages.length} mobile money messages',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error scanning messages: $e');
      Get.snackbar(
        'Scan Error',
        'Failed to scan messages: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isScanning.value = false;
    }
  }

  /// Analyze a single message for fraud
  Future<void> _analyzeMessage(SmsMessage message) async {
    try {
      isAnalyzing.value = true;

      final result = await _fraudService.analyzeSmsMessage(message);
      fraudResults.insert(0, result);

      if (result.isFraud) {
        fraudDetected.value++;
        _showFraudAlert(message, result);
      }
    } catch (e) {
      print('Error analyzing message: $e');
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// Show fraud alert to user
  void _showFraudAlert(SmsMessage message, FraudResult result) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('Fraud Alert!'),
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
            const SizedBox(height: 8),
            Text('Risk Level: ${result.riskLevelText}'),
            Text(
              'Confidence: ${(result.confidenceScore * 100).toStringAsFixed(1)}%',
            ),
            if (result.reason != null) ...[
              const SizedBox(height: 8),
              Text(
                'Reason: ${result.reason}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.body,
                style: const TextStyle(fontSize: 12),
                maxLines: 3,
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
              'View Details',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Get fraud statistics
  Map<String, dynamic> get fraudStats {
    return _fraudService.getFraudStats(fraudResults);
  }

  /// Load stored data from local storage
  void _loadStoredData() {
    try {
      final storedMessages = _storage.read('scanned_messages');
      final storedResults = _storage.read('fraud_results');
      final storedStats = _storage.read('scan_stats');

      if (storedMessages != null) {
        scannedMessages.value = (storedMessages as List)
            .map((json) => SmsMessage.fromJson(json))
            .toList();
      }

      if (storedResults != null) {
        fraudResults.value = (storedResults as List)
            .map((json) => FraudResult.fromJson(json))
            .toList();
      }

      if (storedStats != null) {
        totalScanned.value = storedStats['totalScanned'] ?? 0;
        fraudDetected.value = storedStats['fraudDetected'] ?? 0;
        final lastScanStr = storedStats['lastScanTime'];
        if (lastScanStr != null) {
          lastScanTime.value = DateTime.parse(lastScanStr);
        }
      }
    } catch (e) {
      print('Error loading stored data: $e');
    }
  }

  /// Save data to local storage
  void _saveToStorage() {
    try {
      _storage.write(
        'scanned_messages',
        scannedMessages.map((msg) => msg.toJson()).toList(),
      );
      _storage.write(
        'fraud_results',
        fraudResults.map((result) => result.toJson()).toList(),
      );
      _storage.write('scan_stats', {
        'totalScanned': totalScanned.value,
        'fraudDetected': fraudDetected.value,
        'lastScanTime': lastScanTime.value?.toIso8601String(),
      });
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  /// Navigation handling
  void onNavItemTapped(int index) {
    selectedNavIndex.value = index;

    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        Get.offAllNamed('/history');
        break;
      case 2:
        Get.offAllNamed('/settings');
        break;
    }
  }

  /// Get formatted last scan time
  String get lastScanTimeFormatted {
    if (lastScanTime.value == null) return 'Never';
    return DateFormat('MMM dd, yyyy HH:mm').format(lastScanTime.value!);
  }

  /// Clear all data
  void clearAllData() {
    Get.defaultDialog(
      title: 'Clear Data',
      middleText:
          'Are you sure you want to clear all scanned messages and results?',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        scannedMessages.clear();
        fraudResults.clear();
        totalScanned.value = 0;
        fraudDetected.value = 0;
        lastScanTime.value = null;
        _saveToStorage();

        Get.back();
        Get.snackbar(
          'Data Cleared',
          'All scan data has been cleared',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  /// Toggle background monitoring
  void toggleBackgroundMonitoring() {
    // For demo mode, just show a notification
    Get.snackbar(
      'Demo Mode',
      'Background monitoring is simulated in demo mode',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  /// Create sample data for demo purposes
  void _createSampleData() {
    // Create some sample messages for demo
    final sampleMessages = _createSampleMessages();
    scannedMessages.addAll(sampleMessages.take(3));
    totalScanned.value = scannedMessages.length;

    // Analyze a sample message to show fraud detection
    if (sampleMessages.isNotEmpty) {
      _analyzeMessage(sampleMessages.first);
    }
  }

  /// Create sample SMS messages for demo
  List<SmsMessage> _createSampleMessages() {
    final now = DateTime.now();

    return [
      SmsMessage(
        id: 'demo_1',
        sender: 'MTN',
        body:
            'Your MTN mobile money transaction was successful. You have received GHS 50.00 from 0244123456. New balance: GHS 150.00. Ref: MM123456789',
        timestamp: now.subtract(const Duration(hours: 1)),
        address: '0244123456',
      ),
      SmsMessage(
        id: 'demo_2',
        sender: 'UNKNOWN',
        body:
            'URGENT: Your account has been suspended. Click here to verify your account immediately: bit.ly/fake-link or you will lose your money!',
        timestamp: now.subtract(const Duration(hours: 2)),
        address: '0557123456',
      ),
      SmsMessage(
        id: 'demo_3',
        sender: 'VODAFONE',
        body:
            'You have successfully sent GHS 25.00 to 0201987654. Your new balance is GHS 75.50. Transaction ID: VF987654321',
        timestamp: now.subtract(const Duration(hours: 3)),
        address: '0201987654',
      ),
      SmsMessage(
        id: 'demo_4',
        sender: 'FAKE-MTN',
        body:
            'Congratulations! You have won GHS 10,000 in our lottery! To claim your prize, send your PIN to this number immediately!',
        timestamp: now.subtract(const Duration(days: 1)),
        address: '0555666777',
      ),
      SmsMessage(
        id: 'demo_5',
        sender: 'AIRTELTIGO',
        body:
            'You have received GHS 100.00 from 0208765432. Your wallet balance is now GHS 225.00. Ref: AT555444333',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        address: '0208765432',
      ),
    ];
  }
}
