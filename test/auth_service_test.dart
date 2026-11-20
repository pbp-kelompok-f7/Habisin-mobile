import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:habisin_mobile/features/auth/services/auth_service.dart';

void main() {
  final auth = AuthService.instance;

  setUp(() {
    auth.token = null;
    auth.profile = null;
  });

  test('isLoggedIn false tanpa token, true jika ada token', () {
    expect(auth.isLoggedIn, false);
    auth.token = 'abc';
    expect(auth.isLoggedIn, true);
  });

  test('email dan name diambil dari profile', () {
    expect(auth.email, isNull);
    auth.profile = {'email': 'a@b.com', 'name': 'Adit'};
    expect(auth.email, 'a@b.com');
    expect(auth.name, 'Adit');
  });

  test('headers menyertakan Authorization hanya jika ada token', () {
    expect(auth.headers.containsKey('Authorization'), false);
    auth.token = 'abc';
    expect(auth.headers['Authorization'], 'Token abc');
    expect(auth.headers['Content-Type'], 'application/json');
  });

  test('url menggabungkan base url dan path', () {
    expect(auth.url('/api/auth/login/').path, '/api/auth/login/');
  });

  group('parseErrors', () {
    test('menggabungkan semua pesan error dengan newline', () {
      final res = http.Response(
          '{"errors":{"email":["Email tidak valid."],"password":["Terlalu pendek."]}}',
          400);
      expect(AuthService.parseErrors(res, 'fallback'),
          'Email tidak valid.\nTerlalu pendek.');
    });

    test('memakai fallback jika body bukan JSON', () {
      final res = http.Response('<html>error</html>', 500);
      expect(AuthService.parseErrors(res, 'fallback'), 'fallback');
    });

    test('memakai fallback jika tidak ada field errors', () {
      final res = http.Response('{"detail":"x"}', 400);
      expect(AuthService.parseErrors(res, 'fallback'), 'fallback');
    });
  });
}