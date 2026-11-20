import 'package:flutter/material.dart';

import 'plan.dart';

const _cream = Color(0xFFF8EEDD);
const _ink = Color(0xFF12372E);
const _muted = Color(0xFF52685C);
const _border = Color(0xFFDFD9CB);

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
    final photo = _photos[recipe.id];
    final imageUri = Uri.tryParse(recipe.imageUrl ?? '');
    const fallback = ColoredBox(
      color: _cream,
      child: Icon(Icons.restaurant_outlined, color: _muted),
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
    final recipes = widget.recipes.where(_matches).toList();
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        foregroundColor: _ink,
        title: const Text('Pilih resep'),
      ),
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
                      ?.copyWith(color: _muted),
                ),
                Semantics(
                  header: true,
                  child: Text(
                    widget.slotLabel,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: _ink, fontWeight: FontWeight.w800),
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
                        const Icon(Icons.search_off, size: 36, color: _muted),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty
                              ? 'Belum ada resep yang tersedia.'
                              : 'Tidak ada resep yang cocok.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: _ink),
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
    return Semantics(
      button: true,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _border),
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
                              color: _ink,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 5),
                      if (recipe.minutes != null)
                        Text(
                          '${recipe.minutes} menit',
                          style: const TextStyle(color: _muted),
                        ),
                      if (recipe.ingredients.isNotEmpty)
                        Text(
                          recipe.ingredients.join(', '),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: _muted),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.add_circle_outline, color: _ink, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
