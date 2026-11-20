import 'package:flutter/material.dart';

import '../models/saved_meal.dart';
import '../theme/saved_meals_colors.dart';

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
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: SavedMealsColors.cardBorder),
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
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: SavedMealsColors.headingDark,
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
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: SavedMealsColors.headingDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ingredients: ${meal.ingredients.isEmpty ? '-' : meal.ingredients}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: SavedMealsColors.mutedText,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF3EFE6)),
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
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: SavedMealsColors.mutedText,
                            ),
                          ),
                          Text(
                            '${meal.caloriesKcal} kcal',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: SavedMealsColors.mutedText,
                            ),
                          ),
                          Text(
                            '${meal.proteinGrams}g protein',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: SavedMealsColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: onDelete,
                      style: IconButton.styleFrom(
                        backgroundColor: SavedMealsColors.deleteBg,
                        foregroundColor: SavedMealsColors.deleteFg,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Mark as Done',
                      onPressed: onMarkDone,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFE6F4EA),
                        foregroundColor: SavedMealsColors.brandGreen,
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
    return Container(
      color: SavedMealsColors.brandBeige.withValues(alpha: 0.6),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 44,
          color: SavedMealsColors.brandGreen,
        ),
      ),
    );
  }
}
