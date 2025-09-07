class NewsArticle {
  final String? author;
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;
  final Source? source;

  NewsArticle({
    this.author,
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      author: json['author'],
      title: json['title'] ?? 'No Title',
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
      content: json['content'],
      source: json['source'] != null ? Source.fromJson(json['source']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
      'source': source?.toJson(),
    };
  }

  /// Get a fallback image URL if the article doesn't have an image
  String get imageUrl {
    if (urlToImage != null && urlToImage!.isNotEmpty) {
      return urlToImage!;
    }
    // Return a placeholder image URL
    return 'https://via.placeholder.com/300x200/7C3AED/FFFFFF?text=News';
  }

  /// Get a truncated description for UI
  String get shortDescription {
    if (description == null || description!.isEmpty) {
      return 'No description available';
    }
    if (description!.length <= 100) {
      return description!;
    }
    return '${description!.substring(0, 97)}...';
  }

  /// Format published date for UI
  String get formattedDate {
    if (publishedAt == null) return 'Unknown date';

    final now = DateTime.now();
    final difference = now.difference(publishedAt!);

    if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class Source {
  final String? id;
  final String name;

  Source({this.id, required this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(id: json['id'], name: json['name'] ?? 'Unknown Source');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class NewsResponse {
  final String status;
  final int totalResults;
  final List<NewsArticle> articles;

  NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] ?? 'error',
      totalResults: json['totalResults'] ?? 0,
      articles:
          (json['articles'] as List<dynamic>?)
              ?.map((article) => NewsArticle.fromJson(article))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'totalResults': totalResults,
      'articles': articles.map((article) => article.toJson()).toList(),
    };
  }
}
