import 'package:habisin_mobile/shared/models/recipe.dart';

enum MealSlot {
  breakfast('Sarapan'),
  lunch('Makan siang'),
  dinner('Makan malam');

  const MealSlot(this.label);
  final String label;
}

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
