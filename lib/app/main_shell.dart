import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/bookmarks/models/bookmarks_store.dart';
import 'package:habisin_mobile/features/bookmarks/screens/bookmarks_screen.dart';
import 'package:habisin_mobile/features/fridge/screens/fridge_screen.dart';
import 'package:habisin_mobile/features/planner/models/weekly_plan.dart';
import 'package:habisin_mobile/features/home/home_screen.dart';
import 'package:habisin_mobile/features/planner/screens/planner_screen.dart';
import 'package:habisin_mobile/features/saved_meals/screens/saved_meals_page.dart';

const _fridgeTab = 0;
const _recipesTab = 2;

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final weeks = <DateTime, WeeklyPlan>{};
  final bookmarks = BookmarksStore.sample();
  final _navigatorKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());
  int tab = _recipesTab;

  Widget tabNavigator(int index, Widget root) {
    final key = _navigatorKeys[index];
    return NavigatorPopHandler(
      onPopWithResult: (_) => key.currentState!.maybePop(),
      child: Navigator(
        key: key,
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => root),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(
        index: tab,
        children: [
          tabNavigator(0, const FridgeScreen()),
          tabNavigator(1, BookmarksScreen(store: bookmarks)),
          tabNavigator(
            2,
            MyHomePage(
              bookmarks: bookmarks,
              onOpenFridge: () => setState(() => tab = _fridgeTab),
            ),
          ),
          tabNavigator(3, PlannerScreen(weeks: weeks)),
          tabNavigator(4, const SavedMealsPage()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (index) => setState(() => tab = index),
        backgroundColor: colors.surface,
        indicatorColor: colors.primary,
        destinations: [
          for (final (icon, label) in [
            (Icons.kitchen_outlined, 'Fridge'),
            (Icons.bookmark_border, 'Bookmarks'),
            (Icons.rice_bowl_outlined, 'Recipes'),
            (Icons.calendar_month_outlined, 'Planner'),
            (Icons.assignment_turned_in_outlined, 'Saved Meals'),
          ])
            NavigationDestination(
              icon: Icon(icon),
              selectedIcon: Icon(icon, color: colors.onPrimary),
              label: label,
            ),
        ],
      ),
    );
  }
}
