import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habisin_mobile/main.dart';
import 'package:habisin_mobile/saved_meals/models/saved_meal.dart';
import 'package:habisin_mobile/saved_meals/screens/history_page.dart';
import 'package:habisin_mobile/saved_meals/screens/saved_meals_page.dart';
import 'package:habisin_mobile/saved_meals/widgets/saved_meals_tab_switcher.dart';
import 'package:habisin_mobile/screens/home_screen.dart';

Finder _verticalScrollable() => find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );

void main() {
  group('SavedMeals DRF model parsing', () {
    test('parses SavedMealsOverview payload matching DRF serializer', () {
      final overview = SavedMealsOverview.fromJson({
        'saved_meals': [
          {
            'id': 11,
            'recipe_id': 52772,
            'recipe_name': 'Teriyaki Chicken Casserole',
            'image_url': '',
            'cooking_time_minutes': 30,
            'portions_saved': 2,
            'ingredients_saved_kg': 0.4,
            'protein_grams': 32,
            'calories_kcal': 450,
            'ingredients': 'Chicken, Soy Sauce',
            'notes': '',
            'status': 'SAVED',
            'is_favorite': false,
            'created_at': '2026-11-20T10:00:00Z',
            'updated_at': '2026-11-20T10:00:00Z',
          },
        ],
        'history_meals': [
          {
            'id': 12,
            'recipe_id': null,
            'recipe_name': 'Garlic Fried Rice',
            'image_url': '',
            'cooking_time_minutes': 15,
            'portions_saved': 3,
            'ingredients_saved_kg': 0.6,
            'protein_grams': 21,
            'calories_kcal': 480,
            'ingredients': 'Rice, Garlic, Egg',
            'notes': 'Leftover rice works best',
            'status': 'HISTORY',
            'is_favorite': true,
            'created_at': '2026-11-19T12:00:00Z',
            'updated_at': '2026-11-20T09:00:00Z',
          },
        ],
        'metrics': {
          'total_portions': 3,
          'total_weight': 0.6,
          'recipes_finished': 1,
          'total_protein': 21,
          'total_calories': 480,
        },
      });

      expect(overview.savedMeals, hasLength(1));
      expect(overview.savedMeals.first.recipeName, 'Teriyaki Chicken Casserole');
      expect(overview.savedMeals.first.status, SavedMealStatus.saved);

      expect(overview.historyMeals, hasLength(1));
      expect(overview.historyMeals.first.status, SavedMealStatus.history);
      expect(overview.historyMeals.first.isFavorite, isTrue);

      expect(overview.metrics.totalPortions, 3);
      expect(overview.metrics.totalWeight, 0.6);
      expect(overview.metrics.recipesFinished, 1);
      expect(overview.metrics.totalProtein, 21);
      expect(overview.metrics.totalCalories, 480);
    });
  });

  group('SavedMealsPage and HistoryPage widgets', () {
    testWidgets('SavedMealsPage renders metrics, switcher, and filters items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: SavedMealsPage()),
      );

      expect(find.text('Saved Meals & History'), findsOneWidget);
      expect(find.text('Portions saved'), findsOneWidget);
      expect(find.text('Recipes completed'), findsOneWidget);
      expect(find.text('Protein & calories saved'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Teriyaki Chicken Casserole'),
        200,
        scrollable: _verticalScrollable(),
      );
      expect(find.text('Teriyaki Chicken Casserole'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Leftover Veggie Frittata'),
        200,
        scrollable: _verticalScrollable(),
      );
      expect(find.text('Leftover Veggie Frittata'), findsOneWidget);

      // Scroll back to top so the search field is visible.
      await tester.scrollUntilVisible(
        find.byType(TextField),
        -200,
        scrollable: _verticalScrollable(),
      );
      await tester.enterText(find.byType(TextField), 'Frittata');
      await tester.pumpAndSettle();

      expect(find.text('Leftover Veggie Frittata'), findsOneWidget);
      expect(find.text('Teriyaki Chicken Casserole'), findsNothing);
    });

    testWidgets(
      'HistoryPage renders notes and scales nutrition when editing portions',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HistoryPage(
              initialHistoryMeals: [
                SavedMeal(
                  id: 10,
                  recipeName: 'Cheese Omelet',
                  ingredients: 'Egg, Cheese',
                  cookingTimeMinutes: 15,
                  portionsSaved: 2,
                  ingredientsSavedKg: 0.4,
                  caloriesKcal: 400,
                  proteinGrams: 24,
                  notes: 'Original note',
                  status: SavedMealStatus.history,
                ),
              ],
            ),
          ),
        );

        final editBtn = find.byTooltip('Edit Note & Portions');
        await tester.scrollUntilVisible(
          editBtn,
          200,
          scrollable: _verticalScrollable(),
        );
        await tester.pumpAndSettle();

        expect(find.text('Cheese Omelet'), findsOneWidget);
        expect(find.text('Original note'), findsOneWidget);

        await tester.tap(editBtn);
        await tester.pumpAndSettle();

        expect(find.text('Edit History'), findsOneWidget);

        final dialogFields = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        );
        await tester.enterText(dialogFields.at(0), '4');
        await tester.enterText(dialogFields.at(1), 'Updated 4 portions');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.text('Updated 4 portions'), findsOneWidget);
        expect(find.text('4 portions'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('800kcal'),
          -200,
          scrollable: _verticalScrollable(),
        );
        expect(find.text('800kcal'), findsOneWidget);
        expect(find.text('48g'), findsOneWidget);
      },
    );
  });

  group('Navigation between Home, Saved Meals, and History', () {
    testWidgets('navigates smoothly via LeftDrawer and TabSwitcher', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('Habisin'), findsOneWidget);

      // Home -> Saved Meals via LeftDrawer
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Saved Meals'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SavedMealsPage), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Teriyaki Chicken Casserole'),
        200,
        scrollable: _verticalScrollable(),
      );
      expect(find.text('Teriyaki Chicken Casserole'), findsOneWidget);

      // Saved Meals -> History via Pill TabSwitcher
      final historyPill = find.descendant(
        of: find.byType(SavedMealsTabSwitcher),
        matching: find.text('History'),
      );
      await tester.scrollUntilVisible(
        historyPill,
        -200,
        scrollable: _verticalScrollable(),
      );
      await tester.tap(historyPill);
      await tester.pumpAndSettle();

      expect(find.byType(HistoryPage), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Garlic Fried Rice'),
        200,
        scrollable: _verticalScrollable(),
      );
      expect(find.text('Garlic Fried Rice'), findsOneWidget);

      // History -> Home via LeftDrawer
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Home'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('Habisin'), findsOneWidget);
    });
  });
}
