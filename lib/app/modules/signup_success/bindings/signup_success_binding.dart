import 'package:get/get.dart';
import '../controllers/signup_success_controller.dart';

class SignupSuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupSuccessController>(() => SignupSuccessController());
  }
}
