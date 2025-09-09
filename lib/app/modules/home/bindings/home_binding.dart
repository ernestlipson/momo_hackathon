import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'package:momo_hackathon/app/data/services/news_service.dart';
import 'package:momo_hackathon/app/data/services/fraud_detection_service.dart';
import 'package:momo_hackathon/app/data/services/network/base_network_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure network service is available (fallback if not already registered)
    if (!Get.isRegistered<BaseNetworkService>()) {
      Get.put<BaseNetworkService>(BaseNetworkService(), permanent: true);
    }

    // Ensure fraud detection service is available (fallback if not already registered)
    if (!Get.isRegistered<FraudDetectionService>()) {
      Get.put<FraudDetectionService>(FraudDetectionService(), permanent: true);
    }

    // Register news service
    Get.lazyPut<NewsService>(() => NewsService());

    // Register home controller
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
