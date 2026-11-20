import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/bookmarks/models/bookmarks_store.dart';
import 'package:habisin_mobile/features/discovery/models/discovery.dart';
import 'package:habisin_mobile/features/home/home_screen.dart';

void main() {
  test('discoverRecipes ranks complete fridge matches first', () {
    final matches = discoverRecipes(
      sampleDiscoveryRecipes,
      fridge: sampleFridge(),
      selected: {'chicken'},
    );
    expect(matches, isNotEmpty);
    expect(
      matches.every((m) => m.recipe.ingredients.contains('chicken')),
      isTrue,
    );
    expect(matches.first.complete, isTrue);
    final partial = matches.firstWhere(
      (m) => m.recipe.id == 'chicken-broccoli',
    );
    expect(partial.have, 3);
    expect(partial.missing, ['oyster sauce']);
  });

  test('discoverRecipes filters by meal type, query and sorts quickest', () {
    final quick = discoverRecipes(
      sampleDiscoveryRecipes,
      fridge: sampleFridge(),
      selected: {},
      mealType: MealType.dinner,
      sort: DiscoverySort.quickest,
    );
    expect(quick.every((m) => m.entry.mealType == MealType.dinner), isTrue);
    expect(quick.first.recipe.minutes, 15);

    final none = discoverRecipes(
      sampleDiscoveryRecipes,
      fridge: sampleFridge(),
      selected: {},
      query: 'sushi',
    );
    expect(none, isEmpty);
  });

  testWidgets('Discovery page shows greeting, matches and community card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BookmarksStore.sample();
    await tester.pumpWidget(MaterialApp(home: MyHomePage(bookmarks: store)));

    expect(find.text('Habisin'), findsOneWidget);
    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(find.text('Matches your fridge'), findsOneWidget);
    expect(find.text('Saved Meals & History'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Chicken, Carrot & Potato Soup'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Chicken, Carrot & Potato Soup'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Community Reviews'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Community Reviews'), findsOneWidget);
  });

  testWidgets('Searching with no results shows empty state and clears', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: MyHomePage(bookmarks: BookmarksStore.sample())),
    );

    await tester.enterText(find.byType(TextField), 'sushi');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('No recipes match yet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('No recipes match yet'), findsOneWidget);

    await tester.ensureVisible(find.text('Clear filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('No recipes match yet'), findsNothing);
  });

  testWidgets('Saving a recipe to a category updates the bookmarks store', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = BookmarksStore.sample();
    await tester.pumpWidget(MaterialApp(home: MyHomePage(bookmarks: store)));

    final save = find.byTooltip('Save Chicken, Carrot & Potato Soup');
    await tester.scrollUntilVisible(
      save,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Save to category'), findsOneWidget);

    await tester.tap(find.text('Sarapan'));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final breakfast = store.categories.firstWhere((c) => c.name == 'Sarapan');
    expect(breakfast.recipes.map((r) => r.id), contains('chicken-soup'));
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
