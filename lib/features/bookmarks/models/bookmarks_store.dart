import 'package:flutter/foundation.dart';
import 'package:habisin_mobile/shared/models/recipe.dart';

class BookmarkCategory {
  BookmarkCategory(this.name, [List<MealRecipe>? recipes])
    : recipes = recipes ?? [];

  String name;
  final List<MealRecipe> recipes;

  bool contains(MealRecipe recipe) => recipes.any((r) => r.id == recipe.id);
}

class BookmarksStore extends ChangeNotifier {
  BookmarksStore(this.categories);

  factory BookmarksStore.sample() => BookmarksStore([
    BookmarkCategory('Siap dimasak', [sampleRecipes[0], sampleRecipes[1]]),
    BookmarkCategory('Sarapan', [sampleRecipes[2]]),
    BookmarkCategory('Makan siang'),
  ]);

  static const maxNameLength = 40;

  final List<BookmarkCategory> categories;

  String? validateName(String name, {BookmarkCategory? editing}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Nama kategori wajib diisi.';
    if (trimmed.length > maxNameLength) {
      return 'Nama kategori maksimal $maxNameLength karakter.';
    }
    final taken = categories.any(
      (category) =>
          category != editing &&
          category.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (taken) return 'Kategori "$trimmed" sudah ada.';
    return null;
  }

  bool isSaved(MealRecipe recipe) => categories.any((c) => c.contains(recipe));

  void saveTo(MealRecipe recipe, Set<BookmarkCategory> chosen) {
    for (final category in categories) {
      category.recipes.removeWhere((r) => r.id == recipe.id);
      if (chosen.contains(category)) category.recipes.add(recipe);
    }
    notifyListeners();
  }

  BookmarkCategory create(String name) {
    final category = BookmarkCategory(name.trim());
    categories.add(category);
    notifyListeners();
    return category;
  }

  void rename(BookmarkCategory category, String name) {
    category.name = name.trim();
    notifyListeners();
  }

  void delete(BookmarkCategory category) {
    categories.remove(category);
    notifyListeners();
  }
}
