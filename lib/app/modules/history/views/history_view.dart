import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/history_controller.dart';
import 'package:momo_hackathon/app/data/models/scan_history.dart';

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
                        IconButton(
                          onPressed: controller.clearHistory,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFF7C3AED),
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // History List
                    Obx(() {
                      if (controller.isLoading.value) {
                        return _buildLoadingState();
                      }

                      if (controller.scanHistories.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Column(
                        children: controller.scanHistories
                            .map((scan) => _buildScanHistoryCard(scan))
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/sms-scanner'),
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 8,
        child: const Icon(Icons.scanner, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
              'Loading scan history...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
            Icon(Icons.security_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No scan history yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start scanning SMS messages to see your fraud detection history',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanHistoryCard(ScanHistory scan) {
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
          color: _getRiskColor(scan.overallRiskLevel).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => controller.viewScanDetails(scan),
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
                          color: _getRiskColor(
                            scan.overallRiskLevel,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          scan.scanTypeDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getRiskColor(scan.overallRiskLevel),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _getScanIcon(scan.scanType),
                        size: 20,
                        color: const Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                  Text(
                    scan.formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Statistics Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatColumn(
                      'Messages Scanned',
                      '${scan.totalMessagesScanned}',
                      Icons.sms_outlined,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      'Fraud Detected',
                      '${scan.fraudDetected}',
                      Icons.warning_outlined,
                      scan.fraudDetected > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      'Safety Score',
                      '${scan.safetyScore.toStringAsFixed(0)}%',
                      Icons.shield_outlined,
                      _getSafetyScoreColor(scan.safetyScore),
                    ),
                  ),
                ],
              ),

              if (scan.fraudDetected > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${scan.fraudDetected} fraud${scan.fraudDetected > 1 ? 's' : ''} detected - Tap to view details',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
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

  Color _getRiskColor(dynamic riskLevel) {
    switch (riskLevel.toString()) {
      case 'FraudRiskLevel.critical':
        return Colors.red.shade700;
      case 'FraudRiskLevel.high':
        return Colors.red;
      case 'FraudRiskLevel.medium':
        return Colors.orange;
      case 'FraudRiskLevel.low':
      default:
        return Colors.green;
    }
  }

  Color _getSafetyScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.orange;
    return Colors.red;
  }

  IconData _getScanIcon(String scanType) {
    switch (scanType) {
      case 'manual':
        return Icons.touch_app;
      case 'background':
        return Icons.autorenew;
      case 'scheduled':
        return Icons.schedule;
      default:
        return Icons.scanner;
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
