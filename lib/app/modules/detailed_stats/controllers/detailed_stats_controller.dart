import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:momo_hackathon/app/data/models/fraud_detection_stats.dart';
import 'package:momo_hackathon/app/data/services/fraud_detection_service.dart';

class DetailedStatsController extends GetxController {
  // Services
  final FraudDetectionService _fraudService = Get.find<FraudDetectionService>();

  // Observable variables for detailed stats
  final detailedStats = FraudDetectionStats.empty().obs;
  final isLoading = false.obs;
  final error = RxnString();

  // Date range selection
  final selectedTimeRange = 'Last 30 Days'.obs;
  final timeRangeOptions = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'Last 6 Months',
    'Last Year',
    'All Time',
  ];

  // Chart data observables
  final chartData = <Map<String, dynamic>>[].obs;
  final isLoadingChart = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDetailedStats();
    loadChartData();
  }

  /// Load detailed fraud detection statistics
  Future<void> loadDetailedStats() async {
    try {
      isLoading.value = true;
      error.value = null;

      final stats = await _fraudService.getStatsOverview();
      detailedStats.value = stats!;

      print(
        '📊 Loaded detailed fraud detection statistics: ${stats.totalAnalyses} analyses',
      );
    } catch (e) {
      print('❌ Error loading detailed stats: $e');
      error.value = e.toString();

      Get.snackbar(
        'Statistics Loading Error',
        'Unable to load detailed fraud detection statistics.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load chart data for visualizations
  Future<void> loadChartData() async {
    try {
      isLoadingChart.value = true;

      // Generate mock chart data - in real app this would come from the service
      final data = _generateMockChartData();
      chartData.value = data;

      print('📈 Loaded chart data: ${data.length} data points');
    } catch (e) {
      print('❌ Error loading chart data: $e');
    } finally {
      isLoadingChart.value = false;
    }
  }

  /// Generate mock chart data for demonstration
  List<Map<String, dynamic>> _generateMockChartData() {
    final now = DateTime.now();
    final data = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      data.add({
        'date': date.toIso8601String().split('T')[0],
        'fraudDetected': (5 + (i * 2) + (i % 3)).toDouble(),
        'totalAnalyses': (50 + (i * 10) + (i % 7)).toDouble(),
        'fraudRate':
            ((5 + (i * 2) + (i % 3)) / (50 + (i * 10) + (i % 7)) * 100),
      });
    }

    return data;
  }

  /// Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([loadDetailedStats(), loadChartData()]);

    Get.snackbar(
      'Data Refreshed',
      'All statistics have been updated successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Change time range filter
  void changeTimeRange(String newRange) {
    selectedTimeRange.value = newRange;
    loadDetailedStats();
    loadChartData();
  }

  /// Export statistics data
  void exportStats() {
    Get.snackbar(
      'Export Feature',
      'Statistics export functionality coming soon!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF7C3AED).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Navigate back to home
  void goBack() {
    Get.back();
  }
}
