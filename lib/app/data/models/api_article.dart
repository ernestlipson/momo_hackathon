class ApiArticle {
  final String id;
  final String title;
  final String excerpt;
  final String? coverImage;
  final DateTime createdAt;
  final String content;

  ApiArticle({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.coverImage,
    required this.createdAt,
    required this.content,
  });

  factory ApiArticle.fromJson(Map<String, dynamic> json) {
    return ApiArticle(
      id: json['id'],
      title: json['title'],
      excerpt: json['excerpt'],
      coverImage: json['coverImage'],
      createdAt: DateTime.parse(json['createdAt']),
      content: json['content'],
    );
  }

  /// Format timestamp based on age
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays <= 5) {
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} minutes ago';
        }
        return '${difference.inHours} hours ago';
      }
      return '${difference.inDays} days ago';
    } else {
      // Format as "Sep 7, 2025"
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
    }
  }
}
