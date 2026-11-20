/// Status separating planned/saved meals from cooked meal history.
enum SavedMealStatus {
  saved,
  history;

  static SavedMealStatus fromApi(String? raw) {
    if (raw != null && raw.toUpperCase() == 'HISTORY') {
      return SavedMealStatus.history;
    }
    return SavedMealStatus.saved;
  }

  String toApi() => this == SavedMealStatus.history ? 'HISTORY' : 'SAVED';
}

/// Data model aligned 1:1 with Django REST Framework `SavedMealSerializer`.
class SavedMeal {
  final int id;
  final int? recipeId;
  final String recipeName;
  final String imageUrl;
  final int cookingTimeMinutes;
  final int portionsSaved;
  final double ingredientsSavedKg;
  final int proteinGrams;
  final int caloriesKcal;
  final String ingredients;
  final String notes;
  final SavedMealStatus status;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SavedMeal({
    required this.id,
    this.recipeId,
    required this.recipeName,
    this.imageUrl = '',
    this.cookingTimeMinutes = 30,
    this.portionsSaved = 1,
    this.ingredientsSavedKg = 0.2,
    this.proteinGrams = 10,
    this.caloriesKcal = 300,
    this.ingredients = '',
    this.notes = '',
    this.status = SavedMealStatus.saved,
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
  });

  factory SavedMeal.fromJson(Map<String, dynamic> json) {
    return SavedMeal(
      id: (json['id'] as num?)?.toInt() ?? 0,
      recipeId: (json['recipe_id'] as num?)?.toInt(),
      recipeName: (json['recipe_name'] as String?) ?? '',
      imageUrl: (json['image_url'] as String?) ?? '',
      cookingTimeMinutes:
          (json['cooking_time_minutes'] as num?)?.toInt() ?? 30,
      portionsSaved: (json['portions_saved'] as num?)?.toInt() ?? 1,
      ingredientsSavedKg:
          (json['ingredients_saved_kg'] as num?)?.toDouble() ?? 0.2,
      proteinGrams: (json['protein_grams'] as num?)?.toInt() ?? 0,
      caloriesKcal: (json['calories_kcal'] as num?)?.toInt() ?? 0,
      ingredients: (json['ingredients'] as String?) ?? '',
      notes: (json['notes'] as String?) ?? '',
      status: SavedMealStatus.fromApi(json['status'] as String?),
      isFavorite: (json['is_favorite'] as bool?) ?? false,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'recipe_name': recipeName,
      'image_url': imageUrl,
      'cooking_time_minutes': cookingTimeMinutes,
      'portions_saved': portionsSaved,
      'ingredients_saved_kg': ingredientsSavedKg,
      'protein_grams': proteinGrams,
      'calories_kcal': caloriesKcal,
      'ingredients': ingredients,
      'notes': notes,
      'status': status.toApi(),
      'is_favorite': isFavorite,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SavedMeal copyWith({
    int? id,
    int? recipeId,
    String? recipeName,
    String? imageUrl,
    int? cookingTimeMinutes,
    int? portionsSaved,
    double? ingredientsSavedKg,
    int? proteinGrams,
    int? caloriesKcal,
    String? ingredients,
    String? notes,
    SavedMealStatus? status,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedMeal(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      imageUrl: imageUrl ?? this.imageUrl,
      cookingTimeMinutes: cookingTimeMinutes ?? this.cookingTimeMinutes,
      portionsSaved: portionsSaved ?? this.portionsSaved,
      ingredientsSavedKg: ingredientsSavedKg ?? this.ingredientsSavedKg,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      ingredients: ingredients ?? this.ingredients,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

/// Aggregated food-waste impact metrics aligned with `SavedMealsMetricsSerializer`.
class SavedMealsMetrics {
  final int totalPortions;
  final double totalWeight;
  final int recipesFinished;
  final int totalProtein;
  final int totalCalories;

  const SavedMealsMetrics({
    required this.totalPortions,
    required this.totalWeight,
    required this.recipesFinished,
    required this.totalProtein,
    required this.totalCalories,
  });

  const SavedMealsMetrics.empty()
      : totalPortions = 0,
        totalWeight = 0.0,
        recipesFinished = 0,
        totalProtein = 0,
        totalCalories = 0;

  factory SavedMealsMetrics.fromJson(Map<String, dynamic> json) {
    return SavedMealsMetrics(
      totalPortions: (json['total_portions'] as num?)?.toInt() ?? 0,
      totalWeight: (json['total_weight'] as num?)?.toDouble() ?? 0.0,
      recipesFinished: (json['recipes_finished'] as num?)?.toInt() ?? 0,
      totalProtein: (json['total_protein'] as num?)?.toInt() ?? 0,
      totalCalories: (json['total_calories'] as num?)?.toInt() ?? 0,
    );
  }

  factory SavedMealsMetrics.fromHistoryMeals(List<SavedMeal> historyMeals) {
    var portions = 0;
    var weight = 0.0;
    var protein = 0;
    var calories = 0;

    for (final meal in historyMeals) {
      portions += meal.portionsSaved;
      weight += meal.ingredientsSavedKg;
      protein += meal.proteinGrams;
      calories += meal.caloriesKcal;
    }

    return SavedMealsMetrics(
      totalPortions: portions,
      totalWeight: double.parse(weight.toStringAsFixed(1)),
      recipesFinished: historyMeals.length,
      totalProtein: protein,
      totalCalories: calories,
    );
  }
}

/// Combined response payload aligned with `/saved-meals/api/overview/`.
class SavedMealsOverview {
  final List<SavedMeal> savedMeals;
  final List<SavedMeal> historyMeals;
  final SavedMealsMetrics metrics;

  const SavedMealsOverview({
    required this.savedMeals,
    required this.historyMeals,
    required this.metrics,
  });

  factory SavedMealsOverview.fromJson(Map<String, dynamic> json) {
    final rawSaved = (json['saved_meals'] as List<dynamic>?) ?? const [];
    final rawHistory = (json['history_meals'] as List<dynamic>?) ?? const [];
    final rawMetrics =
        (json['metrics'] as Map<String, dynamic>?) ?? const <String, dynamic>{};

    return SavedMealsOverview(
      savedMeals: rawSaved
          .whereType<Map<String, dynamic>>()
          .map(SavedMeal.fromJson)
          .toList(),
      historyMeals: rawHistory
          .whereType<Map<String, dynamic>>()
          .map(SavedMeal.fromJson)
          .toList(),
      metrics: SavedMealsMetrics.fromJson(rawMetrics),
    );
  }
}

/// Checkpoint 1 sample data reflecting the DRF schema before live HTTP integration.
abstract final class SavedMealsSampleData {
  static List<SavedMeal> initialSavedMeals() => [
        const SavedMeal(
          id: 1,
          recipeId: 52772,
          recipeName: 'Teriyaki Chicken Casserole',
          cookingTimeMinutes: 30,
          portionsSaved: 2,
          ingredientsSavedKg: 0.4,
          proteinGrams: 34,
          caloriesKcal: 460,
          ingredients: 'Chicken Breast, Soy Sauce, Broccoli, Rice',
          status: SavedMealStatus.saved,
        ),
        const SavedMeal(
          id: 2,
          recipeName: 'Leftover Veggie Frittata',
          cookingTimeMinutes: 18,
          portionsSaved: 1,
          ingredientsSavedKg: 0.2,
          proteinGrams: 19,
          caloriesKcal: 290,
          ingredients: 'Eggs, Spinach, Bell Pepper, Cheddar',
          status: SavedMealStatus.saved,
        ),
      ];

  static List<SavedMeal> initialHistoryMeals() => [
        const SavedMeal(
          id: 3,
          recipeId: 52874,
          recipeName: 'Beef & Mustard Stir Fry',
          cookingTimeMinutes: 25,
          portionsSaved: 2,
          ingredientsSavedKg: 0.4,
          proteinGrams: 38,
          caloriesKcal: 510,
          ingredients: 'Beef Strips, Onion, Carrot, Garlic',
          notes: 'Used leftover carrots and half an onion from the fridge.',
          status: SavedMealStatus.history,
          isFavorite: true,
        ),
        const SavedMeal(
          id: 4,
          recipeName: 'Garlic Fried Rice',
          cookingTimeMinutes: 15,
          portionsSaved: 3,
          ingredientsSavedKg: 0.6,
          proteinGrams: 21,
          caloriesKcal: 480,
          ingredients: 'Day-old Rice, Egg, Garlic, Scallion',
          notes: 'Crispier when using cold leftover rice.',
          status: SavedMealStatus.history,
        ),
      ];
}
