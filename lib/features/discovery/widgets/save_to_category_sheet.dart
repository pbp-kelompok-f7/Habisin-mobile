import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/bookmarks/models/bookmarks_store.dart';
import 'package:habisin_mobile/features/bookmarks/screens/bookmarks_screen.dart';
import 'package:habisin_mobile/shared/models/recipe.dart';

Future<void> showSaveToCategorySheet(
  BuildContext context, {
  required BookmarksStore store,
  required MealRecipe recipe,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => SaveToCategorySheet(store: store, recipe: recipe),
  );
}

class SaveToCategorySheet extends StatefulWidget {
  const SaveToCategorySheet({
    super.key,
    required this.store,
    required this.recipe,
  });

  final BookmarksStore store;
  final MealRecipe recipe;

  @override
  State<SaveToCategorySheet> createState() => _SaveToCategorySheetState();
}

class _SaveToCategorySheetState extends State<SaveToCategorySheet> {
  late final Set<BookmarkCategory> chosen = {
    for (final category in widget.store.categories)
      if (category.contains(widget.recipe)) category,
  };

  void toggle(BookmarkCategory category) {
    setState(() {
      if (!chosen.remove(category)) chosen.add(category);
    });
  }

  Future<void> createCategory() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          CategoryNameDialog(title: 'New category', store: widget.store),
    );
    if (!mounted || name == null) return;
    setState(() => chosen.add(widget.store.create(name)));
  }

  void save() {
    widget.store.saveTo(widget.recipe, chosen);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Save to category',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              widget.recipe.name,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              'Select categories',
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final category in widget.store.categories)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CategoryOption(
                        category: category,
                        checked: chosen.contains(category),
                        onTap: () => toggle(category),
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: createCategory,
                style: TextButton.styleFrom(foregroundColor: colors.onSurface),
                icon: const Icon(Icons.add),
                label: const Text('New category'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.onSurface,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: colors.outlineVariant),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Save'),
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

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.category,
    required this.checked,
    required this.onTap,
  });

  final BookmarkCategory category;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: CheckboxListTile(
        value: checked,
        onChanged: (_) => onTap(),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: colors.primary,
        title: Text(
          category.name,
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        secondary: Text(
          '${category.recipes.length} recipes',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
        ),
      ),
    );
  }
}
