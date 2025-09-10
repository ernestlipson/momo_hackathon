import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  // Observable for selected tab index
  final selectedNavIndex = 0.obs;

  // Page titles for each tab
  final List<String> pageTitles = ['Home', 'History', 'Settings'];

  /// Handle navigation item tap
  void onNavItemTapped(int index) {
    selectedNavIndex.value = index;
  }

  /// Get current page title
  String get currentPageTitle => pageTitles[selectedNavIndex.value];

  @override
  void onInit() {
    super.onInit();
    // Initialize with home tab selected
    selectedNavIndex.value = 0;
  }
}
