import 'dart:convert';

import 'package:http/http.dart' as http;

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://risyad-athaya-habisin.pws.cs.ui.ac.id',
);

const loginField = 'email';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  String? token;
  Map<String, dynamic>? profile;

  bool get isLoggedIn => token != null;
  String? get email => profile?['email'] as String?;
  String? get name => profile?['name'] as String?;

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      };

  Uri url(String path) => Uri.parse('$apiBaseUrl$path');

  Future<void> login(String identifier, String password) async {
    final res = await _send(
      () => http.post(
        url('/api/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({loginField: identifier, 'password': password}),
      ),
    );
    if (res.statusCode != 200) {
      throw AuthException(parseErrors(res, 'Email atau password salah.'));
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    token = data['token'] as String?;
    profile = data['profile'] as Map<String, dynamic>?;
  }

  Future<void> register(Map<String, String> fields) async {
    final res = await _send(
      () => http.post(
        url('/api/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(fields),
      ),
    );
    if (res.statusCode != 201) {
      throw AuthException(parseErrors(res, 'Registrasi gagal.'));
    }
  }

  Future<void> logout() async {
    final current = headers;
    token = null;
    profile = null;
    await http
        .post(url('/api/auth/logout/'), headers: current)
        .then((_) {}, onError: (_) {});
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 15));
    } on Exception {
      throw AuthException('Tidak bisa terhubung ke server. Coba lagi.');
    }
  }

  static String parseErrors(http.Response res, String fallback) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final errors = body['errors'] as Map<String, dynamic>?;
      final messages = errors?.values
          .expand((v) => v is List ? v : [v])
          .map((e) => e.toString())
          .toList();
      if (messages != null && messages.isNotEmpty) return messages.join('\n');
    } on Exception {
      return fallback;
    }
    return fallback;
  }
}
