/// User model for authenticated user data
class User {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String email;
  final bool emailVerified;
  final String role;
  final String firstName;
  final String lastName;
  final String? displayName;
  final String? username;
  final String? avatar;
  final String? bio;
  final DateTime? dateOfBirth;
  final String timezone;
  final String location;
  final String? googleId;
  final String? appleId;
  final String? facebookId;
  final String? twitterId;
  final String status;
  final DateTime? lastLoginAt;
  final DateTime lastActiveAt;

  const User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.email,
    required this.emailVerified,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.displayName,
    this.username,
    this.avatar,
    this.bio,
    this.dateOfBirth,
    required this.timezone,
    required this.location,
    this.googleId,
    this.appleId,
    this.facebookId,
    this.twitterId,
    required this.status,
    this.lastLoginAt,
    required this.lastActiveAt,
  });

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      email: json['email'] ?? '',
      emailVerified: json['emailVerified'] ?? false,
      role: json['role'] ?? 'USER',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      displayName: json['displayName'],
      username: json['username'],
      avatar: json['avatar'],
      bio: json['bio'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      timezone: json['timezone'] ?? 'UTC',
      location: json['location'] ?? '',
      googleId: json['googleId'],
      appleId: json['appleId'],
      facebookId: json['facebookId'],
      twitterId: json['twitterId'],
      status: json['status'] ?? 'ACTIVE',
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      lastActiveAt: DateTime.parse(
        json['lastActiveAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'email': email,
      'emailVerified': emailVerified,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'username': username,
      'avatar': avatar,
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'timezone': timezone,
      'location': location,
      'googleId': googleId,
      'appleId': appleId,
      'facebookId': facebookId,
      'twitterId': twitterId,
      'status': status,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get display name or full name
  String get displayNameOrFull => displayName ?? fullName;

  /// Get initials for avatar
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'U';
  }

  /// Check if user is active
  bool get isActive => status == 'ACTIVE';

  /// Check if email is verified
  bool get isEmailVerified => emailVerified;
}
