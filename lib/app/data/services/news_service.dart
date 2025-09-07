import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/news_article.dart';

class NewsService extends GetxService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = '31925e80d95746c98eb111a297f7db69';

  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'X-API-Key': _apiKey, 'User-Agent': 'MomoHackathon/1.0'},
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🌐 Making request to: ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Response received: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ Request error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Fetch top headlines from Ghana or technology news
  Future<List<NewsArticle>> getTopHeadlines({
    String? country = 'gh', // Ghana
    String? category,
    int pageSize = 10,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/top-headlines',
        queryParameters: {
          if (country != null) 'country': country,
          if (category != null) 'category': category,
          'pageSize': pageSize,
          'page': page,
        },
      );

      final newsResponse = NewsResponse.fromJson(response.data);

      if (newsResponse.status == 'ok') {
        return newsResponse.articles;
      } else {
        throw Exception('Failed to fetch news: ${newsResponse.status}');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid API key. Please check your News API key.');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many requests. Please try again later.');
      } else if (e.response?.statusCode == 426) {
        throw Exception('Upgrade required. This API key has limited access.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('General error: $e');
      throw Exception('Failed to fetch news articles: $e');
    }
  }

  /// Search for news articles
  Future<List<NewsArticle>> searchNews({
    required String query,
    String? sortBy = 'publishedAt', // publishedAt, relevancy, popularity
    String? language = 'en',
    int pageSize = 10,
    int page = 1,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final response = await _dio.get(
        '/everything',
        queryParameters: {
          'q': query,
          if (sortBy != null) 'sortBy': sortBy,
          if (language != null) 'language': language,
          'pageSize': pageSize,
          'page': page,
          if (from != null) 'from': from.toIso8601String().split('T')[0],
          if (to != null) 'to': to.toIso8601String().split('T')[0],
        },
      );

      final newsResponse = NewsResponse.fromJson(response.data);

      if (newsResponse.status == 'ok') {
        return newsResponse.articles;
      } else {
        throw Exception('Failed to search news: ${newsResponse.status}');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid API key. Please check your News API key.');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many requests. Please try again later.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('General error: $e');
      throw Exception('Failed to search news articles: $e');
    }
  }

  /// Get technology news articles
  Future<List<NewsArticle>> getTechNews({
    int pageSize = 10,
    int page = 1,
  }) async {
    try {
      // First try to get tech news from Ghana, then fallback to global tech news
      try {
        return await getTopHeadlines(
          country: 'gh',
          category: 'technology',
          pageSize: pageSize,
          page: page,
        );
      } catch (e) {
        // If Ghana tech news fails, search for global tech news
        return await searchNews(
          query: 'technology OR fintech OR mobile money OR digital payment',
          sortBy: 'publishedAt',
          pageSize: pageSize,
          page: page,
        );
      }
    } catch (e) {
      print('Failed to get tech news: $e');
      // Return sample articles if API fails
      return _getSampleArticles();
    }
  }

  /// Get finance/fintech related news
  Future<List<NewsArticle>> getFinanceNews({
    int pageSize = 10,
    int page = 1,
  }) async {
    try {
      return await searchNews(
        query:
            'mobile money OR fintech OR digital banking OR Ghana finance OR cryptocurrency',
        sortBy: 'publishedAt',
        pageSize: pageSize,
        page: page,
      );
    } catch (e) {
      print('Failed to get finance news: $e');
      return _getSampleArticles();
    }
  }

  /// Fallback sample articles for when API fails
  List<NewsArticle> _getSampleArticles() {
    final now = DateTime.now();

    return [
      NewsArticle(
        title: 'Ghana\'s Mobile Money Revolution Continues',
        description:
            'Mobile money transactions in Ghana have seen unprecedented growth, revolutionizing how people access financial services.',
        author: 'Tech News Ghana',
        url: 'https://example.com/mobile-money-ghana',
        urlToImage:
            'https://via.placeholder.com/300x200/7C3AED/FFFFFF?text=Mobile+Money',
        publishedAt: now.subtract(const Duration(hours: 2)),
        source: Source(id: 'tech-ghana', name: 'Tech News Ghana'),
      ),
      NewsArticle(
        title: 'Fintech Startups Transform African Banking',
        description:
            'A new wave of fintech startups across Africa is making banking more accessible and affordable for millions.',
        author: 'African Tech',
        url: 'https://example.com/fintech-africa',
        urlToImage:
            'https://via.placeholder.com/300x200/7C3AED/FFFFFF?text=Fintech',
        publishedAt: now.subtract(const Duration(hours: 6)),
        source: Source(id: 'african-tech', name: 'African Tech'),
      ),
      NewsArticle(
        title: 'Digital Payment Security: What You Need to Know',
        description:
            'Learn about the latest security measures protecting your digital payments and how to stay safe online.',
        author: 'Cyber Security Weekly',
        url: 'https://example.com/payment-security',
        urlToImage:
            'https://via.placeholder.com/300x200/7C3AED/FFFFFF?text=Security',
        publishedAt: now.subtract(const Duration(days: 1)),
        source: Source(id: 'cyber-weekly', name: 'Cyber Security Weekly'),
      ),
    ];
  }

  /// Check if the News API is accessible
  Future<bool> checkApiStatus() async {
    try {
      final response = await _dio.get(
        '/top-headlines',
        queryParameters: {'country': 'us', 'pageSize': 1},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('API status check failed: $e');
      return false;
    }
  }
}
