/// DRF API endpoint definitions for the Saved Meals & History module.
abstract final class SavedMealsEndpoints {
  static const String defaultBaseUrl = 'http://10.0.2.2:8000';
  static const String pwsBaseUrl = 'https://risyad-athaya-habisin.pws.cs.ui.ac.id';

  static const String overview = '/saved-meals/api/overview/';
  static const String metrics = '/saved-meals/api/metrics/';
  static const String meals = '/saved-meals/api/meals/';
  static String mealDetail(int mealId) => '/saved-meals/api/meals/$mealId/';
  static String addFromRecipe(int recipeId) =>
      '/saved-meals/api/meals/from-recipe/$recipeId/';
  static String markMealDone(int mealId) =>
      '/saved-meals/api/meals/$mealId/complete/';
  static const String history = '/saved-meals/api/history/';
  static String historyDetail(int mealId) => '/saved-meals/api/history/$mealId/';

  static String buildUrl(String path, {String baseUrl = defaultBaseUrl}) =>
      '$baseUrl$path';
}
