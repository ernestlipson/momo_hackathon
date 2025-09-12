import 'package:get/get.dart';
import '../controllers/fraud_messages_controller.dart';

class FraudMessagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FraudMessagesController>(() => FraudMessagesController());
  }
}
