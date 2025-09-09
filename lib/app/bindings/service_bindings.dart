import 'package:get/get.dart';
import '../data/services/network/base_network_service.dart';
import '../data/services/storage/secure_storage_service.dart';
import '../data/services/fraud_detection_service.dart';

/// Service bindings for dependency injection
class ServiceBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize secure storage service
    Get.putAsync<SecureStorageService>(() async {
      final service = SecureStorageService();
      await service.init();
      return service;
    }, permanent: true);

    // Initialize network service immediately for core functionality
    if (!Get.isRegistered<BaseNetworkService>()) {
      Get.put<BaseNetworkService>(BaseNetworkService(), permanent: true);
    }

    // Initialize fraud detection service immediately for core functionality
    if (!Get.isRegistered<FraudDetectionService>()) {
      Get.put<FraudDetectionService>(FraudDetectionService(), permanent: true);
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
