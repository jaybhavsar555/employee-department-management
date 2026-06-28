import 'package:flutter_test/flutter_test.dart';

import 'package:admin_panel/models/auth_response.dart';
import 'package:admin_panel/models/auth_session.dart';

void main() {
  group('AuthSession', () {
    test('isAdmin is true for ROLE_ADMIN', () {
      const session = AuthSession(username: 'admin', role: 'ROLE_ADMIN');
      expect(session.isAdmin, isTrue);
    });

    test('isAdmin is false for ROLE_USER', () {
      const session = AuthSession(username: 'john', role: 'ROLE_USER');
      expect(session.isAdmin, isFalse);
    });
  });

  group('AuthResponse', () {
    test('fromJson parses login response with refresh token', () {
      final response = AuthResponse.fromJson({
        'token': 'access-token',
        'refreshToken': 'refresh-token',
        'tokenType': 'Bearer',
        'username': 'admin',
        'role': 'ROLE_ADMIN',
      });

      expect(response.token, 'access-token');
      expect(response.refreshToken, 'refresh-token');
      expect(response.isAdmin, isTrue);
    });
  });
}
