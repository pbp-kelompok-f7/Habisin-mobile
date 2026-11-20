import 'package:flutter/material.dart';

import '../../main.dart';
import '../../widgets/left_drawer.dart';
import '../models/saved_meal.dart';
import '../services/saved_meals_endpoints.dart';
import '../theme/saved_meals_colors.dart';
import '../widgets/history_meal_card.dart';
import '../widgets/meal_filter_bar.dart';
import '../widgets/metrics_summary_section.dart';
import '../widgets/saved_meals_tab_switcher.dart';

/// Cooking History page displaying completed meals, personal notes, and edit actions.
class HistoryPage extends StatefulWidget {
  final Widget? drawer;
  final VoidCallback? onOpenSaved;
  final List<SavedMeal>? initialHistoryMeals;

  const HistoryPage({
    super.key,
    this.drawer,
    this.onOpenSaved,
    this.initialHistoryMeals,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<SavedMeal> _historyMeals;
  String _query = '';
  String _timeFilter = '';
  String _calorieFilter = '';

  @override
  void initState() {
    super.initState();
    _historyMeals = List<SavedMeal>.from(
      widget.initialHistoryMeals ?? SavedMealsSampleData.initialHistoryMeals(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToSavedMeals() {
    if (widget.onOpenSaved != null) {
      widget.onOpenSaved!();
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.savedMeals);
  }

  Future<void> _openEditDialog(SavedMeal meal) async {
    final portionsController = TextEditingController(
      text: '${meal.portionsSaved}',
    );
    final notesController = TextEditingController(text: meal.notes);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit History'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal.recipeName,
                style: const TextStyle(
                  fontSize: 13,
                  color: SavedMealsColors.mutedText,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: portionsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Portions (auto-scales nutrition)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Personal Notes',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SavedMealsColors.brandGreen,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      portionsController.dispose();
      notesController.dispose();
      return;
    }

    final parsedPortions = int.tryParse(portionsController.text.trim()) ??
        meal.portionsSaved;
    final newPortions = parsedPortions < 1 ? 1 : parsedPortions;
    final oldPortions = meal.portionsSaved < 1 ? 1 : meal.portionsSaved;

    // Proportional scaling matching Django's `scale_nutrition` helper.
    final scaledCalories =
        ((meal.caloriesKcal / oldPortions) * newPortions).round().clamp(10, 99999);
    final scaledProtein =
        ((meal.proteinGrams / oldPortions) * newPortions).round().clamp(0, 99999);
    final scaledWeight = double.parse((newPortions * 0.2).toStringAsFixed(1));
    final updatedNote = notesController.text.trim();

    portionsController.dispose();
    notesController.dispose();

    // Checkpoint 2 will PATCH SavedMealsEndpoints.historyDetail(meal.id).
    setState(() {
      final index = _historyMeals.indexWhere((item) => item.id == meal.id);
      if (index != -1) {
        _historyMeals[index] = meal.copyWith(
          portionsSaved: newPortions,
          ingredientsSavedKg: scaledWeight,
          caloriesKcal: scaledCalories,
          proteinGrams: scaledProtein,
          notes: updatedNote,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Updated "${meal.recipeName}" (API: ${SavedMealsEndpoints.historyDetail(meal.id)})',
        ),
      ),
    );
  }

  void _handleDelete(SavedMeal meal) {
    // Checkpoint 2 will DELETE SavedMealsEndpoints.historyDetail(meal.id).
    setState(() {
      _historyMeals.removeWhere((item) => item.id == meal.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted "${meal.recipeName}" from History.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = SavedMealsMetrics.fromHistoryMeals(_historyMeals);
    final filteredMeals = filterMeals(
      _historyMeals,
      query: _query,
      timeFilter: _timeFilter,
      calorieFilter: _calorieFilter,
    );

    return Scaffold(
      backgroundColor: SavedMealsColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Cooking History'),
        backgroundColor: SavedMealsColors.brandGreenDark,
        foregroundColor: Colors.white,
      ),
      drawer: widget.drawer ?? const LeftDrawer(currentRoute: AppRoutes.history),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Cooking History',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: SavedMealsColors.headingDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Review completed meals, portions, and personal notes',
            style: TextStyle(
              fontSize: 14,
              color: SavedMealsColors.mutedText,
            ),
          ),
          const SizedBox(height: 16),
          MetricsSummarySection(metrics: metrics),
          const SizedBox(height: 18),
          SavedMealsTabSwitcher(
            activeTab: SavedMealsTab.history,
            onSelectSaved: _navigateToSavedMeals,
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
                  'No cooking history yet.',
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
                child: HistoryMealCard(
                  meal: meal,
                  onEdit: () => _openEditDialog(meal),
                  onDelete: () => _handleDelete(meal),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
