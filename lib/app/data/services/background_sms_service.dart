import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../models/sms_message.dart';
import '../models/fraud_result.dart';
import 'fraud_detection_service.dart';

/// Background service for continuous SMS monitoring and fraud detection
class BackgroundSmsService extends GetxService {
  static const String _taskName = 'smsMonitoringTask';
  static const String _storageKey = 'background_sms_service';
  
  final GetStorage _storage = GetStorage();
  final FraudDetectionService _fraudService = Get.find<FraudDetectionService>();
  final SmsQuery _smsQuery = SmsQuery();
  
  // Service state
  final isRunning = false.obs;
  final lastCheck = Rxn<DateTime>();
  StreamSubscription<SmsMessage>? _smsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeWorkManager();
    _loadServiceState();
  }

  @override
  void onClose() {
    stopBackgroundMonitoring();
    super.onClose();
  }

  /// Initialize WorkManager for background tasks
  void _initializeWorkManager() {
    try {
      Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false, // Set to true for debugging
      );
    } catch (e) {
      print('Error initializing WorkManager: $e');
    }
  }

  /// Start background SMS monitoring
  Future<void> startBackgroundMonitoring() async {
    if (isRunning.value) {
      print('Background monitoring is already running');
      return;
    }

    try {
      // Start periodic task to check for new SMS messages
      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency: const Duration(minutes: 15), // Check every 15 minutes
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        inputData: {
          'action': 'monitor_sms',
          'last_check': lastCheck.value?.millisecondsSinceEpoch ?? 0,
        },
      );

      // Also start real-time SMS listener if possible
      await _startRealtimeSmsListener();

      isRunning.value = true;
      lastCheck.value = DateTime.now();
      _saveServiceState();

      print('Background SMS monitoring started');
    } catch (e) {
      print('Error starting background monitoring: $e');
      throw Exception('Failed to start background monitoring: $e');
    }
  }

  /// Stop background SMS monitoring
  Future<void> stopBackgroundMonitoring() async {
    try {
      await Workmanager().cancelByUniqueName(_taskName);
      await _smsSubscription?.cancel();
      _smsSubscription = null;
      
      isRunning.value = false;
      _saveServiceState();
      
      print('Background SMS monitoring stopped');
    } catch (e) {
      print('Error stopping background monitoring: $e');
    }
  }

  /// Start real-time SMS listener (for when app is active)
  Future<void> _startRealtimeSmsListener() async {
    try {
      _smsSubscription = SmsReceiver().onSmsReceived!.listen(
        (SmsMessage sms) async {
          final message = _convertToOurSmsMessage(sms);
          if (message.isMobileMoneyTransaction) {
            await _processSmsMessage(message);
          }
        },
        onError: (error) {
          print('Error in SMS listener: $error');
        },
      );
    } catch (e) {
      print('Error starting real-time SMS listener: $e');
    }
  }

  /// Process a single SMS message for fraud detection
  Future<void> _processSmsMessage(SmsMessage message) async {
    try {
      print('Processing SMS from ${message.sender}');
      
      // Analyze message for fraud
      final result = await _fraudService.analyzeSmsMessage(message);
      
      // Store result
      _storeAnalysisResult(message, result);
      
      // If fraud detected, show notification
      if (result.isFraud) {
        await _showFraudNotification(message, result);
      }
      
      lastCheck.value = DateTime.now();
      _saveServiceState();
      
    } catch (e) {
      print('Error processing SMS message: $e');
    }
  }

  /// Convert sms_advanced SmsMessage to our SmsMessage model
  SmsMessage _convertToOurSmsMessage(dynamic smsMessage) {
    return SmsMessage(
      id: smsMessage.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sender: smsMessage.sender ?? 'Unknown',
      body: smsMessage.body ?? '',
      timestamp: smsMessage.date ?? DateTime.now(),
      address: smsMessage.address,
    );
  }

  /// Store analysis result locally
  void _storeAnalysisResult(SmsMessage message, FraudResult result) {
    try {
      final existingResults = _storage.read<List>('background_fraud_results') ?? [];
      existingResults.insert(0, {
        'message': message.toJson(),
        'result': result.toJson(),
        'processed_at': DateTime.now().toIso8601String(),
      });
      
      // Keep only last 100 results
      if (existingResults.length > 100) {
        existingResults.removeRange(100, existingResults.length);
      }
      
      _storage.write('background_fraud_results', existingResults);
    } catch (e) {
      print('Error storing analysis result: $e');
    }
  }

  /// Show notification for fraud detection
  Future<void> _showFraudNotification(SmsMessage message, FraudResult result) async {
    try {
      // In a full implementation, you would use flutter_local_notifications
      // For now, we'll just log and store for later display
      print('🚨 FRAUD DETECTED: ${message.sender} - ${result.reason}');
      
      // Store fraud alert for app to display when opened
      _storeFraudAlert(message, result);
      
    } catch (e) {
      print('Error showing fraud notification: $e');
    }
  }

  /// Store fraud alert for later display
  void _storeFraudAlert(SmsMessage message, FraudResult result) {
    try {
      final alerts = _storage.read<List>('pending_fraud_alerts') ?? [];
      alerts.add({
        'message': message.toJson(),
        'result': result.toJson(),
        'alert_time': DateTime.now().toIso8601String(),
        'shown': false,
      });
      
      _storage.write('pending_fraud_alerts', alerts);
    } catch (e) {
      print('Error storing fraud alert: $e');
    }
  }

  /// Get pending fraud alerts
  List<Map<String, dynamic>> getPendingFraudAlerts() {
    try {
      final alerts = _storage.read<List>('pending_fraud_alerts') ?? [];
      return alerts.cast<Map<String, dynamic>>()
          .where((alert) => alert['shown'] == false)
          .toList();
    } catch (e) {
      print('Error getting pending fraud alerts: $e');
      return [];
    }
  }

  /// Mark fraud alerts as shown
  void markAlertsAsShown(List<String> alertIds) {
    try {
      final alerts = _storage.read<List>('pending_fraud_alerts') ?? [];
      for (var alert in alerts) {
        if (alertIds.contains(alert['result']['messageId'])) {
          alert['shown'] = true;
        }
      }
      _storage.write('pending_fraud_alerts', alerts);
    } catch (e) {
      print('Error marking alerts as shown: $e');
    }
  }

  /// Load service state from storage
  void _loadServiceState() {
    try {
      final state = _storage.read(_storageKey);
      if (state != null) {
        isRunning.value = state['isRunning'] ?? false;
        if (state['lastCheck'] != null) {
          lastCheck.value = DateTime.parse(state['lastCheck']);
        }
      }
    } catch (e) {
      print('Error loading service state: $e');
    }
  }

  /// Save service state to storage
  void _saveServiceState() {
    try {
      _storage.write(_storageKey, {
        'isRunning': isRunning.value,
        'lastCheck': lastCheck.value?.toIso8601String(),
      });
    } catch (e) {
      print('Error saving service state: $e');
    }
  }

  /// Get service status
  Map<String, dynamic> getServiceStatus() {
    return {
      'isRunning': isRunning.value,
      'lastCheck': lastCheck.value,
      'pendingAlerts': getPendingFraudAlerts().length,
    };
  }
}

/// WorkManager callback dispatcher for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('Background task executed: $task');
      
      switch (inputData?['action']) {
        case 'monitor_sms':
          await _performBackgroundSmsCheck(inputData);
          break;
        default:
          print('Unknown background task action');
      }
      
      return Future.value(true);
    } catch (e) {
      print('Error in background task: $e');
      return Future.value(false);
    }
  });
}

/// Perform background SMS check
Future<void> _performBackgroundSmsCheck(Map<String, dynamic>? inputData) async {
  try {
    // Initialize services for background context
    final storage = GetStorage();
    await storage.initStorage();
    
    final smsQuery = SmsQuery();
    final lastCheckTime = DateTime.fromMillisecondsSinceEpoch(
      inputData?['last_check'] ?? 0
    );
    
    // Query recent SMS messages since last check
    final messages = await smsQuery.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 20,
    );
    
    // Filter new mobile money messages
    final newMessages = messages.where((sms) {
      final message = SmsMessage(
        id: sms.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        sender: sms.sender ?? 'Unknown',
        body: sms.body ?? '',
        timestamp: sms.date ?? DateTime.now(),
        address: sms.address,
      );
      
      return message.isMobileMoneyTransaction && 
             message.timestamp.isAfter(lastCheckTime);
    });
    
    print('Found ${newMessages.length} new mobile money messages');
    
    // Process each new message (simplified analysis for background)
    for (final sms in newMessages) {
      final message = SmsMessage(
        id: sms.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        sender: sms.sender ?? 'Unknown',
        body: sms.body ?? '',
        timestamp: sms.date ?? DateTime.now(),
        address: sms.address,
      );
      
      // Store for later processing when app opens
      final pendingMessages = storage.read<List>('pending_background_messages') ?? [];
      pendingMessages.add(message.toJson());
      await storage.write('pending_background_messages', pendingMessages);
    }
    
  } catch (e) {
    print('Error in background SMS check: $e');
  }
}