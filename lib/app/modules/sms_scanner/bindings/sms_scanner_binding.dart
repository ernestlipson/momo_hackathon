import 'package:get/get.dart';
import '../../../data/services/fraud_detection_service.dart';
import '../controllers/sms_scanner_controller.dart';

class SmsScannerBinding extends Bindings {
  @override
  void dependencies() {
    // Register fraud detection service
    Get.lazyPut<FraudDetectionService>(() => FraudDetectionService());

    // Register SMS scanner controller
    Get.lazyPut<SmsScannerController>(() => SmsScannerController());
  }
}
