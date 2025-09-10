import 'package:get/get.dart';
import '../models/api_article.dart';
import 'network/base_network_service.dart';

class ApiArticleService {
  final BaseNetworkService _networkService = Get.find<BaseNetworkService>();

  Future<List<ApiArticle>> fetchArticles() async {
    final response = await _networkService.get('/articles');
    if (response != null &&
        response.statusCode == 200 &&
        response.data != null) {
      final articlesJson = response.data['data']['articles'] as List;
      return articlesJson.map((json) => ApiArticle.fromJson(json)).toList();
    }
    return [];
  }
}
