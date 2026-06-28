// Maps JSON from POST /auth/login and POST /auth/refresh
class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.tokenType,
    required this.username,
    required this.role,
  });

  // Parse backend JSON into Dart object
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }

  final String token; // Access JWT
  final String refreshToken; // Refresh JWT
  final String tokenType; // Always "Bearer"
  final String username;
  final String role;

  bool get isAdmin => role == 'ROLE_ADMIN';
}

// Body sent to POST /auth/login
class LoginRequest {
  const LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };

  final String username;
  final String password;
}

// Body sent to POST /auth/refresh
class RefreshTokenRequest {
  const RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};

  final String refreshToken;
}
