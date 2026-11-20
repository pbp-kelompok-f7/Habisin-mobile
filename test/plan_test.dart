import 'package:flutter_test/flutter_test.dart';
import 'package:habisin_mobile/meals_planner/plan.dart';

void main() {
  final soup = sampleRecipes[0];
  final friedRice = sampleRecipes[1];
  final omelet = sampleRecipes[2];

  test('reads saved Django recipes without requiring cooking time', () {
    final recipe = MealRecipe.fromJson({
      'id': 'mealdb:123',
      'name': 'Chicken soup',
      'ingredients': ['chicken', 'carrot'],
      'image_url': 'https://example.org/soup.png',
      'saved': true,
    });
    expect(recipe.id, 'mealdb:123');
    expect(recipe.ingredients, ['chicken', 'carrot']);
    expect(recipe.minutes, isNull);
    expect(recipe.imageUrl, 'https://example.org/soup.png');
    expect(
      () => MealRecipe.fromJson({'id': 'mealdb:123', 'name': 'Chicken soup'}),
      throwsFormatException,
    );
  });

  test('replacing or clearing a slot recomputes the weekly shopping list', () {
    final plan = WeeklyPlan();
    plan.assign(0, MealSlot.lunch, soup);
    plan.assign(6, MealSlot.dinner, friedRice);

    expect(plan.countFor(0), 1);
    expect(plan.countFor(6), 1);
    expect(plan.ingredients.where((item) => item == 'wortel'), hasLength(1));

    plan.assign(0, MealSlot.lunch, omelet);
    expect(plan.total, 2);
    expect(plan.mealFor(0, MealSlot.lunch), same(omelet));
    expect(plan.ingredients, isNot(contains('ayam')));
    expect(plan.ingredients, containsAll(['telur', 'bayam', 'wortel']));

    plan.remove(6, MealSlot.dinner);
    plan.remove(6, MealSlot.dinner);
    expect(plan.mealFor(6, MealSlot.dinner), isNull);
    expect(plan.total, 1);
    expect(plan.ingredients, unorderedEquals(omelet.ingredients));
  });

  test('all 21 slots can be scheduled independently for each plan', () {
    final plan = WeeklyPlan();
    for (var day = 0; day < 7; day++) {
      for (final slot in MealSlot.values) {
        plan.assign(day, slot, soup);
      }
    }

    expect(plan.total, 21);
    expect(plan.countFor(3), 3);
    expect(plan.ingredients, unorderedEquals(soup.ingredients));
    expect(WeeklyPlan().total, 0);

    plan.remove(3, MealSlot.breakfast);
    expect(plan.total, 20);
    expect(plan.countFor(3), 2);
    expect(plan.mealFor(3, MealSlot.lunch), same(soup));
  });
}
