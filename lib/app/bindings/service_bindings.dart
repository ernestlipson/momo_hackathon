import 'package:get/get.dart';
import '../data/services/network/base_network_service.dart';
import '../data/services/storage/secure_storage_service.dart';
import '../data/services/fraud_detection_service.dart';
import '../data/services/news_service.dart';
import '../data/services/auth_service.dart';

/// Service bindings for dependency injection
class ServiceBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize secure storage service first (synchronously)
    if (!Get.isRegistered<SecureStorageService>()) {
      final secureStorage = SecureStorageService();
      Get.put<SecureStorageService>(secureStorage, permanent: true);
      // Initialize storage asynchronously in the background
      secureStorage.init().catchError((e) {
        print('Warning: Failed to initialize SecureStorageService: $e');
      });
    }

    // Initialize network service immediately for core functionality
    if (!Get.isRegistered<BaseNetworkService>()) {
      Get.put<BaseNetworkService>(BaseNetworkService(), permanent: true);
    }

    // Initialize fraud detection service immediately for core functionality
    if (!Get.isRegistered<FraudDetectionService>()) {
      Get.put<FraudDetectionService>(FraudDetectionService(), permanent: true);
    }

    // Initialize news service for fetching articles
    if (!Get.isRegistered<NewsService>()) {
      Get.put<NewsService>(NewsService(), permanent: true);
    }

    // Initialize auth service for user authentication
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService(), permanent: true);
    }
  }
}

/// Initial service bindings that need to be loaded before app starts
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Put essential services here that need immediate access
    Get.put<BaseNetworkService>(BaseNetworkService(), permanent: true);
  }
}
