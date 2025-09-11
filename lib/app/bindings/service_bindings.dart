import 'package:get/get.dart';
import 'package:momo_hackathon/app/data/services/local_auth_db_service.dart';
import '../data/services/network/base_network_service.dart';
import '../data/services/fraud_detection_service.dart';
import '../data/services/sms_listener_service.dart';
import '../data/services/background_sms_worker.dart';
import '../data/services/news_service.dart';
import '../data/services/api_article_service.dart';
import '../data/services/auth_service.dart';

/// Service bindings for dependency injection
class ServiceBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize network service immediately for core functionality
    if (!Get.isRegistered<BaseNetworkService>()) {
      Get.put<BaseNetworkService>(BaseNetworkService(), permanent: true);
    }

    // Initialize fraud detection service immediately for core functionality
    if (!Get.isRegistered<FraudDetectionService>()) {
      Get.put<FraudDetectionService>(FraudDetectionService(), permanent: true);
    }

    // Initialize SMS listener service for background monitoring
    if (!Get.isRegistered<SmsListenerService>()) {
      Get.put<SmsListenerService>(SmsListenerService(), permanent: true);
    }

    // Initialize news service for fetching articles
    if (!Get.isRegistered<NewsService>()) {
      Get.put<NewsService>(NewsService(), permanent: true);
    }

    // Initialize API article service for fetching API articles
    if (!Get.isRegistered<ApiArticleService>()) {
      Get.put<ApiArticleService>(ApiArticleService(), permanent: true);
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
    Get.put<LocalAuthDbService>(LocalAuthDbService(), permanent: true);
    // Put essential services here that need immediate access
    Get.put<BaseNetworkService>(BaseNetworkService(), permanent: true);
  }
}
