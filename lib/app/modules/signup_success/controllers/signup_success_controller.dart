import 'dart:async';
import 'package:get/get.dart';

class SignupSuccessController extends GetxController {
  // Observable countdown value
  final countdown = 3.obs;
  final isCountdownActive = true.obs;

  // Timer for countdown
  Timer? _timer;

  // User data passed from signup
  late final String firstName;
  late final String email;

  @override
  void onInit() {
    super.onInit();

    // Get user data from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    firstName = args?['firstName'] ?? 'User';
    email = args?['email'] ?? '';

    // Start countdown
    _startCountdown();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  /// Start the countdown timer
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        // Countdown finished, navigate to home
        timer.cancel();
        isCountdownActive.value = false;
        _navigateToHome();
      }
    });
  }

  /// Navigate to home page
  void _navigateToHome() {
    Get.offAllNamed('/');
  }

  /// Skip countdown and go to home immediately
  void skipToHome() {
    _timer?.cancel();
    isCountdownActive.value = false;
    _navigateToHome();
  }

  /// Get welcome message
  String get welcomeMessage {
    return 'Welcome, $firstName!';
  }

  /// Get countdown message
  String get countdownMessage {
    if (countdown.value > 0) {
      return 'Redirecting to your dashboard in ${countdown.value} second${countdown.value == 1 ? '' : 's'}...';
    }
    return 'Redirecting now...';
  }
}
