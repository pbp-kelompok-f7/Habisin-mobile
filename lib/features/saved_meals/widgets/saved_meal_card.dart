import 'package:flutter/material.dart';

import '../models/saved_meal.dart';

/// Card widget representing a meal with status `SAVED`.
class SavedMealCard extends StatelessWidget {
  final SavedMeal meal;
  final VoidCallback? onMarkDone;
  final VoidCallback? onDelete;

  const SavedMealCard({
    super.key,
    required this.meal,
    this.onMarkDone,
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
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: _MealBannerImage(imageUrl: meal.imageUrl),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${meal.portionsSaved} portions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.recipeName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ingredients: ${meal.ingredients.isEmpty ? '-' : meal.ingredients}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: colors.outlineVariant),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${meal.cookingTimeMinutes} mins',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${meal.caloriesKcal} kcal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${meal.proteinGrams}g protein',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: onDelete,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.errorContainer,
                        foregroundColor: colors.error,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Mark as Done',
                      onPressed: onMarkDone,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.secondary,
                        foregroundColor: colors.primary,
                      ),
                      icon: const Icon(Icons.check, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealBannerImage extends StatelessWidget {
  final String imageUrl;

  const _MealBannerImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return const _ImageFallback();
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.secondary.withValues(alpha: 0.6),
      child: Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 44,
          color: colors.primary,
        ),
      ),
    );
  }
}
