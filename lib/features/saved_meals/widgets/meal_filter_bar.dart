import 'package:flutter/material.dart';

import '../models/saved_meal.dart';

/// Applies the same search, time, and calorie filters as Django's `_filter_user_meals`.
List<SavedMeal> filterMeals(
  List<SavedMeal> meals, {
  String query = '',
  String timeFilter = '',
  String calorieFilter = '',
}) {
  final normalizedQuery = query.trim().toLowerCase();

  return meals.where((meal) {
    if (normalizedQuery.isNotEmpty) {
      final matchesText =
          meal.recipeName.toLowerCase().contains(normalizedQuery) ||
              meal.ingredients.toLowerCase().contains(normalizedQuery) ||
              meal.notes.toLowerCase().contains(normalizedQuery);
      if (!matchesText) return false;
    }

    switch (timeFilter) {
      case 'quick':
        if (meal.cookingTimeMinutes > 20) return false;
      case 'medium':
        if (meal.cookingTimeMinutes <= 20 || meal.cookingTimeMinutes > 35) {
          return false;
        }
      case 'long':
        if (meal.cookingTimeMinutes <= 35) return false;
    }

    switch (calorieFilter) {
      case 'low':
        if (meal.caloriesKcal > 350) return false;
      case 'medium':
        if (meal.caloriesKcal <= 350 || meal.caloriesKcal > 500) return false;
      case 'high':
        if (meal.caloriesKcal <= 500) return false;
    }

    return true;
  }).toList();
}

/// Shared search input and time/calorie dropdowns for Saved Meals and History.
class MealFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String timeFilter;
  final String calorieFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onTimeFilterChanged;
  final ValueChanged<String> onCalorieFilterChanged;

  const MealFilterBar({
    super.key,
    required this.searchController,
    required this.timeFilter,
    required this.calorieFilter,
    required this.onSearchChanged,
    required this.onTimeFilterChanged,
    required this.onCalorieFilterChanged,
  });

  InputDecoration _pillDecoration(
    ColorScheme colors, {
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(
          color: colors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: _pillDecoration(
            colors,
            hintText: 'Search meals / ingredients...',
            prefixIcon: Icon(
              Icons.search,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: timeFilter,
                isExpanded: true,
                decoration: _pillDecoration(colors),
                items: const [
                  DropdownMenuItem(value: '', child: Text('All Times')),
                  DropdownMenuItem(
                    value: 'quick',
                    child: Text('Quick (<= 20m)'),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Text('Medium (21-35m)'),
                  ),
                  DropdownMenuItem(
                    value: 'long',
                    child: Text('Long (> 35m)'),
                  ),
                ],
                onChanged: (value) => onTimeFilterChanged(value ?? ''),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: calorieFilter,
                isExpanded: true,
                decoration: _pillDecoration(colors),
                items: const [
                  DropdownMenuItem(value: '', child: Text('All Calories')),
                  DropdownMenuItem(
                    value: 'low',
                    child: Text('Low (<= 350)'),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Text('Med (351-500)'),
                  ),
                  DropdownMenuItem(
                    value: 'high',
                    child: Text('High (> 500)'),
                  ),
                ],
                onChanged: (value) => onCalorieFilterChanged(value ?? ''),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
