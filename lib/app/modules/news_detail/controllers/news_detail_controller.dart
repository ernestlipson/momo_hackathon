import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:momo_hackathon/app/data/models/news_article.dart';

class NewsDetailController extends GetxController {
  late final NewsArticle article;

  final isLoading = false.obs;
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    // Get article from arguments
    final args = Get.arguments;
    if (args is NewsArticle) {
      article = args;
    } else {
      // Handle error - no article provided
      Get.back();
      Get.snackbar(
        'Error',
        'Article not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  /// Share article (placeholder implementation)
  void shareArticle() {
    if (article.url != null && article.url!.isNotEmpty) {
      Get.snackbar(
        'Share Article',
        'Sharing: ${article.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Open original article (placeholder implementation)
  void openOriginalArticle() {
    if (article.url != null && article.url!.isNotEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text('Open Article'),
          content: Text(
            'Would you like to open this article in your browser?\n\n${article.url}',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Article Link',
                  'In a real app, this would open: ${article.url}',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3),
                );
              },
              child: const Text('Open'),
            ),
          ],
        ),
      );
    }
  }

  /// Format article content for display
  String get formattedContent {
    if (article.content != null && article.content!.isNotEmpty) {
      // Remove the [+1234 chars] suffix that News API adds
      String content = article.content!;
      final regex = RegExp(r'\s*\[\+\d+ chars\]$');
      content = content.replaceAll(regex, '');
      return content;
    }

    if (article.description != null && article.description!.isNotEmpty) {
      return article.description!;
    }

    return 'No content available for this article.';
  }

  /// Get reading time estimate
  String get estimatedReadingTime {
    final wordCount = formattedContent.split(' ').length;
    final minutes = (wordCount / 200)
        .ceil(); // Average reading speed: 200 words/min
    return '$minutes min read';
  }
}
