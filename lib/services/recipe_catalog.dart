import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:habisin_mobile/models/plan.dart';

/// Set to the full DRF catalogue URL when running against Django.
const plannerApiUrl = String.fromEnvironment('PLANNER_API_URL');

Future<List<MealRecipe>> fetchPlannerRecipes(Uri endpoint) async {
  final response = await http
      .get(endpoint, headers: {'Accept': 'application/json'})
      .timeout(const Duration(seconds: 8));
  if (response.statusCode != 200) {
    throw http.ClientException('Katalog tidak tersedia.', endpoint);
  }
  final body = jsonDecode(utf8.decode(response.bodyBytes));
  if (body is! Map || body['recipes'] is! List) {
    throw const FormatException('Format katalog tidak sesuai.');
  }
  return [
    for (final item in body['recipes'] as List)
      if (item is Map<String, dynamic>)
        MealRecipe.fromJson(item)
      else
        throw const FormatException('Format resep tidak sesuai.'),
  ];
}
