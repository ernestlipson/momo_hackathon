import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:momo_hackathon/app/data/models/fraud_detection_stats.dart';
import 'package:momo_hackathon/app/data/services/fraud_detection_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

  // Phase 3: Advanced Filter Properties
  final minConfidence = 0.0.obs;
  final maxConfidence = 100.0.obs;
  final isTextAnalysisEnabled = true.obs;
  final isImageAnalysisEnabled = true.obs;
  final isUserScanEnabled = true.obs;
  final isBackgroundScanEnabled = true.obs;

  // Phase 4: Export & Reporting Properties (PDF-only)
  final isExporting = false.obs;
  final exportProgress = 0.0.obs;
  final includeCharts = true.obs;
  final includeDetailedBreakdown = true.obs;
  final includeTimeRange = true.obs;
  final selectedReportTemplate = 'Standard'.obs;
  final reportTemplates = [
    'Standard',
    'Executive Summary',
    'Technical Details',
    'Security Audit',
  ].obs;

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
      await Future.delayed(const Duration(milliseconds: 800));

      chartData.value = [
        {'day': 'Mon', 'fraud': 12, 'clean': 188},
        {'day': 'Tue', 'fraud': 8, 'clean': 192},
        {'day': 'Wed', 'fraud': 15, 'clean': 185},
        {'day': 'Thu', 'fraud': 6, 'clean': 194},
        {'day': 'Fri', 'fraud': 11, 'clean': 189},
        {'day': 'Sat', 'fraud': 9, 'clean': 191},
        {'day': 'Sun', 'fraud': 7, 'clean': 193},
      ];

      print('📈 Chart data loaded successfully');
    } catch (e) {
      print('❌ Error loading chart data: $e');
    } finally {
      isLoadingChart.value = false;
    }
  }

  /// Filter stats by confidence range (Phase 3)
  void filterByConfidence(double min, double max) {
    minConfidence.value = min;
    maxConfidence.value = max;
    // Trigger filtered data load
    loadDetailedStats();
    print('🔍 Filtering by confidence: $min% - $max%');
  }

  /// Filter by analysis type (Phase 3)
  void toggleAnalysisType(String type, bool enabled) {
    switch (type) {
      case 'text':
        isTextAnalysisEnabled.value = enabled;
        break;
      case 'image':
        isImageAnalysisEnabled.value = enabled;
        break;
      case 'user':
        isUserScanEnabled.value = enabled;
        break;
      case 'background':
        isBackgroundScanEnabled.value = enabled;
        break;
    }
    // Trigger filtered data load
    loadDetailedStats();
    print('🔧 Toggled $type analysis: $enabled');
  }

  /// Update time range
  void updateTimeRange(String range) {
    selectedTimeRange.value = range;
    loadDetailedStats();
    loadChartData();
    print('📅 Time range updated to: $range');
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

  /// Reset all filters to default values
  void resetFilters() {
    minConfidence.value = 0.0;
    maxConfidence.value = 100.0;
    isTextAnalysisEnabled.value = true;
    isImageAnalysisEnabled.value = true;
    isUserScanEnabled.value = true;
    isBackgroundScanEnabled.value = true;
    selectedTimeRange.value = 'Last 30 Days';

    // Reload data with default filters
    refreshAllData();

    Get.snackbar(
      'Filters Reset',
      'All filters have been reset to default values',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Export statistics data as PDF (Phase 4: Enhanced PDF Export)
  Future<void> exportStats() async {
    try {
      isExporting.value = true;
      exportProgress.value = 0.0;

      exportProgress.value = 0.2;
      await Future.delayed(const Duration(milliseconds: 500));

      // Generate PDF export data
      final exportData = _generatePdfExport();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'fraud_detection_report_${selectedReportTemplate.value.toLowerCase().replaceAll(' ', '_')}_$timestamp.pdf';

      exportProgress.value = 0.6;
      await Future.delayed(const Duration(milliseconds: 500));

      // Save file to device
      await _saveExportFile(exportData, fileName);

      exportProgress.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 500));

      // Show success message
      Get.snackbar(
        'PDF Export Successful! 📊',
        'Report saved as $fileName',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'PDF Export Failed',
        'Error exporting PDF report: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isExporting.value = false;
      exportProgress.value = 0.0;
    }
  }

  /// Generate PDF export data
  String _generatePdfExport() {
    final stats = detailedStats.value;
    final cleanTransactions = stats.totalAnalyses - stats.fraudDetected;

    // Generate comprehensive PDF content (simulated as text for now)
    final buffer = StringBuffer();

    // Header
    buffer.writeln('FRAUD DETECTION REPORT');
    buffer.writeln('Generated: ${DateTime.now().toString()}');
    buffer.writeln('Template: ${selectedReportTemplate.value}');
    buffer.writeln('Time Range: ${selectedTimeRange.value}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    // Executive Summary
    buffer.writeln('EXECUTIVE SUMMARY');
    buffer.writeln('-' * 20);
    buffer.writeln('Total Analyses: ${stats.totalAnalyses}');
    buffer.writeln('Fraud Detected: ${stats.fraudDetected}');
    buffer.writeln('Fraud Rate: ${stats.fraudRate.toStringAsFixed(2)}%');
    buffer.writeln('Clean Transactions: $cleanTransactions');
    buffer.writeln(
      'Average Confidence: ${stats.averageConfidence.toStringAsFixed(2)}%',
    );
    buffer.writeln();

    // Breakdown by Analysis Type
    buffer.writeln('ANALYSIS BREAKDOWN');
    buffer.writeln('-' * 20);
    buffer.writeln('Text Analysis: ${stats.textAnalysisCount}');
    buffer.writeln('Image Analysis: ${stats.imageAnalysisCount}');
    buffer.writeln('User Scan: ${stats.userScanCount}');
    buffer.writeln('Background Scan: ${stats.backgroundScanCount}');
    buffer.writeln();

    // Risk Distribution (calculated from available data)
    buffer.writeln('ANALYSIS DISTRIBUTION');
    buffer.writeln('-' * 21);
    final textPercent = (stats.textAnalysisCount / stats.totalAnalyses * 100)
        .toStringAsFixed(1);
    final imagePercent = (stats.imageAnalysisCount / stats.totalAnalyses * 100)
        .toStringAsFixed(1);
    final userPercent = (stats.userScanCount / stats.totalAnalyses * 100)
        .toStringAsFixed(1);
    final backgroundPercent =
        (stats.backgroundScanCount / stats.totalAnalyses * 100).toStringAsFixed(
          1,
        );

    buffer.writeln('Text Analysis: $textPercent%');
    buffer.writeln('Image Analysis: $imagePercent%');
    buffer.writeln('User Scans: $userPercent%');
    buffer.writeln('Background Scans: $backgroundPercent%');
    buffer.writeln();

    if (includeCharts.value) {
      buffer.writeln('CHARTS & VISUALIZATIONS');
      buffer.writeln('-' * 25);
      buffer.writeln(
        '[Chart Data - Visual representations would be embedded here]',
      );
      buffer.writeln();
    }

    if (includeDetailedBreakdown.value) {
      buffer.writeln('DETAILED ANALYSIS');
      buffer.writeln('-' * 18);
      buffer.writeln('Performance Metrics:');
      buffer.writeln(
        '- Average Confidence Score: ${stats.averageConfidence.toStringAsFixed(2)}%',
      );
      buffer.writeln(
        '- Detection Accuracy: ${stats.averageConfidence.toStringAsFixed(2)}%',
      );
      buffer.writeln(
        '- Clean Transaction Rate: ${(100 - stats.fraudRate).toStringAsFixed(2)}%',
      );
      buffer.writeln(
        '- Last Analysis: ${stats.lastAnalysisAt?.toString() ?? 'N/A'}',
      );
      buffer.writeln();
    }

    if (includeTimeRange.value) {
      buffer.writeln('TIME RANGE ANALYSIS');
      buffer.writeln('-' * 20);
      buffer.writeln('Data Period: ${selectedTimeRange.value}');
      buffer.writeln(
        'Trend Analysis: [Historical trend data would be included here]',
      );
      buffer.writeln();
    }

    // Footer
    buffer.writeln('=' * 50);
    buffer.writeln('Report generated by MoMo Fraud Detection System');
    buffer.writeln('Confidential - For Internal Use Only');

    return buffer.toString();
  }

  /// Save export file to device storage
  Future<void> _saveExportFile(String content, String fileName) async {
    try {
      // Get appropriate directory based on platform
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        throw Exception('Unable to access storage directory');
      }

      // Create the file
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(content);

      print('📁 File saved successfully: $filePath');
    } catch (e) {
      print('❌ Error saving file: $e');
      rethrow;
    }
  }

  /// Navigate back to home
  void goBack() {
    Get.back();
  }
}
