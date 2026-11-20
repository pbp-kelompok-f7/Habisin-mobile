import 'package:habisin_mobile/shared/models/recipe.dart';

enum MealType {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snack('Snack');

  const MealType(this.label);
  final String label;
}

enum DiscoverySort {
  bestMatch('Best match'),
  quickest('Quickest'),
  fewestMissing('Fewest missing');

  const DiscoverySort(this.label);
  final String label;
}

class DiscoveryRecipe {
  const DiscoveryRecipe({
    required this.recipe,
    required this.servings,
    required this.mealType,
  });

  final MealRecipe recipe;
  final int servings;
  final MealType mealType;
}

class FridgeIngredient {
  FridgeIngredient(this.name, {this.daysLeft});

  final String name;
  final int? daysLeft;

  bool get expiringSoon => daysLeft != null && daysLeft! <= 3;
}

class RecipeMatch {
  const RecipeMatch(this.entry, this.missing);

  final DiscoveryRecipe entry;
  final List<String> missing;

  MealRecipe get recipe => entry.recipe;
  int get total => recipe.ingredients.length;
  int get have => total - missing.length;
  bool get complete => missing.isEmpty;
}

List<RecipeMatch> discoverRecipes(
  List<DiscoveryRecipe> recipes, {
  required List<FridgeIngredient> fridge,
  required Set<String> selected,
  String query = '',
  MealType? mealType,
  DiscoverySort sort = DiscoverySort.bestMatch,
}) {
  final inFridge = {for (final item in fridge) item.name.toLowerCase()};
  final picked = {for (final name in selected) name.toLowerCase()};
  final terms = query.trim().toLowerCase();

  bool keep(DiscoveryRecipe entry) {
    final recipe = entry.recipe;
    if (mealType != null && entry.mealType != mealType) return false;
    if (picked.isNotEmpty && !recipe.ingredients.any(picked.contains)) {
      return false;
    }
    if (terms.isEmpty) return true;
    return [
      recipe.name,
      ...recipe.ingredients,
    ].join(' ').toLowerCase().contains(terms);
  }

  final matches = [
    for (final entry in recipes.where(keep))
      RecipeMatch(entry, [
        for (final name in entry.recipe.ingredients)
          if (!inFridge.contains(name)) name,
      ]),
  ];

  int byRatio(RecipeMatch a, RecipeMatch b) =>
      (b.have / b.total).compareTo(a.have / a.total);
  int byMissing(RecipeMatch a, RecipeMatch b) =>
      a.missing.length.compareTo(b.missing.length);
  int byMinutes(RecipeMatch a, RecipeMatch b) =>
      (a.recipe.minutes ?? 999).compareTo(b.recipe.minutes ?? 999);

  matches.sort(switch (sort) {
    DiscoverySort.bestMatch => (a, b) {
      final ratio = byRatio(a, b);
      return ratio != 0 ? ratio : byMissing(a, b);
    },
    DiscoverySort.quickest => byMinutes,
    DiscoverySort.fewestMissing => (a, b) {
      final missing = byMissing(a, b);
      return missing != 0 ? missing : byRatio(a, b);
    },
  });
  return matches;
}

List<FridgeIngredient> sampleFridge() => [
  FridgeIngredient('chicken', daysLeft: 2),
  FridgeIngredient('broccoli', daysLeft: 3),
  FridgeIngredient('carrot'),
  FridgeIngredient('potato'),
  FridgeIngredient('bell pepper'),
  FridgeIngredient('garlic'),
  FridgeIngredient('sweet potato'),
  FridgeIngredient('egg', daysLeft: 5),
  FridgeIngredient('brussels sprouts'),
];

const sampleDiscoveryRecipes = [
  DiscoveryRecipe(
    recipe: MealRecipe(
      id: 'chicken-soup',
      name: 'Chicken, Carrot & Potato Soup',
      ingredients: ['chicken', 'carrot', 'potato'],
      minutes: 30,
    ),
    servings: 4,
    mealType: MealType.dinner,
  ),
  DiscoveryRecipe(
    recipe: MealRecipe(
      id: 'garlic-broccoli',
      name: 'Garlic Broccoli Stir-fry',
      ingredients: ['broccoli', 'garlic', 'chicken'],
      minutes: 15,
    ),
    servings: 2,
    mealType: MealType.lunch,
  ),
  DiscoveryRecipe(
    recipe: MealRecipe(
      id: 'chicken-broccoli',
      name: 'Chicken, Broccoli & Garlic Stir-fry',
      ingredients: ['chicken', 'broccoli', 'garlic', 'oyster sauce'],
      minutes: 30,
    ),
    servings: 3,
    mealType: MealType.dinner,
  ),
  DiscoveryRecipe(
    recipe: MealRecipe(
      id: 'pepper-omelette',
      name: 'Yellow Pepper Omelette',
      ingredients: ['egg', 'bell pepper', 'garlic'],
      minutes: 10,
    ),
    servings: 1,
    mealType: MealType.breakfast,
  ),
  DiscoveryRecipe(
    recipe: MealRecipe(
      id: 'perkedel',
      name: 'Potato Perkedel',
      ingredients: ['potato', 'egg', 'spring onion'],
      minutes: 45,
    ),
    servings: 4,
    mealType: MealType.snack,
  ),
  DiscoveryRecipe(
    recipe: MealRecipe(
      id: 'capcay',
      name: 'Capcay Veggie Stir-fry',
      ingredients: ['carrot', 'broccoli', 'cauliflower'],
      minutes: 20,
    ),
    servings: 3,
    mealType: MealType.lunch,
  ),
  DiscoveryRecipe(
    recipe: MealRecipe(
      id: 'brussels-sprouts',
      name: 'Buttery Brussels Sprouts',
      ingredients: ['brussels sprouts', 'garlic', 'butter'],
      minutes: 15,
    ),
    servings: 2,
    mealType: MealType.dinner,
  ),
  DiscoveryRecipe(
    recipe: MealRecipe(
      id: 'sweet-potato',
      name: 'Honey Garlic Sweet Potato',
      ingredients: ['sweet potato', 'garlic', 'honey'],
      minutes: 35,
    ),
    servings: 2,
    mealType: MealType.snack,
  ),
  DiscoveryRecipe(
    recipe: MealRecipe(
      id: 'egg-fried-rice',
      name: 'Egg Fried Rice',
      ingredients: ['rice', 'egg', 'garlic', 'carrot'],
      minutes: 20,
    ),
    servings: 2,
    mealType: MealType.breakfast,
  ),
  DiscoveryRecipe(
    recipe: MealRecipe(
      id: 'chicken-sandwich',
      name: 'Chicken Pepper Sandwich',
      ingredients: ['bread', 'chicken', 'bell pepper', 'mayonnaise'],
      minutes: 10,
    ),
    servings: 2,
    mealType: MealType.lunch,
  ),
];
