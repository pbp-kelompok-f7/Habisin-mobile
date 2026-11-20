import 'package:flutter/material.dart';
import 'package:habisin_mobile/models/plan.dart';
import 'package:habisin_mobile/screens/home_screen.dart';
import 'package:habisin_mobile/screens/planner_screen.dart';

const _recipesTab = 2;
const _plannerTab = 3;

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final weeks = <DateTime, WeeklyPlan>{};
  final _homeKey = GlobalKey<NavigatorState>();
  final _plannerKey = GlobalKey<NavigatorState>();
  int tab = _recipesTab;

  void selectTab(int index) {
    setState(() => tab = index == _recipesTab ? _recipesTab : _plannerTab);
  }

  Widget tabNavigator(GlobalKey<NavigatorState> key, Widget root) {
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
        index: tab == _recipesTab ? 0 : 1,
        children: [
          tabNavigator(_homeKey, const MyHomePage()),
          tabNavigator(_plannerKey, PlannerScreen(weeks: weeks)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: selectTab,
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
