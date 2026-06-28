// Lightweight logged-in user info for UI (no tokens stored here)
class AuthSession {
  const AuthSession({
    required this.username,
    required this.role,
  });

  final String username;
  final String role; // e.g. ROLE_ADMIN or ROLE_USER

  // Used to show/hide delete buttons — only admin can DELETE on backend
  bool get isAdmin => role == 'ROLE_ADMIN';
}
