import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momo_hackathon/app/data/models/recent_analysis.dart';

import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'History',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: controller.refreshHistoryData,
                              icon: const Icon(
                                Icons.refresh,
                                color: Color(0xFF7C3AED),
                                size: 28,
                              ),
                              tooltip: 'Refresh History',
                            ),
                            IconButton(
                              onPressed: controller.clearHistory,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFF7C3AED),
                                size: 28,
                              ),
                              tooltip: 'Clear History',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // History List
                    Obx(() {
                      if (controller.isLoading.value) {
                        return _buildLoadingState();
                      }

                      if (controller.recentAnalyses.isEmpty &&
                          controller.errorMessage.value != null) {
                        return _buildErrorState();
                      }

                      if (controller.recentAnalyses.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Column(
                        children: [
                          // Total count header
                          if (controller.totalAnalyses.value > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                'Total Analyses: ${controller.totalAnalyses.value}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ...controller.recentAnalyses.map(
                            (analysis) => _buildAnalysisCard(analysis),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 100.0),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading recent analyses...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Unable to load analyses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.refreshHistoryData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100.0),
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No analyses yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start analyzing messages to see your fraud detection history',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(RecentAnalysis analysis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _getStatusColor(analysis.status).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => controller.viewAnalysisDetails(analysis),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            analysis.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          analysis.statusDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(analysis.status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _getTypeIcon(analysis.analysisType),
                        size: 20,
                        color: const Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                  Text(
                    analysis.formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Main Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatColumn(
                      'Confidence',
                      analysis.confidenceDisplay,
                      Icons.percent_outlined,
                      _getConfidenceColor(analysis.confidence),
                    ),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      'Source',
                      analysis.sourceDisplay,
                      Icons.source_outlined,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      'Type',
                      analysis.typeDisplay,
                      Icons.category_outlined,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              // Risk Factors Section
              if (analysis.riskFactors.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(analysis.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(analysis.status).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_outlined,
                            color: _getStatusColor(analysis.status),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Risk Factors (${analysis.riskFactors.length})',
                            style: TextStyle(
                              color: _getStatusColor(analysis.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (analysis.riskFactors.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          analysis.riskFactors.take(2).join(', '),
                          style: TextStyle(
                            color: _getStatusColor(analysis.status),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'FRAUD':
        return Colors.red;
      case 'SUSPICIOUS':
        return Colors.orange;
      case 'LEGITIMATE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 90) return Colors.red;
    if (confidence >= 70) return Colors.orange;
    if (confidence >= 50) return Colors.yellow.shade700;
    return Colors.green;
  }

  IconData _getTypeIcon(String analysisType) {
    switch (analysisType.toUpperCase()) {
      case 'TEXT':
        return Icons.sms_outlined;
      case 'IMAGE':
        return Icons.image_outlined;
      case 'VOICE':
        return Icons.mic_outlined;
      default:
        return Icons.analytics_outlined;
    }
  }
}
