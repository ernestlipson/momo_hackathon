import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momo_hackathon/app/data/models/scan_history.dart';
import 'package:momo_hackathon/app/data/models/fraud_result.dart';
import 'package:momo_hackathon/app/data/models/sms_message.dart';

class HistoryController extends GetxController {
  // Storage
  final GetStorage _storage = GetStorage();

  // Observable variables for history data
  final scanHistories = <ScanHistory>[].obs;
  final isLoading = false.obs;

  final selectedNavIndex = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistoryData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void loadHistoryData() {
    try {
      isLoading.value = true;

      // Load from storage
      final stored = _storage.read('scan_histories');
      if (stored != null) {
        final List<dynamic> jsonList = stored;
        scanHistories.assignAll(
          jsonList.map((json) => ScanHistory.fromJson(json)).toList(),
        );
      } else {
        // Create sample data for demo
        _createSampleHistories();
      }

      // Sort by date (newest first)
      scanHistories.sort((a, b) => b.scanDate.compareTo(a.scanDate));
    } catch (e) {
      print('Error loading history data: $e');
      _createSampleHistories();
    } finally {
      isLoading.value = false;
    }
  }

  /// Create sample scan histories for demo
  void _createSampleHistories() {
    final now = DateTime.now();

    scanHistories.assignAll([
      ScanHistory(
        id: 'scan_${now.millisecondsSinceEpoch}',
        scanDate: now.subtract(const Duration(hours: 2)),
        totalMessagesScanned: 15,
        fraudDetected: 2,
        legitimateMessages: 13,
        scanType: 'manual',
        scannedMessages: _getSampleMessages(
          now.subtract(const Duration(hours: 2)),
        ),
        fraudResults: _getSampleFraudResults(
          now.subtract(const Duration(hours: 2)),
        ),
      ),
      ScanHistory(
        id: 'scan_${now.millisecondsSinceEpoch - 1}',
        scanDate: now.subtract(const Duration(days: 1)),
        totalMessagesScanned: 8,
        fraudDetected: 1,
        legitimateMessages: 7,
        scanType: 'background',
        scannedMessages: _getSampleMessages(
          now.subtract(const Duration(days: 1)),
        ),
        fraudResults: _getSampleFraudResults(
          now.subtract(const Duration(days: 1)),
        ),
      ),
      ScanHistory(
        id: 'scan_${now.millisecondsSinceEpoch - 2}',
        scanDate: now.subtract(const Duration(days: 3)),
        totalMessagesScanned: 22,
        fraudDetected: 0,
        legitimateMessages: 22,
        scanType: 'manual',
        scannedMessages: _getSampleMessages(
          now.subtract(const Duration(days: 3)),
        ),
        fraudResults: [],
      ),
    ]);

    _saveToStorage();
  }

  List<SmsMessage> _getSampleMessages(DateTime baseDate) {
    return [
      SmsMessage(
        id: 'msg_1_${baseDate.millisecondsSinceEpoch}',
        sender: 'MTN',
        body:
            'Your MTN mobile money transaction was successful. You have received GHS 50.00 from 0244123456.',
        timestamp: baseDate,
        address: '0244123456',
      ),
      SmsMessage(
        id: 'msg_2_${baseDate.millisecondsSinceEpoch}',
        sender: 'VODAFONE',
        body:
            'You have successfully sent GHS 25.00 to 0201987654. Your new balance is GHS 75.50.',
        timestamp: baseDate.subtract(const Duration(minutes: 30)),
        address: '0201987654',
      ),
    ];
  }

  List<FraudResult> _getSampleFraudResults(DateTime baseDate) {
    return [
      FraudResult(
        messageId: 'msg_fraud_${baseDate.millisecondsSinceEpoch}',
        isFraud: true,
        confidenceScore: 0.85,
        riskLevel: FraudRiskLevel.high,
        fraudType: FraudType.phishing,
        reason: 'Suspicious sender and urgent language detected',
        redFlags: [
          'Unknown sender',
          'Urgent action required',
          'Suspicious link',
        ],
        analyzedAt: baseDate,
      ),
    ];
  }

  /// Add new scan history
  void addScanHistory(ScanHistory scanHistory) {
    scanHistories.insert(0, scanHistory);
    _saveToStorage();
  }

  /// Save to storage
  void _saveToStorage() {
    try {
      final jsonList = scanHistories.map((scan) => scan.toJson()).toList();
      _storage.write('scan_histories', jsonList);
    } catch (e) {
      print('Error saving history data: $e');
    }
  }

  void onNavItemTapped(int index) {
    selectedNavIndex.value = index;

    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        // Already on History
        break;
      case 2:
        Get.toNamed('/settings');
        break;
    }
  }

  void clearHistory() {
    Get.defaultDialog(
      title: 'Clear History',
      middleText: 'Are you sure you want to clear all scan history?',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        scanHistories.clear();
        _storage.remove('scan_histories');
        Get.back();
        Get.snackbar(
          'Success',
          'History cleared successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      },
    );
  }

  /// View scan details
  void viewScanDetails(ScanHistory scanHistory) {
    Get.dialog(
      AlertDialog(
        title: Text('Scan Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Scan Type', scanHistory.scanTypeDisplay),
              _buildDetailRow('Date', scanHistory.formattedDate),
              _buildDetailRow(
                'Messages Scanned',
                '${scanHistory.totalMessagesScanned}',
              ),
              _buildDetailRow('Fraud Detected', '${scanHistory.fraudDetected}'),
              _buildDetailRow(
                'Legitimate',
                '${scanHistory.legitimateMessages}',
              ),
              _buildDetailRow(
                'Fraud Rate',
                '${scanHistory.fraudRate.toStringAsFixed(1)}%',
              ),
              _buildDetailRow(
                'Safety Score',
                '${scanHistory.safetyScore.toStringAsFixed(1)}%',
              ),
              if (scanHistory.fraudDetected > 0) ...[
                const SizedBox(height: 16),
                const Text(
                  'High Risk Frauds:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...scanHistory.highRiskFrauds.map(
                  (fraud) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '• ${fraud.fraudType?.name.toUpperCase() ?? 'UNKNOWN'}: ${fraud.reason ?? 'No details'}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
