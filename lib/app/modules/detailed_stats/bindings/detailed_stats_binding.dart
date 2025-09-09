import 'package:get/get.dart';
import '../controllers/detailed_stats_controller.dart';

class DetailedStatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailedStatsController>(() => DetailedStatsController());
  }
}
