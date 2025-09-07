import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'package:momo_hackathon/app/data/services/news_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register news service
    Get.lazyPut<NewsService>(() => NewsService());

    // Register home controller
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
