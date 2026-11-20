import 'package:flutter/material.dart';
import 'package:habisin_mobile/shared/models/recipe.dart';
import 'package:habisin_mobile/shared/widgets/recipe_thumbnail.dart';

class BookmarkCard extends StatelessWidget {
  const BookmarkCard({
    super.key,
    required this.recipe,
    required this.removeLabel,
    required this.onRemove,
  });

  final MealRecipe recipe;
  final String removeLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final metaStyle = TextStyle(color: colors.onSurfaceVariant, fontSize: 13);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeThumbnail(recipe: recipe, size: 88),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  if (recipe.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      recipe.ingredients.join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    children: [
                      _Meta(
                        icon: Icons.shopping_basket_outlined,
                        label: '${recipe.ingredients.length} bahan',
                        style: metaStyle,
                      ),
                      if (recipe.minutes != null)
                        _Meta(
                          icon: Icons.schedule,
                          label: '${recipe.minutes} menit',
                          style: metaStyle,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton.outlined(
              tooltip: removeLabel,
              onPressed: onRemove,
              style: IconButton.styleFrom(
                side: BorderSide(color: colors.outlineVariant),
              ),
              icon: Icon(Icons.close, size: 20, color: colors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, required this.style});

  final IconData icon;
  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: style.color),
        const SizedBox(width: 4),
        Text(label, style: style),
      ],
    );
  }
}
