/// Login request model for user authentication
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  /// Create copy with updated fields
  LoginRequest copyWith({String? email, String? password}) {
    return LoginRequest(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'LoginRequest(email: $email, password: [HIDDEN])';
  }
}
