import 'package:get/get.dart';
import '../controllers/main_navigation_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../history/controllers/history_controller.dart';
import '../../settings/controllers/settings_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    // Put the main navigation controller
    Get.put<MainNavigationController>(MainNavigationController());

    // Lazily put all tab controllers to ensure they're available when needed
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<HistoryController>(() => HistoryController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
