/// Login response model for authentication API
class LoginResponse {
  final String userId;
  final String token;
  final String refreshToken;

  const LoginResponse({
    required this.userId,
    required this.token,
    required this.refreshToken,
  });

  /// Create from JSON
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return LoginResponse(
      userId: data['userId'] ?? '',
      token: data['token'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': {'userId': userId, 'token': token, 'refreshToken': refreshToken},
    };
  }

  @override
  String toString() {
    return 'LoginResponse(userId: $userId, token: [HIDDEN], refreshToken: [HIDDEN])';
  }
}
