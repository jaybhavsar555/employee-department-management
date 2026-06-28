class AuthSession {
  const AuthSession({
    required this.username,
    required this.role,
  });

  final String username;
  final String role;

  bool get isAdmin => role == 'ROLE_ADMIN';
}
