enum MealSlot {
  breakfast('Sarapan'),
  lunch('Makan siang'),
  dinner('Makan malam');

  const MealSlot(this.label);
  final String label;
}

class MealRecipe {
  const MealRecipe({
    required this.id,
    required this.name,
    required this.ingredients,
    this.minutes,
    this.imageUrl,
  });

  factory MealRecipe.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final ingredients = json['ingredients'];
    final minutes = json['minutes'];
    final imageUrl = json['image_url'];
    if (id is! String ||
        id.trim().isEmpty ||
        name is! String ||
        name.trim().isEmpty) {
      throw const FormatException('Recipe is missing its id or name.');
    }
    if (ingredients is! List || ingredients.any((item) => item is! String)) {
      throw const FormatException(
        'Recipe ingredients must be a list of names.',
      );
    }
    if ((minutes != null && minutes is! int) ||
        (imageUrl != null && imageUrl is! String)) {
      throw const FormatException('Invalid recipe duration or image URL.');
    }
    return MealRecipe(
      id: id,
      name: name,
      ingredients: List<String>.unmodifiable(ingredients.cast<String>()),
      minutes: minutes as int?,
      imageUrl: imageUrl as String?,
    );
  }

  final String id;
  final String name;
  final List<String> ingredients;
  final int? minutes;
  final String? imageUrl;
}

const sampleRecipes = [
  MealRecipe(
    id: 'soup',
    name: 'Sup Ayam Wortel Kentang',
    ingredients: ['ayam', 'wortel', 'kentang', 'bawang putih', 'seledri'],
    minutes: 30,
  ),
  MealRecipe(
    id: 'fried-rice',
    name: 'Nasi Goreng Sisa Sayur',
    ingredients: ['nasi', 'wortel', 'telur', 'bawang putih', 'kecap manis'],
    minutes: 20,
  ),
  MealRecipe(
    id: 'omelet',
    name: 'Omelet Bayam Keju',
    ingredients: ['telur', 'bayam', 'keju'],
    minutes: 15,
  ),
];

/// Days are indexed from Monday (0) to Sunday (6).
class WeeklyPlan {
  final _days = List.generate(7, (_) => <MealSlot, MealRecipe>{});

  MealRecipe? mealFor(int day, MealSlot slot) => _days[day][slot];

  void assign(int day, MealSlot slot, MealRecipe recipe) {
    _days[day][slot] = recipe;
  }

  void remove(int day, MealSlot slot) {
    _days[day].remove(slot);
  }

  int countFor(int day) => _days[day].length;

  int get total => _days.fold(0, (count, meals) => count + meals.length);

  List<String> get ingredients {
    final needed = <String>{};
    for (final meals in _days) {
      for (final recipe in meals.values) {
        needed.addAll(recipe.ingredients);
      }
    }
    return needed.toList();
  }
}
