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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Range Selector
                    _buildTimeRangeSelector(),
                    const SizedBox(height: 24),

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

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build custom AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        onPressed: controller.goBack,
      ),
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

  /// Build time range selector
  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range, color: Color(0xFF7C3AED), size: 20),
          const SizedBox(width: 12),
          const Text(
            'Time Range:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 16),
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
                    controller.changeTimeRange(newValue);
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
            fontSize: 20,
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
        // Second row - Performance metrics
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Amount Saved',
                value: '\$${stats.amountSaved.toStringAsFixed(2)}',
                icon: Icons.savings_outlined,
                color: Colors.green,
                subtitle: 'Protected funds',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Avg Confidence',
                value: stats.confidenceDisplay,
                icon: Icons.psychology_outlined,
                color: stats.hasGoodConfidence ? Colors.green : Colors.orange,
                subtitle: 'Detection accuracy',
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
          'Fraud Detection Trends',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
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
          child: Obx(
            () => controller.isLoadingChart.value
                ? _buildChartLoadingState()
                : _buildMockChart(),
          ),
        ),
      ],
    );
  }

  /// Build mock chart (placeholder for real chart implementation)
  Widget _buildMockChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weekly Fraud Detection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_down, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '↓ 15%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar('Mon', 0.7, Colors.green),
              _buildChartBar('Tue', 0.4, Colors.green),
              _buildChartBar('Wed', 0.9, Colors.orange),
              _buildChartBar('Thu', 0.3, Colors.green),
              _buildChartBar('Fri', 0.6, Colors.orange),
              _buildChartBar('Sat', 0.2, Colors.green),
              _buildChartBar('Sun', 0.1, Colors.green),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildLegendItem('Low Risk', Colors.green),
            const SizedBox(width: 16),
            _buildLegendItem('Medium Risk', Colors.orange),
            const SizedBox(width: 16),
            _buildLegendItem('High Risk', Colors.red),
          ],
        ),
      ],
    );
  }

  /// Build chart bar for mock chart
  Widget _buildChartBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height * 120,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /// Build legend item
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
            fontSize: 20,
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

  /// Build action buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.exportStats,
            icon: const Icon(Icons.download_outlined),
            label: const Text('Export Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.refreshAllData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7C3AED),
              side: const BorderSide(color: Color(0xFF7C3AED)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(20),
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
                    fontSize: 14,
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
              fontSize: 24,
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
                    fontSize: 13,
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
              fontSize: 20,
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
