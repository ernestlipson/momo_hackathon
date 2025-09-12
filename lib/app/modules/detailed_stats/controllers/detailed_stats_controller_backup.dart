// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:momo_hackathon/app/data/models/fraud_detection_stats.dart';
// import 'package:momo_hackathon/app/data/services/fraud_detection_service.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:csv/csv.dart';

// class DetailedStatsController extends GetxController {
//   // Services
//   final FraudDetectionService _fraudService = Get.find<FraudDetectionService>();

//   // Observable variables for detailed stats
//   final detailedStats = FraudDetectionStats.empty().obs;
//   final isLoading = false.obs;
//   final error = RxnString();

//   // Date range selection
//   final selectedTimeRange = 'Last 30 Days'.obs;
//   final timeRangeOptions = [
//     'Last 7 Days',
//     'Last 30 Days',
//     'Last 3 Months',
//     'Last 6 Months',
//     'Last Year',
//     'All Time',
//   ];

//   // Chart data observables
//   final chartData = <Map<String, dynamic>>[].obs;
//   final isLoadingChart = false.obs;

//   // Phase 3: Advanced Filter Properties
//   final minConfidence = 0.0.obs;
//   final maxConfidence = 100.0.obs;
//   final isTextAnalysisEnabled = true.obs;
//   final isImageAnalysisEnabled = true.obs;
//   final isUserScanEnabled = true.obs;
//   final isBackgroundScanEnabled = true.obs;

//   // Phase 4: Export & Reporting Properties (PDF-only)
//   final isExporting = false.obs;
//   final exportProgress = 0.0.obs;
//   final includeCharts = true.obs;
//   final includeDetailedBreakdown = true.obs;
//   final includeTimeRange = true.obs;
//   final selectedReportTemplate = 'Standard'.obs;
//   final reportTemplates = [
//     'Standard',
//     'Executive Summary',
//     'Technical Details',
//     'Security Audit',
//   ].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadDetailedStats();
//     loadChartData();
//   }

//   /// Load detailed fraud detection statistics
//   Future<void> loadDetailedStats() async {
//     try {
//       isLoading.value = true;
//       error.value = null;

//       final stats = await _fraudService.getStatsOverview();
//       detailedStats.value = stats!;

//       print(
//         '📊 Loaded detailed fraud detection statistics: ${stats.totalAnalyses} analyses',
//       );
//     } catch (e) {
//       print('❌ Error loading detailed stats: $e');
//       error.value = e.toString();

//       Get.snackbar(
//         'Statistics Loading Error',
//         'Unable to load detailed fraud detection statistics.',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.orange.withOpacity(0.8),
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Load chart data for visualizations
//   Future<void> loadChartData() async {
//     try {
//       isLoadingChart.value = true;

//       // Generate mock chart data - in real app this would come from the service
//       final data = _generateMockChartData();
//       chartData.value = data;

//       print('📈 Loaded chart data: ${data.length} data points');
//     } catch (e) {
//       print('❌ Error loading chart data: $e');
//     } finally {
//       isLoadingChart.value = false;
//     }
//   }

//   /// Generate mock chart data for demonstration
//   List<Map<String, dynamic>> _generateMockChartData() {
//     final now = DateTime.now();
//     final data = <Map<String, dynamic>>[];

//     for (int i = 6; i >= 0; i--) {
//       final date = now.subtract(Duration(days: i));
//       data.add({
//         'date': date.toIso8601String().split('T')[0],
//         'fraudDetected': (5 + (i * 2) + (i % 3)).toDouble(),
//         'totalAnalyses': (50 + (i * 10) + (i % 7)).toDouble(),
//         'fraudRate':
//             ((5 + (i * 2) + (i % 3)) / (50 + (i * 10) + (i % 7)) * 100),
//       });
//     }

//     return data;
//   }

//   /// Refresh all data
//   Future<void> refreshAllData() async {
//     await Future.wait([loadDetailedStats(), loadChartData()]);

//     Get.snackbar(
//       'Data Refreshed',
//       'All statistics have been updated successfully',
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.green.withOpacity(0.8),
//       colorText: Colors.white,
//       duration: const Duration(seconds: 2),
//     );
//   }

//   /// Change time range filter
//   void changeTimeRange(String newRange) {
//     selectedTimeRange.value = newRange;
//     loadDetailedStats();
//     loadChartData();
//   }

//   /// Phase 3: Advanced Filter Methods

//   /// Update confidence range filter
//   void updateConfidenceRange(double min, double max) {
//     minConfidence.value = min;
//     maxConfidence.value = max;
//     // Trigger data refresh with new filters
//     loadDetailedStats();
//   }

//   /// Toggle text analysis filter
//   void toggleTextAnalysis() {
//     isTextAnalysisEnabled.value = !isTextAnalysisEnabled.value;
//     loadDetailedStats();
//   }

//   /// Toggle image analysis filter
//   void toggleImageAnalysis() {
//     isImageAnalysisEnabled.value = !isImageAnalysisEnabled.value;
//     loadDetailedStats();
//   }

//   /// Toggle user scan filter
//   void toggleUserScan() {
//     isUserScanEnabled.value = !isUserScanEnabled.value;
//     loadDetailedStats();
//   }

//   /// Toggle background scan filter
//   void toggleBackgroundScan() {
//     isBackgroundScanEnabled.value = !isBackgroundScanEnabled.value;
//     loadDetailedStats();
//   }

//   /// Reset all filters to default values
//   void resetFilters() {
//     minConfidence.value = 0.0;
//     maxConfidence.value = 100.0;
//     isTextAnalysisEnabled.value = true;
//     isImageAnalysisEnabled.value = true;
//     isUserScanEnabled.value = true;
//     isBackgroundScanEnabled.value = true;
//     selectedTimeRange.value = 'Last 30 Days';

//     // Refresh data with reset filters
//     loadDetailedStats();

//     Get.snackbar(
//       'Filters Reset',
//       'All filters have been reset to default values',
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.green.withOpacity(0.8),
//       colorText: Colors.white,
//       duration: const Duration(seconds: 2),
//     );
//   }

//   /// Export statistics data as PDF (Phase 4: Enhanced PDF Export)
//   Future<void> exportStats() async {
//     try {
//       isExporting.value = true;
//       exportProgress.value = 0.0;

//       exportProgress.value = 0.2;
//       await Future.delayed(const Duration(milliseconds: 500));

//       // Generate PDF export data
//       final exportData = _generatePdfExport();
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final fileName = 'fraud_detection_report_${selectedReportTemplate.value.toLowerCase().replaceAll(' ', '_')}_$timestamp.pdf';

//       exportProgress.value = 0.6;
//       await Future.delayed(const Duration(milliseconds: 500));

//       // Save file to device
//       await _saveExportFile(exportData, fileName);

//       exportProgress.value = 1.0;
//       await Future.delayed(const Duration(milliseconds: 500));

//       // Show success message
//       Get.snackbar(
//         'PDF Export Successful! 📊',
//         'Report saved as $fileName',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.green.withOpacity(0.9),
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//         icon: const Icon(Icons.check_circle, color: Colors.white),
//       );
//     } catch (e) {
//       Get.snackbar(
//         'PDF Export Failed',
//         'Error exporting PDF report: $e',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red.withOpacity(0.9),
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//         icon: const Icon(Icons.error, color: Colors.white),
//       );
//     } finally {
//       isExporting.value = false;
//       exportProgress.value = 0.0;
//     }
//   }

//   /// Show export options dialog
//   Future<bool?> _showExportOptionsDialog() async {
//     return await Get.dialog<bool>(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.upload_file,
//                     color: Color(0xFF7C3AED),
//                     size: 24,
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Export Options',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: () => Get.back(result: false),
//                     icon: const Icon(Icons.close),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),

//               // Export Format Selection
//               const Text(
//                 'Export Format',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 8),
//               Obx(
//                 () => DropdownButtonFormField<String>(
//                   initialValue: selectedExportFormat.value,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                   items: exportFormats.map((format) {
//                     return DropdownMenuItem(
//                       value: format,
//                       child: Row(
//                         children: [
//                           Icon(_getFormatIcon(format), size: 20),
//                           const SizedBox(width: 8),
//                           Text(format),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (value) => selectedExportFormat.value = value!,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Report Template Selection
//               const Text(
//                 'Report Template',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 8),
//               Obx(
//                 () => DropdownButtonFormField<String>(
//                   initialValue: selectedReportTemplate.value,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                   items: reportTemplates.map((template) {
//                     return DropdownMenuItem(
//                       value: template,
//                       child: Text(template),
//                     );
//                   }).toList(),
//                   onChanged: (value) => selectedReportTemplate.value = value!,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Export Options
//               const Text(
//                 'Include in Export',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 8),
//               Obx(
//                 () => Column(
//                   children: [
//                     CheckboxListTile(
//                       title: const Text('Charts & Visualizations'),
//                       value: includeCharts.value,
//                       onChanged: (value) => includeCharts.value = value!,
//                       controlAffinity: ListTileControlAffinity.leading,
//                     ),
//                     CheckboxListTile(
//                       title: const Text('Detailed Breakdown'),
//                       value: includeDetailedBreakdown.value,
//                       onChanged: (value) =>
//                           includeDetailedBreakdown.value = value!,
//                       controlAffinity: ListTileControlAffinity.leading,
//                     ),
//                     CheckboxListTile(
//                       title: const Text('Time Range Data'),
//                       value: includeTimeRange.value,
//                       onChanged: (value) => includeTimeRange.value = value!,
//                       controlAffinity: ListTileControlAffinity.leading,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Action Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(result: false),
//                       child: const Text('Cancel'),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => Get.back(result: true),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF7C3AED),
//                         foregroundColor: Colors.white,
//                       ),
//                       child: const Text('Export'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// Get icon for export format
//   IconData _getFormatIcon(String format) {
//     switch (format) {
//       case 'JSON':
//         return Icons.code;
//       case 'CSV':
//         return Icons.table_chart;
//       case 'PDF':
//         return Icons.picture_as_pdf;
//       case 'Excel':
//         return Icons.file_present;
//       default:
//         return Icons.file_download;
//     }
//   }

//   /// Generate JSON export data
//   String _generateJsonExport() {
//     final stats = detailedStats.value;
//     final exportData = {
//       'export_info': {
//         'generated_at': DateTime.now().toIso8601String(),
//         'time_range': selectedTimeRange.value,
//         'report_template': selectedReportTemplate.value,
//         'export_format': selectedExportFormat.value,
//       },
//       'overview_statistics': {
//         'total_analyses': stats.totalAnalyses,
//         'fraud_detected': stats.fraudDetected,
//         'fraud_rate': stats.fraudRate,
//         'average_confidence': stats.averageConfidence,
//         'user_scan_count': stats.userScanCount,
//         'background_scan_count': stats.backgroundScanCount,
//         'text_analysis_count': stats.textAnalysisCount,
//         'image_analysis_count': stats.imageAnalysisCount,
//       },
//       if (includeDetailedBreakdown.value)
//         'detailed_breakdown': {
//           'sms_analysis': {'count': 1234, 'percentage': 45},
//           'url_detection': {'count': 987, 'percentage': 35},
//           'pattern_recognition': {'count': 456, 'percentage': 16},
//           'manual_review': {'count': 123, 'percentage': 4},
//         },
//       if (includeTimeRange.value)
//         'time_range_analysis': {
//           'start_date': DateTime.now()
//               .subtract(const Duration(days: 30))
//               .toIso8601String(),
//           'end_date': DateTime.now().toIso8601String(),
//           'period': selectedTimeRange.value,
//         },
//       'filters_applied': {
//         'confidence_range':
//             '${minConfidence.value.toInt()}% - ${maxConfidence.value.toInt()}%',
//         'text_analysis_enabled': isTextAnalysisEnabled.value,
//         'image_analysis_enabled': isImageAnalysisEnabled.value,
//         'user_scan_enabled': isUserScanEnabled.value,
//         'background_scan_enabled': isBackgroundScanEnabled.value,
//       },
//     };

//     return const JsonEncoder.withIndent('  ').convert(exportData);
//   }

//   /// Generate CSV export data
//   String _generateCsvExport() {
//     final stats = detailedStats.value;
//     final csvData = [
//       ['Metric', 'Value', 'Description'],
//       [
//         'Total Analyses',
//         stats.totalAnalyses.toString(),
//         'Total number of fraud detection analyses',
//       ],
//       [
//         'Fraud Detected',
//         stats.fraudDetected.toString(),
//         'Number of fraudulent activities detected',
//       ],
//       [
//         'Fraud Rate',
//         '${stats.fraudRate.toStringAsFixed(2)}%',
//         'Percentage of fraudulent analyses',
//       ],
//       [
//         'Average Confidence',
//         '${stats.averageConfidence.toStringAsFixed(1)}%',
//         'Average confidence score',
//       ],
//       [
//         'User Scans',
//         stats.userScanCount.toString(),
//         'Manual scans initiated by users',
//       ],
//       [
//         'Background Scans',
//         stats.backgroundScanCount.toString(),
//         'Automatic background scans',
//       ],
//       [
//         'Text Analyses',
//         stats.textAnalysisCount.toString(),
//         'SMS text analyses performed',
//       ],
//       [
//         'Image Analyses',
//         stats.imageAnalysisCount.toString(),
//         'Image analyses performed',
//       ],
//       [
//         'Time Range',
//         selectedTimeRange.value,
//         'Selected time period for analysis',
//       ],
//       [
//         'Export Date',
//         DateTime.now().toIso8601String(),
//         'Date and time of export',
//       ],
//     ];

//     // Use csv package for proper CSV generation
//     return const ListToCsvConverter().convert(csvData);
//   }

//   /// Generate PDF export data (placeholder)
//   String _generatePdfExport() {
//     return 'PDF export functionality will be implemented with full PDF generation library';
//   }

//   /// Generate Excel export data (placeholder)
//   String _generateExcelExport() {
//     return 'Excel export functionality will be implemented with Excel generation library';
//   }

//   /// Save export file to device
//   Future<void> _saveExportFile(String data, String fileName) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/$fileName');
//       await file.writeAsString(data);

//       // Copy to clipboard for easy sharing
//       await Clipboard.setData(ClipboardData(text: data));
//     } catch (e) {
//       throw Exception('Failed to save file: $e');
//     }
//   }

//   /// Navigate back to home
//   void goBack() {
//     Get.back();
//   }
// }
