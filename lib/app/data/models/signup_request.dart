/// Signup request model for user registration
class SignupRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String location;

  const SignupRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.location,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'location': location,
    };
  }

  /// Create copy with updated fields
  SignupRequest copyWith({
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? location,
  }) {
    return SignupRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      location: location ?? this.location,
    );
  }
}

/// Ghana regions enum for location selection
enum GhanaRegion {
  greaterAccra('GREATER_ACCRA', 'Greater Accra'),
  ashanti('ASHANTI', 'Ashanti'),
  western('WESTERN', 'Western'),
  central('CENTRAL', 'Central'),
  volta('VOLTA', 'Volta'),
  eastern('EASTERN', 'Eastern'),
  northern('NORTHERN', 'Northern'),
  upperEast('UPPER_EAST', 'Upper East'),
  upperWest('UPPER_WEST', 'Upper West'),
  brongAhafo('BRONG_AHAFO', 'Brong Ahafo'),
  westernNorth('WESTERN_NORTH', 'Western North'),
  ahafo('AHAFO', 'Ahafo'),
  bono('BONO', 'Bono'),
  bonoEast('BONO_EAST', 'Bono East'),
  oti('OTI', 'Oti'),
  savannah('SAVANNAH', 'Savannah'),
  northEast('NORTH_EAST', 'North East');

  const GhanaRegion(this.code, this.displayName);

  final String code;
  final String displayName;

  /// Get all regions as a list
  static List<GhanaRegion> get all => GhanaRegion.values;

  /// Get region by code
  static GhanaRegion? fromCode(String code) {
    try {
      return GhanaRegion.values.firstWhere((region) => region.code == code);
    } catch (e) {
      return null;
    }
  }
}
