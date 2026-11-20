import 'package:flutter/material.dart';

import '../models/saved_meal.dart';
import '../services/saved_meals_endpoints.dart';
import '../theme/saved_meals_colors.dart';
import '../widgets/meal_filter_bar.dart';
import '../widgets/metrics_summary_section.dart';
import '../widgets/saved_meal_card.dart';
import '../widgets/saved_meals_tab_switcher.dart';
import 'history_page.dart';

/// Main Saved Meals page displaying saved recipes, impact metrics, and filters.
class SavedMealsPage extends StatefulWidget {
  final Widget? drawer;
  final VoidCallback? onOpenHistory;
  final List<SavedMeal>? initialSavedMeals;
  final List<SavedMeal>? initialHistoryMeals;

  const SavedMealsPage({
    super.key,
    this.drawer,
    this.onOpenHistory,
    this.initialSavedMeals,
    this.initialHistoryMeals,
  });

  @override
  State<SavedMealsPage> createState() => _SavedMealsPageState();
}

class _SavedMealsPageState extends State<SavedMealsPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<SavedMeal> _savedMeals;
  late List<SavedMeal> _historyMeals;
  String _query = '';
  String _timeFilter = '';
  String _calorieFilter = '';

  @override
  void initState() {
    super.initState();
    _savedMeals = List<SavedMeal>.from(
      widget.initialSavedMeals ?? SavedMealsSampleData.initialSavedMeals(),
    );
    _historyMeals = List<SavedMeal>.from(
      widget.initialHistoryMeals ?? SavedMealsSampleData.initialHistoryMeals(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToHistory() {
    if (widget.onOpenHistory != null) {
      widget.onOpenHistory!();
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => HistoryPage(
          drawer: widget.drawer,
          initialSavedMeals: _savedMeals,
          initialHistoryMeals: _historyMeals,
        ),
      ),
    );
  }

  void _handleMarkDone(SavedMeal meal) {
    // Checkpoint 2 will POST to SavedMealsEndpoints.markMealDone(meal.id).
    setState(() {
      _savedMeals.removeWhere((item) => item.id == meal.id);
      _historyMeals.insert(
        0,
        meal.copyWith(status: SavedMealStatus.history),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${meal.recipeName}" moved to History (API: ${SavedMealsEndpoints.markMealDone(meal.id)})',
        ),
      ),
    );
  }

  void _handleDelete(SavedMeal meal) {
    // Checkpoint 2 will DELETE SavedMealsEndpoints.mealDetail(meal.id).
    setState(() {
      _savedMeals.removeWhere((item) => item.id == meal.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed "${meal.recipeName}" from Saved Meals.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = SavedMealsMetrics.fromHistoryMeals(_historyMeals);
    final filteredMeals = filterMeals(
      _savedMeals,
      query: _query,
      timeFilter: _timeFilter,
      calorieFilter: _calorieFilter,
    );

    return Scaffold(
      backgroundColor: SavedMealsColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Saved Meals'),
        backgroundColor: SavedMealsColors.brandGreenDark,
        foregroundColor: Colors.white,
      ),
      drawer: widget.drawer,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Saved Meals & History',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: SavedMealsColors.headingDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track rescued portions and planned meals',
            style: TextStyle(
              fontSize: 14,
              color: SavedMealsColors.mutedText,
            ),
          ),
          const SizedBox(height: 16),
          MetricsSummarySection(metrics: metrics),
          const SizedBox(height: 18),
          SavedMealsTabSwitcher(
            activeTab: SavedMealsTab.saved,
            onSelectHistory: _navigateToHistory,
          ),
          const SizedBox(height: 14),
          MealFilterBar(
            searchController: _searchController,
            timeFilter: _timeFilter,
            calorieFilter: _calorieFilter,
            onSearchChanged: (value) => setState(() => _query = value),
            onTimeFilterChanged: (value) => setState(() => _timeFilter = value),
            onCalorieFilterChanged: (value) =>
                setState(() => _calorieFilter = value),
          ),
          const SizedBox(height: 16),
          if (filteredMeals.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SavedMealsColors.cardBorder),
              ),
              child: const Center(
                child: Text(
                  'No meals found.',
                  style: TextStyle(
                    fontSize: 14,
                    color: SavedMealsColors.mutedText,
                  ),
                ),
              ),
            )
          else
            ...filteredMeals.map(
              (meal) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SavedMealCard(
                  meal: meal,
                  onMarkDone: () => _handleMarkDone(meal),
                  onDelete: () => _handleDelete(meal),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
