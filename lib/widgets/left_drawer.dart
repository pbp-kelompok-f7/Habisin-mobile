import 'package:flutter/material.dart';

import '../main.dart';
import '../saved_meals/theme/saved_meals_colors.dart';

/// Shared navigation drawer linking the home screen and module pages.
class LeftDrawer extends StatelessWidget {
  final String currentRoute;

  const LeftDrawer({
    super.key,
    required this.currentRoute,
  });

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context);
    if (currentRoute == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: SavedMealsColors.backgroundCream,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: SavedMealsColors.brandGreenDark,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Habisin',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Save ingredients, reduce food waste',
                  style: TextStyle(
                    fontSize: 13,
                    color: SavedMealsColors.brandBeige,
                  ),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.home_outlined,
            label: 'Home',
            selected: currentRoute == AppRoutes.home,
            onTap: () => _navigateTo(context, AppRoutes.home),
          ),
          _DrawerItem(
            icon: Icons.bookmark_added_outlined,
            label: 'Saved Meals',
            selected: currentRoute == AppRoutes.savedMeals,
            onTap: () => _navigateTo(context, AppRoutes.savedMeals),
          ),
          _DrawerItem(
            icon: Icons.history,
            label: 'History',
            selected: currentRoute == AppRoutes.history,
            onTap: () => _navigateTo(context, AppRoutes.history),
          ),
          // TODO (Tim): Tambahkan menu navigasi modul lain di sini.
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected
            ? SavedMealsColors.brandGreenDark
            : SavedMealsColors.brandGreen,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: SavedMealsColors.headingDark,
        ),
      ),
      selected: selected,
      selectedTileColor: SavedMealsColors.brandBeige.withValues(alpha: 0.65),
      onTap: onTap,
    );
  }
}
