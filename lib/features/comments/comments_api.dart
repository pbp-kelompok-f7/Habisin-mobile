import 'dart:convert';

import 'package:http/http.dart' as http;

import 'comment.dart';

/// Base URL of the Django server or `/api/comments/` endpoint when running against Django.
/// Example: `--dart-define=COMMENTS_API_URL=http://127.0.0.1:8010/api/comments`
const commentsApiUrl = String.fromEnvironment('COMMENTS_API_URL');
const commentsAuthToken = String.fromEnvironment('COMMENTS_AUTH_TOKEN');

Uri _resolveCommentsBase(String rawUrl) {
  final trimmed = rawUrl.trim().replaceAll(RegExp(r'/+$'), '');
  if (trimmed.endsWith('/api/comments') || trimmed.endsWith('/comments/api')) {
    return Uri.parse('$trimmed/');
  }
  return Uri.parse('$trimmed/api/comments/');
}

Map<String, String> _headers({String? token, bool jsonBody = false}) {
  return {
    'Accept': 'application/json',
    if (jsonBody) 'Content-Type': 'application/json',
    if (token != null && token.trim().isNotEmpty)
      'Authorization': 'Token ${token.trim()}',
  };
}

Future<List<RecipeComment>> fetchRecipeComments(
  String baseUrl,
  int recipeId, {
  String? token,
  http.Client? client,
}) async {
  final base = _resolveCommentsBase(baseUrl);
  final endpoint = base.resolve('recipes/$recipeId/');
  final httpClient = client ?? http.Client();
  final response = await httpClient
      .get(endpoint, headers: _headers(token: token))
      .timeout(const Duration(seconds: 8));
  if (response.statusCode != 200) {
    throw http.ClientException('Komentar tidak tersedia.', endpoint);
  }
  final body = jsonDecode(utf8.decode(response.bodyBytes));
  if (body is! Map || body['comments'] is! List) {
    throw const FormatException('Format daftar komentar tidak sesuai.');
  }
  return [
    for (final item in body['comments'] as List)
      if (item is Map<String, dynamic>)
        RecipeComment.fromJson(item)
      else
        throw const FormatException('Format komentar tidak sesuai.'),
  ];
}

Future<RecipeComment> postRecipeComment(
  String baseUrl,
  int recipeId,
  String content, {
  required String token,
  http.Client? client,
}) async {
  final base = _resolveCommentsBase(baseUrl);
  final endpoint = base.resolve('recipes/$recipeId/');
  final httpClient = client ?? http.Client();
  final response = await httpClient
      .post(
        endpoint,
        headers: _headers(token: token, jsonBody: true),
        body: jsonEncode({'content': content}),
      )
      .timeout(const Duration(seconds: 8));
  if (response.statusCode != 200 && response.statusCode != 201) {
    throw http.ClientException('Gagal mengirim komentar.', endpoint);
  }
  final body = jsonDecode(utf8.decode(response.bodyBytes));
  if (body is! Map || body['comment'] is! Map<String, dynamic>) {
    throw const FormatException('Format respons komentar tidak sesuai.');
  }
  return RecipeComment.fromJson(body['comment'] as Map<String, dynamic>);
}

Future<RecipeComment> toggleCommentLike(
  String baseUrl,
  int commentId, {
  required String token,
  http.Client? client,
}) async {
  final base = _resolveCommentsBase(baseUrl);
  final endpoint = base.resolve('$commentId/like/');
  final httpClient = client ?? http.Client();
  final response = await httpClient
      .post(endpoint, headers: _headers(token: token))
      .timeout(const Duration(seconds: 8));
  if (response.statusCode != 200) {
    throw http.ClientException('Gagal memperbarui suka komentar.', endpoint);
  }
  final body = jsonDecode(utf8.decode(response.bodyBytes));
  if (body is! Map || body['comment'] is! Map<String, dynamic>) {
    throw const FormatException('Format respons like tidak sesuai.');
  }
  return RecipeComment.fromJson(body['comment'] as Map<String, dynamic>);
}

Future<void> deleteRecipeComment(
  String baseUrl,
  int commentId, {
  required String token,
  http.Client? client,
}) async {
  final base = _resolveCommentsBase(baseUrl);
  final endpoint = base.resolve('$commentId/');
  final httpClient = client ?? http.Client();
  final response = await httpClient
      .delete(endpoint, headers: _headers(token: token))
      .timeout(const Duration(seconds: 8));
  if (response.statusCode != 200 && response.statusCode != 204) {
    throw http.ClientException('Gagal menghapus komentar.', endpoint);
  }
}
