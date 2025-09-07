import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:momo_hackathon/app/data/models/news_article.dart';
import 'package:momo_hackathon/app/data/services/news_service.dart';

class HomeController extends GetxController {
  // Services
  final NewsService _newsService = Get.find<NewsService>();

  // Observable variables for home stats
  final totalScan = 1234.obs;
  final amountSaved = 56.78.obs;
  final selectedNavIndex = 0.obs;

  // News articles data
  final newsArticles = <NewsArticle>[].obs;
  final isLoadingNews = false.obs;
  final newsError = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void loadHomeData() {
    // Load initial news articles
    loadNewsArticles();
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

  void onNavItemTapped(int index) {
    selectedNavIndex.value = index;

    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        Get.toNamed('/history');
        break;
      case 2:
        Get.toNamed('/settings');
        break;
    }
  }

  void onScanButtonPressed() {
    // Navigate to SMS scanner
    Get.toNamed('/sms-scanner');
  }
}
