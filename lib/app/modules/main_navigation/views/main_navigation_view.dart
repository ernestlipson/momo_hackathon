import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_navigation_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/views/home_view.dart';
import '../../history/views/history_view.dart';
import '../../settings/views/settings_view.dart';

class MainNavigationView extends GetView<MainNavigationController> {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => IndexedStack(
          index: controller.selectedNavIndex.value,
          children: const [HomeView(), HistoryView(), SettingsView()],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: Obx(
        () => controller.selectedNavIndex.value == 0
            ? FloatingActionButton(
                onPressed: () {
                  try {
                    final homeController = Get.find<HomeController>();
                    homeController.onScanButtonPressed();
                  } catch (e) {
                    print('Error accessing HomeController: $e');
                    Get.toNamed('/sms-scanner');
                  }
                },
                backgroundColor: const Color(0xFF7C3AED),
                elevation: 8,
                child: const Icon(Icons.scanner, color: Colors.white, size: 28),
              )
            : const SizedBox.shrink(),
      ),
    );
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
