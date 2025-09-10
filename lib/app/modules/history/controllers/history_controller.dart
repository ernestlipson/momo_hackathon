import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momo_hackathon/app/data/models/scan_history.dart';
import 'package:momo_hackathon/app/data/models/fraud_result.dart';
import 'package:momo_hackathon/app/data/models/sms_message.dart';
import 'package:momo_hackathon/app/data/models/recent_analysis.dart';
import 'package:momo_hackathon/app/data/services/fraud_detection_service.dart';

class HistoryController extends GetxController {
  // Storage
  final GetStorage _storage = GetStorage();

  // Services
  final FraudDetectionService _fraudService = Get.find<FraudDetectionService>();

  // Observable variables for history data
  final recentAnalyses = <RecentAnalysis>[].obs;
  final totalAnalyses = 0.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadHistoryData();
  }

  /// Load recent analyses from API
  Future<void> loadHistoryData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Fetch recent analyses from API
      final response = await _fraudService.getRecentAnalyses();

      recentAnalyses.assignAll(response.analyses);
      totalAnalyses.value = response.total;

      print('📊 Loaded ${response.analyses.length} recent analyses');
    } catch (e) {
      print('❌ Error loading recent analyses: $e');
      errorMessage.value = e.toString();

      // Show user-friendly error message
      Get.snackbar(
        'Loading Error',
        'Unable to load recent analyses. Please check your connection and try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh recent analyses from API
  Future<void> refreshHistoryData() async {
    await loadHistoryData();

    if (recentAnalyses.isNotEmpty && errorMessage.value == null) {
      Get.snackbar(
        'History Updated',
        'Recent analyses refreshed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void clearHistory() {
    Get.defaultDialog(
      title: 'Clear History',
      middleText:
          'This will clear your local history cache. Data will be reloaded from the server.',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        recentAnalyses.clear();
        totalAnalyses.value = 0;
        Get.back();
        Get.snackbar(
          'Success',
          'Local history cleared successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      },
    );
  }

  /// View analysis details
  void viewAnalysisDetails(RecentAnalysis analysis) {
    Get.dialog(
      AlertDialog(
        title: const Text('Analysis Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Status', analysis.statusDisplay),
              _buildDetailRow('Confidence', analysis.confidenceDisplay),
              _buildDetailRow('Risk Level', analysis.riskLevel),
              _buildDetailRow('Source', analysis.sourceDisplay),
              _buildDetailRow('Type', analysis.typeDisplay),
              _buildDetailRow('Date', analysis.formattedDate),
              _buildDetailRow('Analysis ID', analysis.analysisId),
              if (analysis.riskFactors.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Risk Factors:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...analysis.riskFactors.map(
                  (factor) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '• $factor',
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
