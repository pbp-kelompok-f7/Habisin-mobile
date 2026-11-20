import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/bookmarks/models/bookmarks_store.dart';
import 'package:habisin_mobile/features/comments/comment.dart';
import 'package:habisin_mobile/features/comments/comments_screen.dart';
import 'package:habisin_mobile/features/discovery/models/discovery.dart';
import 'package:habisin_mobile/features/discovery/widgets/discovery_recipe_card.dart';
import 'package:habisin_mobile/features/discovery/widgets/fridge_ingredients_card.dart';
import 'package:habisin_mobile/features/discovery/widgets/save_to_category_sheet.dart';

const _pageSize = 6;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.bookmarks, this.onOpenFridge});

  final BookmarksStore bookmarks;
  final VoidCallback? onOpenFridge;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final commentsStore = CommentsStore();
  final _search = TextEditingController();
  final fridge = sampleFridge();
  final selected = {'chicken', 'broccoli', 'carrot', 'potato', 'garlic'};
  String query = '';
  MealType? mealType;
  DiscoverySort sort = DiscoverySort.bestMatch;
  int shown = _pageSize;

  @override
  void initState() {
    super.initState();
    widget.bookmarks.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.bookmarks.removeListener(_refresh);
    _search.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void update(VoidCallback change) {
    setState(() {
      change();
      shown = _pageSize;
    });
  }

  void runSearch() {
    FocusScope.of(context).unfocus();
    update(() => query = _search.text);
  }

  void toggleIngredient(String name) {
    update(() {
      if (!selected.remove(name)) selected.add(name);
    });
  }

  void clearFilters() {
    _search.clear();
    update(() {
      query = '';
      mealType = null;
      selected.clear();
    });
  }

  Future<void> addIngredient() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _AddIngredientDialog(),
    );
    if (!mounted || name == null) return;
    final exists = fridge.any((item) => item.name == name);
    update(() {
      if (!exists) fridge.add(FridgeIngredient(name));
      selected.add(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final matches = discoverRecipes(
      sampleDiscoveryRecipes,
      fridge: fridge,
      selected: selected,
      query: query,
      mealType: mealType,
      sort: sort,
    );
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Habisin')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
              children: [
                Text(
                  'Selamat Datang!',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find recipes from ingredients already in your fridge.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                _SearchRow(controller: _search, onSearch: runSearch),
                const SizedBox(height: 16),
                FridgeIngredientsCard(
                  fridge: fridge,
                  selected: selected,
                  onToggle: toggleIngredient,
                  onAdd: addIngredient,
                  onManage: widget.onOpenFridge,
                ),
                const SizedBox(height: 26),
                _MatchesHeader(
                  count: matches.length,
                  sort: sort,
                  onSort: (value) => update(() => sort = value),
                ),
                const SizedBox(height: 12),
                _MealTypeChips(
                  selected: mealType,
                  onSelect: (value) => update(() => mealType = value),
                ),
                const SizedBox(height: 16),
                if (matches.isEmpty)
                  _NoResults(
                    onClear: clearFilters,
                    onUpdateFridge: widget.onOpenFridge,
                  )
                else ...[
                  for (final match in matches.take(shown))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DiscoveryRecipeCard(
                        match: match,
                        saved: widget.bookmarks.isSaved(match.recipe),
                        onSave: () => showSaveToCategorySheet(
                          context,
                          store: widget.bookmarks,
                          recipe: match.recipe,
                        ),
                      ),
                    ),
                  if (widget.onOpenFridge != null)
                    _CantFindCard(onTap: widget.onOpenFridge!),
                  if (matches.length > shown) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => setState(() => shown += _pageSize),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colors.onSurface,
                          side: BorderSide(color: colors.outlineVariant),
                        ),
                        child: const Text('Load more'),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 28),
                _HomeCard(
                  title: 'Community Reviews',
                  subtitle: 'Bagikan tips memasak, variasi bahan sisa, dan sukai ulasan pengguna lain.',
                  action: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.onSurface,
                      foregroundColor: colors.surface,
                    ),
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentsScreen(store: commentsStore),
                      ),
                    ),
                    icon: const Icon(Icons.forum_outlined),
                    label: const Text('Buka Community Reviews'),
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

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.outlineVariant),
    );
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              hintText: 'Search recipes or ingredients',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: border,
              enabledBorder: border,
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: onSearch,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Search'),
        ),
      ],
    );
  }
}

class _MatchesHeader extends StatelessWidget {
  const _MatchesHeader({
    required this.count,
    required this.sort,
    required this.onSort,
  });

  final int count;
  final DiscoverySort sort;
  final ValueChanged<DiscoverySort> onSort;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Matches your fridge',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$count recipes · ${sort.label.toLowerCase()} first',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DiscoverySort>(
              value: sort,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              borderRadius: BorderRadius.circular(12),
              dropdownColor: Colors.white,
              items: [
                for (final option in DiscoverySort.values)
                  DropdownMenuItem(value: option, child: Text(option.label)),
              ],
              onChanged: (value) {
                if (value != null) onSort(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MealTypeChips extends StatelessWidget {
  const _MealTypeChips({required this.selected, required this.onSelect});

  final MealType? selected;
  final ValueChanged<MealType?> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget chip(String label, MealType? value) {
      final active = selected == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: active,
          onSelected: (_) => onSelect(value),
          showCheckmark: false,
          selectedColor: colors.primary,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: active ? colors.onPrimary : colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
          shape: StadiumBorder(
            side: BorderSide(
              color: active ? colors.primary : colors.outlineVariant,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('All', null),
          for (final type in MealType.values) chip(type.label, type),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onClear, this.onUpdateFridge});

  final VoidCallback onClear;
  final VoidCallback? onUpdateFridge;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.search_off, color: colors.onPrimary),
          ),
          const SizedBox(height: 14),
          Text(
            'No recipes match yet',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try other fridge ingredients, a different meal, or another search.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: onClear,
                child: const Text('Clear filters'),
              ),
              if (onUpdateFridge != null)
                OutlinedButton(
                  onPressed: onUpdateFridge,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colors.onSurface,
                    side: BorderSide(color: colors.outlineVariant),
                  ),
                  child: const Text('Update fridge'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CantFindCard extends StatelessWidget {
  const _CantFindCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.kitchen_outlined, color: colors.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Can't find a match?",
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'The more complete your fridge, the sharper the picks.',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: 'Open fridge',
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}

class _AddIngredientDialog extends StatefulWidget {
  const _AddIngredientDialog();

  @override
  State<_AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<_AddIngredientDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void submit() {
    final name = _controller.text.trim().toLowerCase();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add ingredient'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => submit(),
        decoration: const InputDecoration(labelText: 'Ingredient name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: submit, child: const Text('Add')),
      ],
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(color: colors.onSurfaceVariant)),
            const SizedBox(height: 16),
            action,
          ],
        ),
      ),
    );
  }
}
