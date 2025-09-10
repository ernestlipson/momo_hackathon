import 'user.dart';

/// Signup response model for registration API
class SignupResponse {
  final String userId;
  final String token;
  final String refreshToken;
  final User user;

  const SignupResponse({
    required this.userId,
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  /// Create from JSON
  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return SignupResponse(
      userId: data['userId'] ?? '',
      token: data['token'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
      user: User.fromJson(data['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': {
        'userId': userId,
        'token': token,
        'refreshToken': refreshToken,
        'user': user.toJson(),
      },
    };
  }
}
