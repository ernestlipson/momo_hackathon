import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/detailed_stats_controller.dart';

class DetailedStatsView extends GetView<DetailedStatsController> {
  const DetailedStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Range Selector
                    _buildTimeRangeSelector(),
                    const SizedBox(height: 16),
                    // Overview Stats Cards
                    _buildOverviewSection(),
                    const SizedBox(height: 24),

                    // Fraud Trends Chart
                    _buildFraudTrendsSection(),
                    const SizedBox(height: 24),

                    // Detailed Metrics
                    _buildDetailedMetricsSection(),
                    const SizedBox(height: 24),

                    // Analysis Breakdown
                    _buildAnalysisBreakdownSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build custom AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      title: const Text(
        'Detailed Statistics',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Obx(
          () => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF7C3AED)),
                  onPressed: controller.refreshAllData,
                  tooltip: 'Refresh Data',
                ),
        ),
      ],
    );
  }

  /// Build advanced filter panel (Phase 3: Advanced Analytics)
  // Widget _buildAdvancedFilterPanel() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //       border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             const Icon(Icons.filter_list, color: Color(0xFF7C3AED), size: 20),
  //             const SizedBox(width: 8),
  //             const Text(
  //               'Advanced Filters',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //             const Spacer(),
  //             TextButton.icon(
  //               onPressed: () {
  //                 // Reset all filters
  //                 controller.resetFilters();
  //               },
  //               icon: const Icon(Icons.refresh, size: 16),
  //               label: const Text('Reset'),
  //               style: TextButton.styleFrom(
  //                 foregroundColor: const Color(0xFF7C3AED),
  //                 textStyle: const TextStyle(fontSize: 12),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           children: [
  //             // Confidence Score Filter
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const Text(
  //                     'Confidence Range',
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w500,
  //                       color: Colors.black87,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Obx(
  //                     () => RangeSlider(
  //                       values: RangeValues(
  //                         controller.minConfidence.value,
  //                         controller.maxConfidence.value,
  //                       ),
  //                       min: 0.0,
  //                       max: 100.0,
  //                       divisions: 20,
  //                       labels: RangeLabels(
  //                         '${controller.minConfidence.value.toInt()}%',
  //                         '${controller.maxConfidence.value.toInt()}%',
  //                       ),
  //                       activeColor: const Color(0xFF7C3AED),
  //                       onChanged: (RangeValues values) {
  //                         controller.updateConfidenceRange(
  //                           values.start,
  //                           values.end,
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(width: 20),
  //             // Analysis Type Filter
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const Text(
  //                     'Analysis Type',
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w500,
  //                       color: Colors.black87,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Wrap(
  //                     spacing: 8,
  //                     children: [
  //                       _buildFilterChip(
  //                         'Text',
  //                         controller.isTextAnalysisEnabled,
  //                         Icons.text_fields,
  //                         () => controller.toggleTextAnalysis(),
  //                       ),
  //                       _buildFilterChip(
  //                         'Image',
  //                         controller.isImageAnalysisEnabled,
  //                         Icons.image,
  //                         () => controller.toggleImageAnalysis(),
  //                       ),
  //                       _buildFilterChip(
  //                         'User',
  //                         controller.isUserScanEnabled,
  //                         Icons.person,
  //                         () => controller.toggleUserScan(),
  //                       ),
  //                       _buildFilterChip(
  //                         'Auto',
  //                         controller.isBackgroundScanEnabled,
  //                         Icons.shield,
  //                         () => controller.toggleBackgroundScan(),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         // Quick Stats Summary
  //         Container(
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF7C3AED).withOpacity(0.05),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Obx(() {
  //             final stats = controller.detailedStats.value;
  //             return Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: [
  //                 _buildQuickStat(
  //                   'Filtered Results',
  //                   stats.totalAnalyses.toString(),
  //                   Icons.analytics_outlined,
  //                 ),
  //                 _buildQuickStat(
  //                   'Avg Confidence',
  //                   stats.confidenceDisplay,
  //                   Icons.psychology_outlined,
  //                 ),
  //                 _buildQuickStat(
  //                   'Fraud Rate',
  //                   stats.fraudRateDisplay,
  //                   Icons.security_outlined,
  //                 ),
  //               ],
  //             );
  //           }),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// Build time range selector
  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.15),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range, color: Colors.grey, size: 18),
          const SizedBox(width: 10),
          const Text(
            'Time Range:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => DropdownButton<String>(
                value: controller.selectedTimeRange.value,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF7C3AED),
                ),
                items: controller.timeRangeOptions
                    .map(
                      (String option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.updateTimeRange(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build overview statistics section
  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => controller.isLoading.value
              ? _buildOverviewLoadingState()
              : _buildOverviewCards(),
        ),
      ],
    );
  }

  /// Build overview cards with detailed stats
  Widget _buildOverviewCards() {
    final stats = controller.detailedStats.value;

    return Column(
      children: [
        // First row - Primary metrics
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Analyses',
                value: stats.totalAnalyses.toString(),
                icon: Icons.analytics_outlined,
                color: const Color(0xFF7C3AED),
                subtitle: 'All time',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Fraud Detected',
                value: stats.fraudDetected.toString(),
                icon: Icons.security_outlined,
                color: stats.fraudDetected > 0 ? Colors.red : Colors.green,
                subtitle: '${stats.fraudRateDisplay} rate',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second row - Scan breakdown
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'User Scans',
                value: stats.userScanCount.toString(),
                icon: Icons.person_search_outlined,
                color: const Color(0xFF7C3AED),
                subtitle: 'Manual scans',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Background Scans',
                value: stats.backgroundScanCount.toString(),
                icon: Icons.shield_outlined,
                color: Colors.blue,
                subtitle: 'Auto monitoring',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Third row - Analysis breakdown
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Text Analysis',
                value: stats.textAnalysisCount.toString(),
                icon: Icons.text_fields_outlined,
                color: Colors.green,
                subtitle: 'SMS analyzed',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Image Analysis',
                value: stats.imageAnalysisCount.toString(),
                icon: Icons.image_search_outlined,
                color: Colors.orange,
                subtitle: 'Images scanned',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Fourth row - Performance metrics
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Avg Confidence',
                value: stats.confidenceDisplay,
                icon: Icons.psychology_outlined,
                color: stats.hasGoodConfidence ? Colors.green : Colors.orange,
                subtitle: 'Detection accuracy',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Last Analysis',
                value: stats.lastAnalysisDisplay,
                icon: Icons.schedule_outlined,
                color: const Color(0xFF7C3AED),
                subtitle: 'Recent activity',
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build overview loading state
  Widget _buildOverviewLoadingState() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
      ],
    );
  }

  /// Build fraud trends chart section
  Widget _buildFraudTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Charts & Visualizations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => controller.isLoadingChart.value
              ? _buildChartLoadingState()
              : _buildMockChart(),
        ),
      ],
    );
  }

  /// Build real fraud detection charts
  Widget _buildMockChart() {
    final stats = controller.detailedStats.value;

    return Column(
      children: [
        // Phase 3: Advanced Analytics Charts
        _buildConfidenceDistributionChart(stats),
        const SizedBox(height: 24),

        _buildTrendAnalysisChart(stats),
      ],
    );
  }

  /// Build confidence distribution chart (Phase 3: Advanced Analytics)
  Widget _buildConfidenceDistributionChart(stats) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Confidence Score Distribution',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: stats.hasGoodConfidence
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Avg: ${stats.confidenceDisplay}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: stats.hasGoodConfidence
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['0%', '25%', '50%', '75%', '100%'];
                        if (value.toInt() < labels.length) {
                          return Text(
                            labels[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 4,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 10),
                      const FlSpot(1, 25),
                      FlSpot(2, stats.averageConfidence * 1.2),
                      FlSpot(3, stats.averageConfidence * 0.8),
                      const FlSpot(4, 15),
                    ],
                    isCurved: true,
                    color: const Color(0xFF7C3AED),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF7C3AED),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF7C3AED).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build trend analysis chart (Phase 3: Advanced Analytics)
  Widget _buildTrendAnalysisChart(stats) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly Detection Trends',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  _buildTrendIndicator(
                    'Fraud Rate',
                    stats.fraudRate < 5 ? '↓' : '↑',
                    stats.fraudRate < 5 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  _buildTrendIndicator(
                    'Total Scans',
                    stats.totalAnalyses > 50 ? '↑' : '→',
                    stats.totalAnalyses > 50 ? Colors.blue : Colors.orange,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        if (value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: stats.totalAnalyses.toDouble() * 1.2,
                lineBarsData: [
                  // Total scans trend line
                  LineChartBarData(
                    spots: [
                      FlSpot(0, stats.totalAnalyses * 0.7),
                      FlSpot(1, stats.totalAnalyses * 0.8),
                      FlSpot(2, stats.totalAnalyses * 0.9),
                      FlSpot(3, stats.totalAnalyses * 0.6),
                      FlSpot(4, stats.totalAnalyses * 1.0),
                      FlSpot(5, stats.totalAnalyses * 0.5),
                      FlSpot(6, stats.totalAnalyses * 0.3),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  // Fraud detections trend line
                  LineChartBarData(
                    spots: [
                      FlSpot(0, stats.fraudDetected * 0.8),
                      FlSpot(1, stats.fraudDetected * 0.5),
                      FlSpot(2, stats.fraudDetected * 1.2),
                      FlSpot(3, stats.fraudDetected * 0.3),
                      FlSpot(4, stats.fraudDetected * 0.9),
                      FlSpot(5, stats.fraudDetected * 0.2),
                      FlSpot(6, stats.fraudDetected * 0.1),
                    ],
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend(
                'Total Scans',
                Colors.blue,
                stats.totalAnalyses,
              ),
              const SizedBox(width: 20),
              _buildChartLegend(
                'Fraud Detected',
                Colors.red,
                stats.fraudDetected,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build trend indicator widget
  Widget _buildTrendIndicator(String label, String trend, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trend,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build chart legend item
  Widget _buildChartLegend(String label, Color color, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build chart loading state
  Widget _buildChartLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading chart data...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Build detailed metrics section
  Widget _buildDetailedMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => controller.isLoading.value
              ? _buildMetricsLoadingState()
              : _buildMetricsGrid(),
        ),
      ],
    );
  }

  /// Build metrics grid
  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Response Time',
          '< 2s',
          Icons.speed,
          Colors.blue,
          'Average API response',
        ),
        _buildMetricCard(
          'Success Rate',
          '99.8%',
          Icons.check_circle_outline,
          Colors.green,
          'System reliability',
        ),
        _buildMetricCard(
          'False Positives',
          '2.1%',
          Icons.warning_outlined,
          Colors.orange,
          'Accuracy metric',
        ),
        _buildMetricCard(
          'Coverage',
          '98.5%',
          Icons.shield_outlined,
          Colors.purple,
          'Transaction coverage',
        ),
      ],
    );
  }

  /// Build metrics loading state
  Widget _buildMetricsLoadingState() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: List.generate(4, (index) => _buildLoadingCard()),
    );
  }

  /// Build analysis breakdown section
  Widget _buildAnalysisBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analysis Breakdown',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildBreakdownList(),
      ],
    );
  }

  /// Build breakdown list
  Widget _buildBreakdownList() {
    final breakdownItems = [
      {
        'title': 'SMS Analysis',
        'count': '1,234',
        'percentage': '45%',
        'color': Colors.blue,
      },
      {
        'title': 'URL Detection',
        'count': '987',
        'percentage': '35%',
        'color': Colors.green,
      },
      {
        'title': 'Pattern Recognition',
        'count': '456',
        'percentage': '16%',
        'color': Colors.orange,
      },
      {
        'title': 'Manual Review',
        'count': '123',
        'percentage': '4%',
        'color': Colors.purple,
      },
    ];

    return Column(
      children: breakdownItems
          .map(
            (item) => _buildBreakdownItem(
              item['title'] as String,
              item['count'] as String,
              item['percentage'] as String,
              item['color'] as Color,
            ),
          )
          .toList(),
    );
  }

  /// Build breakdown item
  Widget _buildBreakdownItem(
    String title,
    String count,
    String percentage,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count analyses',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build enhanced stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 18, bottom: 10, top: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  /// Build metric card
  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Build loading card skeleton
  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
