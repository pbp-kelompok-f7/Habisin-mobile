import 'package:flutter/material.dart';
import 'package:habisin_mobile/shared/models/recipe.dart';

class RecipeThumbnail extends StatelessWidget {
  const RecipeThumbnail({super.key, required this.recipe, this.size = 76});

  final MealRecipe recipe;
  final double size;

  static const _photos = {
    'soup': 'soup',
    'chicken-soup': 'soup',
    'fried-rice': 'fried-rice',
    'omelet': 'omelet',
    'spinach-omelet': 'omelet',
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final photo = _photos[recipe.id];
    final imageUri = Uri.tryParse(recipe.imageUrl ?? '');
    final fallback = ColoredBox(
      color: colors.surface,
      child: Icon(Icons.restaurant_outlined, color: colors.onSurfaceVariant),
    );
    Widget image = fallback;
    if (photo != null) {
      image = Image.asset('assets/meals/$photo.png', fit: BoxFit.cover);
    } else if (imageUri != null &&
        imageUri.hasAuthority &&
        (imageUri.scheme == 'https' || imageUri.scheme == 'http')) {
      image = Image.network(
        imageUri.toString(),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox.square(dimension: size, child: image),
      ),
    );
  }
}
