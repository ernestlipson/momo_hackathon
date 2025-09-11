import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readsms/readsms.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../../data/models/sms_message.dart';
import '../../../data/models/fraud_result.dart';
import '../../../data/services/fraud_detection_service.dart';
import '../../../data/services/sms_listener_service.dart';
import '../../../data/services/background_sms_worker.dart';

class SmsScannerController extends GetxController {
  // Services
  final FraudDetectionService _fraudService = Get.find<FraudDetectionService>();
  final SmsListenerService _smsListener = Get.find<SmsListenerService>();
  final GetStorage _storage = GetStorage();
  final Readsms _readsms = Readsms();

  // Observables
  final isScanning = false.obs;
  final hasPermission = false.obs;
  final scannedMessages = <SmsMessage>[].obs;
  final fraudResults = <FraudResult>[].obs;
  final isAnalyzing = false.obs;
  final selectedNavIndex = 0.obs;
  final isBackgroundMonitoring = false.obs;

  // Statistics
  final totalScanned = 0.obs;
  final fraudDetected = 0.obs;
  final lastScanTime = Rxn<DateTime>();

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
      _initializeBackgroundMonitoring();
    }
  }

  @override
  void onClose() {
    _smsListener.stopListening();
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

  /// Initialize background SMS monitoring
  Future<void> _initializeBackgroundMonitoring() async {
    if (!hasPermission.value) return;

    try {
      // Initialize background worker
      await BackgroundSmsWorker.initialize();
      
      // Check if background monitoring was previously enabled
      final wasEnabled = await BackgroundSmsWorker.isBackgroundMonitoringEnabled();
      isBackgroundMonitoring.value = wasEnabled;
      
      if (wasEnabled) {
        await _startBackgroundMonitoring();
      }
      
      print('📱 Background monitoring initialized');
    } catch (e) {
      print('❌ Error initializing background monitoring: $e');
    }
  }

  /// Start background SMS monitoring
  Future<void> _startBackgroundMonitoring() async {
    if (!hasPermission.value) return;

    try {
      // Start the SMS listener service
      final started = await _smsListener.startListening();
      
      if (started) {
        // Start background worker
        await BackgroundSmsWorker.startBackgroundMonitoring();
        isBackgroundMonitoring.value = true;
        
        print('📱 Background SMS monitoring started');
        
        // Merge background results with controller results
        _mergeBackgroundResults();
      } else {
        print('❌ Failed to start SMS listener');
      }
    } catch (e) {
      print('❌ Error starting background monitoring: $e');
    }
  }

  /// Merge background results with controller results
  void _mergeBackgroundResults() {
    // Listen to background results and merge them
    ever(_smsListener.backgroundResults, (List<FraudResult> results) {
      for (final result in results) {
        // Add to fraud results if not already present
        if (!fraudResults.any((r) => r.messageId == result.messageId)) {
          fraudResults.insert(0, result);
          if (result.isFraud) {
            fraudDetected.value++;
          }
        }
      }
      _saveToStorage();
    });

    // Listen to incoming messages and merge them
    ever(_smsListener.incomingMessages, (List<SmsMessage> messages) {
      for (final message in messages) {
        // Add to scanned messages if not already present
        if (!scannedMessages.any((m) => m.id == message.id)) {
          scannedMessages.insert(0, message);
          totalScanned.value++;
        }
      }
      _saveToStorage();
    });
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
      // Read SMS messages from device
      final smsMessages = await _readsms.read();
      
      // Filter only mobile money messages from the last 30 days
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final mobileMoneyMessages = smsMessages
          .where((sms) => sms.timeReceived.isAfter(cutoffDate))
          .map((sms) => SmsMessage(
                id: sms.timeReceived.millisecondsSinceEpoch.toString(),
                sender: sms.sender,
                body: sms.body,
                timestamp: sms.timeReceived,
                address: sms.sender,
              ))
          .where((msg) => msg.isMobileMoneyTransaction)
          .toList();

      print('📱 Found ${mobileMoneyMessages.length} mobile money messages');

      // Clear previous results
      scannedMessages.clear();
      fraudResults.clear();

      // Add and analyze each message
      for (SmsMessage message in mobileMoneyMessages) {
        scannedMessages.add(message);
        await _analyzeMessage(message);
      }

      totalScanned.value = scannedMessages.length;
      lastScanTime.value = DateTime.now();
      _saveToStorage();

      Get.snackbar(
        'Scan Complete',
        'Analyzed ${mobileMoneyMessages.length} mobile money messages',
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

      final result = await _fraudService.analyzeSmsMessage(message, source: 'USER_SCAN');
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
        
        // Also clear background results
        _smsListener.clearBackgroundResults();
        
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
  Future<void> toggleBackgroundMonitoring() async {
    try {
      if (isBackgroundMonitoring.value) {
        // Stop background monitoring
        _smsListener.stopListening();
        await BackgroundSmsWorker.stopBackgroundMonitoring();
        await BackgroundSmsWorker.setBackgroundMonitoringEnabled(false);
        isBackgroundMonitoring.value = false;
        
        Get.snackbar(
          'Background Monitoring Disabled',
          'SMS fraud detection will only work when app is open',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        // Start background monitoring
        if (!hasPermission.value) {
          await requestPermissions();
          if (!hasPermission.value) return;
        }
        
        await _startBackgroundMonitoring();
        await BackgroundSmsWorker.setBackgroundMonitoringEnabled(true);
        
        Get.snackbar(
          'Background Monitoring Enabled',
          'SMS fraud detection is now active in the background',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error toggling background monitoring: $e');
      Get.snackbar(
        'Error',
        'Failed to toggle background monitoring: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}
