import 'package:flutter/material.dart';

import '../main.dart';
import '../saved_meals/theme/saved_meals_colors.dart';
import '../widgets/left_drawer.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SavedMealsColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Habisin'),
        backgroundColor: SavedMealsColors.brandGreenDark,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(currentRoute: AppRoutes.home),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: SavedMealsColors.headingDark,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: SavedMealsColors.brandGreen,
                    ),
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.savedMeals,
                    ),
                    icon: const Icon(Icons.bookmark_added_outlined),
                    label: const Text('Saved Meals'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SavedMealsColors.brandGreenDark,
                      side: const BorderSide(
                        color: SavedMealsColors.brandGreen,
                      ),
                    ),
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.history,
                    ),
                    icon: const Icon(Icons.history),
                    label: const Text('History'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
