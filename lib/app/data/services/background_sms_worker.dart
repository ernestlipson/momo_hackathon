import 'package:workmanager/workmanager.dart';
import 'package:get_storage/get_storage.dart';

/// Background SMS worker for continuous monitoring
/// This worker runs in the background even when the app is closed
class BackgroundSmsWorker {
  static const String TASK_NAME = 'sms_fraud_background_monitor';
  static const String UNIQUE_NAME = 'sms_fraud_worker';

  /// Initialize the background worker
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to true for debugging
    );

    print('🔧 Background SMS Worker initialized');
  }

  /// Register the background monitoring task
  static Future<void> startBackgroundMonitoring() async {
    try {
      await Workmanager().registerPeriodicTask(
        UNIQUE_NAME,
        TASK_NAME,
        frequency: const Duration(minutes: 15), // Check every 15 minutes
        constraints: Constraints(
          networkType: NetworkType.connected, // Require internet for API calls
          requiresBatteryNotLow: true,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        initialDelay: const Duration(minutes: 1), // Start after 1 minute
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 5),
      );

      print('⏰ Background SMS monitoring task registered');
    } catch (e) {
      print('❌ Failed to register background task: $e');
    }
  }

  /// Stop background monitoring
  static Future<void> stopBackgroundMonitoring() async {
    try {
      await Workmanager().cancelByUniqueName(UNIQUE_NAME);
      print('⏹️ Background SMS monitoring stopped');
    } catch (e) {
      print('❌ Failed to stop background monitoring: $e');
    }
  }

  /// Check if background monitoring is enabled
  static Future<bool> isBackgroundMonitoringEnabled() async {
    // Check if the task is registered by looking at storage
    final storage = GetStorage();
    return storage.read('background_monitoring_enabled') ?? false;
  }

  /// Enable/disable background monitoring
  static Future<void> setBackgroundMonitoringEnabled(bool enabled) async {
    final storage = GetStorage();
    await storage.write('background_monitoring_enabled', enabled);

    if (enabled) {
      await startBackgroundMonitoring();
    } else {
      await stopBackgroundMonitoring();
    }
  }
}

/// Callback dispatcher for background tasks
/// This function runs in a separate isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      print('🔄 Background task started: $taskName');

      switch (taskName) {
        case BackgroundSmsWorker.TASK_NAME:
          await _performBackgroundSmsCheck();
          break;
        default:
          print('⚠️ Unknown task: $taskName');
          break;
      }

      print('✅ Background task completed: $taskName');
      return Future.value(true);
    } catch (e) {
      print('❌ Background task failed: $taskName - $e');
      return Future.value(false);
    }
  });
}

/// Perform background SMS check
Future<void> _performBackgroundSmsCheck() async {
  try {
    // Initialize GetStorage for background task
    await GetStorage.init();

    // For now, this will just log that the background task is running
    // In a full implementation, you might:
    // 1. Check for new SMS messages since last check
    // 2. Analyze any new mobile money messages
    // 3. Store results for when the app reopens
    // 4. Send local notifications for fraud alerts

    print('📱 Background SMS check performed at ${DateTime.now()}');

    // Store the last check time
    final storage = GetStorage();
    await storage.write(
      'last_background_check',
      DateTime.now().toIso8601String(),
    );

    // In a real implementation, you would integrate with the SMS listener here
    // However, reading SMS in background requires special handling and might
    // be restricted on newer Android versions
  } catch (e) {
    print('❌ Error in background SMS check: $e');
  }
}

/// Utility functions for background worker management
class BackgroundWorkerUtils {
  static final GetStorage _storage = GetStorage();

  /// Get last background check time
  static DateTime? getLastBackgroundCheckTime() {
    final timeStr = _storage.read('last_background_check');
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  /// Get background monitoring statistics
  static Map<String, dynamic> getBackgroundStats() {
    final lastCheck = getLastBackgroundCheckTime();
    final isEnabled = _storage.read('background_monitoring_enabled') ?? false;

    return {
      'isEnabled': isEnabled,
      'lastCheck': lastCheck,
      'timeSinceLastCheck': lastCheck != null
          ? DateTime.now().difference(lastCheck).inMinutes
          : null,
    };
  }

  /// Clear background worker data
  static Future<void> clearBackgroundData() async {
    await _storage.remove('last_background_check');
    await _storage.remove('background_monitoring_enabled');
  }
}
