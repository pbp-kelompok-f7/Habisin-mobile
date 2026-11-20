import 'package:flutter/material.dart';
import 'package:habisin_mobile/shared/models/recipe.dart';
import 'package:habisin_mobile/shared/widgets/recipe_thumbnail.dart';

class RecipePicker extends StatefulWidget {
  const RecipePicker({
    super.key,
    required this.recipes,
    required this.slotLabel,
    required this.dayLabel,
  });

  final List<MealRecipe> recipes;
  final String slotLabel;
  final String dayLabel;

  @override
  State<RecipePicker> createState() => _RecipePickerState();
}

class _RecipePickerState extends State<RecipePicker> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    setState(() => _query = '');
  }

  bool _matches(MealRecipe recipe) {
    final terms = _query.trim().toLowerCase().split(RegExp(r'\s+'));
    final searchable = [
      recipe.name,
      ...recipe.ingredients,
    ].join(' ').toLowerCase();
    return terms.every(searchable.contains);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final recipes = widget.recipes.where(_matches).toList();
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Habisin')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Text(
                  widget.dayLabel,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                Semantics(
                  header: true,
                  child: Text(
                    widget.slotLabel,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    labelText: 'Cari resep atau bahan',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (recipes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 36,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty
                              ? 'Belum ada resep yang tersedia.'
                              : 'Tidak ada resep yang cocok.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.onSurface),
                        ),
                        if (_query.isNotEmpty)
                          TextButton(
                            onPressed: _clearSearch,
                            child: const Text('Tampilkan semua resep'),
                          ),
                      ],
                    ),
                  ),
                for (final recipe in recipes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecipeOption(
                      recipe: recipe,
                      onTap: () => Navigator.pop<MealRecipe>(context, recipe),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeOption extends StatelessWidget {
  const _RecipeOption({required this.recipe, required this.onTap});

  final MealRecipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                RecipeThumbnail(recipe: recipe),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colors.onSurface,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 5),
                      if (recipe.minutes != null)
                        Text(
                          '${recipe.minutes} menit',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      if (recipe.ingredients.isNotEmpty)
                        Text(
                          recipe.ingredients.join(', '),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.add_circle_outline,
                  color: colors.onSurface,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
