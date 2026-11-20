import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/planner/models/weekly_plan.dart';
import 'package:habisin_mobile/shared/models/recipe.dart';
import 'package:habisin_mobile/shared/widgets/recipe_thumbnail.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.slot,
    required this.recipe,
    required this.onChoose,
    required this.onRemove,
  });
  final MealSlot slot;
  final MealRecipe? recipe;
  final VoidCallback onChoose;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final meal = recipe;
    final icon = switch (slot) {
      MealSlot.breakfast => Icons.wb_twilight_outlined,
      MealSlot.lunch => Icons.light_mode_outlined,
      MealSlot.dinner => Icons.dark_mode_outlined,
    };
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: colors.onSurfaceVariant, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    slot.label,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (meal != null)
                  IconButton(
                    tooltip: 'Hapus ${slot.label}',
                    onPressed: onRemove,
                    icon: const Icon(Icons.close, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (meal == null)
              Align(
                alignment: Alignment.centerLeft,
                child: Tooltip(
                  message: 'Tambah ${slot.label}',
                  child: TextButton.icon(
                    onPressed: onChoose,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah menu'),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  RecipeThumbnail(recipe: meal, size: 52),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      meal.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Ganti ${slot.label}',
                    child: TextButton(
                      onPressed: onChoose,
                      child: const Text('Ganti'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
