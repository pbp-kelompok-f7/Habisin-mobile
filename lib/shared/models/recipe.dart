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
