class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.tokenType,
    required this.username,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }

  final String token;
  final String refreshToken;
  final String tokenType;
  final String username;
  final String role;

  bool get isAdmin => role == 'ROLE_ADMIN';
}

class LoginRequest {
  const LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };

  final String username;
  final String password;
}

class RefreshTokenRequest {
  const RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};

  final String refreshToken;
}
