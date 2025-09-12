import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momo_hackathon/app/data/models/api_article.dart';
import 'package:momo_hackathon/app/data/models/fraud_detection_stats.dart';
import 'package:momo_hackathon/app/data/services/api_article_service.dart';
import 'package:momo_hackathon/app/data/services/fraud_detection_service.dart';
import 'package:momo_hackathon/app/data/services/local_auth_db_service.dart';
import 'package:momo_hackathon/app/data/services/news_service.dart';

class HomeController extends GetxController {
  // Services
  final NewsService _newsService = Get.find<NewsService>();
  final ApiArticleService _apiArticleService = Get.find<ApiArticleService>();
  final FraudDetectionService _fraudService = Get.find<FraudDetectionService>();

  // Observable variables for fraud detection stats
  final fraudStats = FraudDetectionStats.empty().obs;
  final isLoadingStats = false.obs;
  final statsError = RxnString();

  // Observable variables for home stats (deprecated - will be replaced with fraudStats)
  final totalScan = 1234.obs;

  // News articles data (commented out - replaced with API articles)
  // final newsArticles = <NewsArticle>[].obs;

  // API Articles data
  final apiArticles = <ApiArticle>[].obs;
  final isLoadingNews = false.obs;
  final newsError = RxnString();

  // User profile data (loaded from secure storage)
  final userName = 'User'.obs;
  final userEmail = 'user@example.com'.obs;
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
      final userData = LocalAuthDbService.getUserData();

      if (userData != null) {
        // Extract user information with safe string handling
        final firstName = (userData['firstName'] as String?)?.trim() ?? '';
        final lastName = (userData['lastName'] as String?)?.trim() ?? '';
        final email = (userData['email'] as String?)?.trim() ?? '';
        final avatar = (userData['avatar'] as String?)?.trim() ?? '';

        // Update observables with safe string concatenation
        final fullName = '$firstName $lastName'.trim();
        userName.value = fullName.isNotEmpty ? fullName : 'User';
        userEmail.value = email.isNotEmpty ? email : 'user@example.com';
        userAvatarUrl.value = avatar;

        Get.log(
          '✅ User profile loaded: ${userName.value} (${userEmail.value})',
        );
      } else {
        // Fallback if no user data found
        userName.value = 'User';
        userEmail.value = 'user@example.com';
        userAvatarUrl.value = '';

        Get.log('⚠️ No user data found in storage');
      }
    } catch (e, s) {
      Get.log('❌ Error loading user profile: $e $s');

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
    // Load API articles (replaced news articles)
    loadApiArticles();
  }

  /// Load fraud detection statistics
  Future<void> loadFraudStats() async {
    try {
      isLoadingStats.value = true;
      statsError.value = null;

      final stats = await _fraudService.getStatsOverview();
      Get.log('Stats Overview: $stats');
      if (stats != null) {
        fraudStats.value = stats;
        totalScan.value = stats.totalAnalyses;
        Get.log(
          '📊 Loaded fraud detection statistics: ${stats.totalAnalyses} analyses',
        );
      } else {
        Get.log('❌ Error loading fraud stats: stats is null');
        statsError.value = 'No stats data available.';
        // Optionally set fallback values or keep previous
        Get.snackbar(
          'Statistics Loading Error',
          'Unable to load fraud detection statistics. Showing cached data.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.log('❌ Error loading fraud stats: $e');
      statsError.value = e.toString();
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
      if (stats != null) {
        fraudStats.value = stats;
        totalScan.value = stats.totalAnalyses;
        Get.snackbar(
          'Statistics Updated',
          'Fraud detection statistics refreshed successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.log('❌ Error refreshing fraud stats: stats is null');
        statsError.value = 'No stats data available.';
        Get.snackbar(
          'Refresh Failed',
          'Unable to refresh statistics. Please try again later.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.log('❌ Error refreshing fraud stats: $e');
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

  /// Refresh both stats and articles
  Future<void> refreshHomeData() async {
    await Future.wait([refreshFraudStats(), refreshNews()]);
  }

  /// Load API articles
  Future<void> loadApiArticles() async {
    try {
      isLoadingNews.value = true;
      newsError.value = null;

      final articles = await _apiArticleService.fetchArticles();

      if (articles.isNotEmpty) {
        apiArticles.assignAll(articles);
        Get.log('📰 Loaded ${apiArticles.length} API articles');
      } else {
        Get.log('⚠️ No API articles found');
      }
    } catch (e) {
      Get.log('❌ Error loading API articles: $e');
      newsError.value = e.toString();

      // Show user-friendly error message
      Get.snackbar(
        'Articles Loading Error',
        'Unable to load latest articles. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingNews.value = false;
    }
  }

  /// Refresh API articles
  Future<void> refreshNews() async {
    await loadApiArticles();

    if (apiArticles.isNotEmpty && newsError.value == null) {
      Get.snackbar(
        'Articles Updated',
        'Latest articles loaded successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /* COMMENTED OUT - OLD NEWS IMPLEMENTATION
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

      Get.log('📰 Loaded ${newsArticles.length} news articles');
    } catch (e) {
      Get.log('❌ Error loading news: $e');
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
  */

  void updateTotalScan(int newCount) {
    totalScan.value = newCount;
  }

  void onScanButtonPressed() {
    // Navigate to SMS scanner
    Get.toNamed('/sms-scanner');
  }
}
