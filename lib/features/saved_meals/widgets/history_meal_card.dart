import 'package:flutter/material.dart';

import '../models/saved_meal.dart';

/// Card widget representing a completed meal entry with status `HISTORY`.
class HistoryMealCard extends StatelessWidget {
  final SavedMeal meal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HistoryMealCard({
    super.key,
    required this.meal,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    meal.recipeName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${meal.portionsSaved} portions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Ingredients: ${meal.ingredients.isEmpty ? '-' : meal.ingredients}',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${meal.caloriesKcal} kcal \u2022 ${meal.proteinGrams}g protein \u2022 ${meal.cookingTimeMinutes} mins',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Text(
                meal.notes.isEmpty ? 'No personal notes yet.' : meal.notes,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle:
                      meal.notes.isEmpty ? FontStyle.italic : FontStyle.normal,
                  color: meal.notes.isEmpty
                      ? colors.onSurfaceVariant
                      : colors.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Edit Note & Portions',
                  onPressed: onEdit,
                  style: IconButton.styleFrom(
                    backgroundColor: colors.secondary,
                    foregroundColor: colors.onSecondary,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Delete from History',
                  onPressed: onDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: colors.errorContainer,
                    foregroundColor: colors.error,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
