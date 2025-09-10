import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:momo_hackathon/app/data/models/news_article.dart';
import 'package:momo_hackathon/app/data/models/fraud_detection_stats.dart';
import 'package:momo_hackathon/app/data/services/news_service.dart';
import 'package:momo_hackathon/app/data/services/fraud_detection_service.dart';
import 'package:momo_hackathon/app/data/services/storage/secure_storage_service.dart';
import 'package:momo_hackathon/app/modules/auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  // Services
  final NewsService _newsService = Get.find<NewsService>();
  final FraudDetectionService _fraudService = Get.find<FraudDetectionService>();
  final SecureStorageService _storageService = Get.find<SecureStorageService>();

  // Observable variables for fraud detection stats
  final fraudStats = FraudDetectionStats.empty().obs;
  final isLoadingStats = false.obs;
  final statsError = RxnString();

  // Observable variables for home stats (deprecated - will be replaced with fraudStats)
  final totalScan = 1234.obs;
  final amountSaved = 56.78.obs;

  // News articles data
  final newsArticles = <NewsArticle>[].obs;
  final isLoadingNews = false.obs;
  final newsError = RxnString();

  // User profile data (loaded from secure storage)
  final userName = 'Loading...'.obs;
  final userEmail = 'Loading...'.obs;
  final userAvatarUrl = ''.obs;
  final isLoadingProfile = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadHomeData();
  }

  /// Load user profile data from secure storage
  Future<void> loadUserProfile() async {
    try {
      isLoadingProfile.value = true;

      // Get user data from secure storage
      final userData = _storageService.getUserData();

      if (userData != null) {
        // Extract user information
        final firstName = userData['firstName'] as String? ?? '';
        final lastName = userData['lastName'] as String? ?? '';
        final email = userData['email'] as String? ?? '';
        final avatar = userData['avatar'] as String? ?? '';

        // Update observables
        userName.value = '$firstName $lastName'.trim();
        userEmail.value = email;
        userAvatarUrl.value = avatar;

        print('✅ User profile loaded: ${userName.value} (${userEmail.value})');
      } else {
        // Fallback if no user data found
        userName.value = 'User';
        userEmail.value = 'user@example.com';
        userAvatarUrl.value = '';

        print('⚠️ No user data found in storage');
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');

      // Fallback values
      userName.value = 'User';
      userEmail.value = 'user@example.com';
      userAvatarUrl.value = '';
    } finally {
      isLoadingProfile.value = false;
    }
  }

  void loadHomeData() {
    // Load fraud detection statistics
    loadFraudStats();
    // Load news articles
    loadNewsArticles();
  }

  /// Load fraud detection statistics
  Future<void> loadFraudStats() async {
    try {
      isLoadingStats.value = true;
      statsError.value = null;

      final stats = await _fraudService.getStatsOverview();
      fraudStats.value = stats;

      // Update legacy stats for backward compatibility
      totalScan.value = stats.totalAnalyses;
      amountSaved.value = stats.amountSaved;

      print(
        '📊 Loaded fraud detection statistics: ${stats.totalAnalyses} analyses',
      );
    } catch (e) {
      print('❌ Error loading fraud stats: $e');
      statsError.value = e.toString();

      // Show user-friendly error message
      Get.snackbar(
        'Statistics Loading Error',
        'Unable to load fraud detection statistics. Showing cached data.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// Refresh fraud detection statistics
  Future<void> refreshFraudStats() async {
    try {
      isLoadingStats.value = true;
      statsError.value = null;

      final stats = await _fraudService.refreshStatsOverview();
      fraudStats.value = stats;

      // Update legacy stats
      totalScan.value = stats.totalAnalyses;
      amountSaved.value = stats.amountSaved;

      Get.snackbar(
        'Statistics Updated',
        'Fraud detection statistics refreshed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error refreshing fraud stats: $e');
      statsError.value = e.toString();

      Get.snackbar(
        'Refresh Failed',
        'Unable to refresh statistics. Please try again later.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// Refresh both stats and news
  Future<void> refreshHomeData() async {
    await Future.wait([refreshFraudStats(), refreshNews()]);
  }

  /// Load news articles from News API
  Future<void> loadNewsArticles() async {
    try {
      isLoadingNews.value = true;
      newsError.value = null;

      // Fetch fintech/tech news relevant to mobile money and Ghana
      final articles = await _newsService.getFinanceNews(pageSize: 5);

      if (articles.isNotEmpty) {
        newsArticles.assignAll(articles);
      } else {
        // Fallback to tech news if no finance news found
        final techArticles = await _newsService.getTechNews(pageSize: 5);
        newsArticles.assignAll(techArticles);
      }

      print('📰 Loaded ${newsArticles.length} news articles');
    } catch (e) {
      print('❌ Error loading news: $e');
      newsError.value = e.toString();

      // Show user-friendly error message
      Get.snackbar(
        'News Loading Error',
        'Unable to load latest news. Showing sample articles.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingNews.value = false;
    }
  }

  /// Refresh news articles
  Future<void> refreshNews() async {
    await loadNewsArticles();

    if (newsArticles.isNotEmpty && newsError.value == null) {
      Get.snackbar(
        'News Updated',
        'Latest articles loaded successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void updateTotalScan(int newCount) {
    totalScan.value = newCount;
  }

  void updateAmountSaved(double newAmount) {
    amountSaved.value = newAmount;
  }

  void onScanButtonPressed() {
    // Navigate to SMS scanner
    Get.toNamed('/sms-scanner');
  }

  /// Logout user (delegate to AuthController)
  Future<void> logout() async {
    try {
      final authController = Get.find<AuthController>();
      await authController.logout();
    } catch (e) {
      print('❌ Error accessing AuthController for logout: $e');
      // Fallback logout by clearing storage directly
      await _storageService.clearAuthData();
      Get.offAllNamed('/login');
    }
  }
}
