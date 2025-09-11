import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/sms_scanner_controller.dart';
import '../../../data/models/fraud_result.dart';

class SmsScannerView extends GetView<SmsScannerController> {
  const SmsScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SMS Fraud Scanner',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF7C3AED)),
      ),
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
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 32),

                    // Permission Status
                    _buildPermissionStatus(),
                    const SizedBox(height: 24),

                    // Statistics Cards
                    _buildStatisticsCards(),
                    const SizedBox(height: 24),

                    // Scan Control
                    _buildScanControl(),
                    const SizedBox(height: 32),

                    // Recent Results
                    _buildRecentResults(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'SMS Scanner',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF7C3AED)),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: controller.clearAllData,
              child: const Row(
                children: [
                  Icon(Icons.clear_all, size: 20),
                  SizedBox(width: 8),
                  Text('Clear Data'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPermissionStatus() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: controller.hasPermission.value
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: controller.hasPermission.value
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  controller.hasPermission.value
                      ? Icons.check_circle
                      : Icons.warning,
                  color: controller.hasPermission.value ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.hasPermission.value
                            ? 'SMS Permission Granted'
                            : 'SMS Permission Required',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: controller.hasPermission.value
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.hasPermission.value
                            ? 'Fraud detection is active'
                            : 'Grant permission to enable fraud detection',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (!controller.hasPermission.value)
                  ElevatedButton(
                    onPressed: controller.requestPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Grant', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            // Background monitoring status
            if (controller.hasPermission.value) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    controller.backgroundMonitoringEnabled.value
                        ? Icons.monitor_outlined
                        : Icons.monitor_outlined,
                    color: controller.backgroundMonitoringEnabled.value 
                        ? Colors.blue : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.backgroundMonitoringEnabled.value
                          ? 'Background monitoring active'
                          : 'Background monitoring disabled',
                      style: TextStyle(
                        fontSize: 12, 
                        color: controller.backgroundMonitoringEnabled.value
                            ? Colors.blue[700]
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  Switch(
                    value: controller.backgroundMonitoringEnabled.value,
                    onChanged: (_) => controller.toggleBackgroundMonitoring(),
                    activeColor: const Color(0xFF7C3AED),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Messages Scanned',
              value: controller.totalScanned.value.toString(),
              icon: Icons.message,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Fraud Detected',
              value: controller.fraudDetected.value.toString(),
              icon: Icons.warning,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanControl() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fraud Detection Control',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Scan: ${controller.lastScanTimeFormatted}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Analysis: API + Local fallback',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 8),
                      if (controller.isScanning.value ||
                          controller.isAnalyzing.value) ...[
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.isAnalyzing.value
                                  ? 'Analyzing messages...'
                                  : 'Scanning messages...',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Text(
                          'Ready to scan',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      controller.hasPermission.value &&
                          !controller.isScanning.value
                      ? controller.scanRecentMessages
                      : null,
                  icon: const Icon(Icons.search, size: 20),
                  label: const Text('Scan Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Analysis',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.fraudResults.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: controller.fraudResults
                .take(10) // Show last 10 results
                .map((result) => _buildResultCard(result))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          children: [
            Icon(Icons.scanner, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No messages scanned yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the scan button to analyze your SMS messages',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(FraudResult result) {
    final message = controller.scannedMessages.firstWhereOrNull(
      (msg) => msg.id == result.messageId,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.isFraud
            ? Colors.red.withOpacity(0.05)
            : Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isFraud
              ? Colors.red.withOpacity(0.2)
              : Colors.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  message?.sender ?? 'Unknown Sender',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRiskColor(result.riskLevel),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result.riskLevelText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (message != null) ...[
            Text(
              message.body,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confidence: ${(result.confidenceScore * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                DateFormat('MMM dd, HH:mm').format(result.analyzedAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          if (result.redFlags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: result.redFlags
                  .take(3)
                  .map(
                    (flag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        flag,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRiskColor(FraudRiskLevel level) {
    switch (level) {
      case FraudRiskLevel.low:
        return Colors.green;
      case FraudRiskLevel.medium:
        return Colors.orange;
      case FraudRiskLevel.high:
        return Colors.red;
      case FraudRiskLevel.critical:
        return Colors.purple;
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedNavIndex.value,
          onTap: controller.onNavItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF7C3AED),
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
