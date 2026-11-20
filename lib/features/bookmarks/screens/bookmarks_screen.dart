import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/bookmarks/models/bookmarks_store.dart';
import 'package:habisin_mobile/features/bookmarks/widgets/bookmark_card.dart';
import 'package:habisin_mobile/shared/models/recipe.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key, required this.store});

  // Owned by the shell so switching tabs keeps this session's bookmarks.
  final BookmarksStore store;

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _search = TextEditingController();
  BookmarkCategory? selected;
  String query = '';

  BookmarksStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    if (store.categories.isNotEmpty) selected = store.categories.first;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void select(BookmarkCategory category) {
    _search.clear();
    setState(() {
      selected = category;
      query = '';
    });
  }

  void clearSearch() {
    _search.clear();
    setState(() => query = '');
  }

  bool matches(MealRecipe recipe) {
    final terms = query.trim().toLowerCase().split(RegExp(r'\s+'));
    final searchable = [
      recipe.name,
      ...recipe.ingredients,
    ].join(' ').toLowerCase();
    return terms.every(searchable.contains);
  }

  Future<String?> askName({required String title, BookmarkCategory? editing}) {
    return showDialog<String>(
      context: context,
      builder: (_) =>
          _CategoryNameDialog(title: title, store: store, editing: editing),
    );
  }

  Future<void> createCategory() async {
    final name = await askName(title: 'Kategori baru');
    if (!mounted || name == null) return;
    select(store.create(name));
  }

  Future<void> renameCategory(BookmarkCategory category) async {
    final name = await askName(title: 'Ganti nama kategori', editing: category);
    if (!mounted || name == null) return;
    setState(() => store.rename(category, name));
  }

  Future<void> deleteCategory(BookmarkCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus "${category.name}"?'),
        content: Text(
          category.recipes.isEmpty
              ? 'Kategori ini akan dihapus.'
              : 'Kategori ini dan ${category.recipes.length} resep di '
                    'dalamnya akan dihapus dari bookmark.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    store.delete(category);
    _search.clear();
    setState(() {
      selected = store.categories.firstOrNull;
      query = '';
    });
  }

  void removeRecipe(BookmarkCategory category, MealRecipe recipe) {
    final index = category.recipes.indexOf(recipe);
    setState(() => category.recipes.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${recipe.name} dihapus dari ${category.name}.'),
          action: SnackBarAction(
            label: 'Urungkan',
            onPressed: () {
              if (!mounted || !store.categories.contains(category)) return;
              setState(() => category.recipes.insert(index, recipe));
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final category = selected;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        title: const Text(
          'Bookmarks',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
              children: [
                Text(
                  'Resep yang kamu simpan, dikelompokkan per kategori.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                _CategoriesCard(
                  categories: store.categories,
                  selected: category,
                  onSelect: select,
                  onCreate: createCategory,
                ),
                const SizedBox(height: 26),
                if (category != null) ..._categoryContent(category, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _categoryContent(BookmarkCategory category, ColorScheme colors) {
    final recipes = category.recipes.where(matches).toList();
    final count = category.recipes.length;
    return [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    category.name,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '$count resep tersimpan',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton.outlined(
            tooltip: 'Ganti nama kategori',
            onPressed: () => renameCategory(category),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: colors.outlineVariant),
            ),
            icon: Icon(Icons.edit_outlined, color: colors.onSurface),
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            tooltip: 'Hapus kategori',
            onPressed: () => deleteCategory(category),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: colors.outlineVariant),
            ),
            icon: Icon(Icons.delete_outline, color: colors.error),
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (count > 0) ...[
        TextField(
          controller: _search,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            hintText: 'Cari di ${category.name}',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Hapus pencarian',
                    onPressed: clearSearch,
                    icon: const Icon(Icons.close),
                  ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      if (count == 0)
        _EmptyState(
          icon: Icons.bookmark_border,
          message: 'Belum ada resep di kategori ini.',
        )
      else if (recipes.isEmpty)
        _EmptyState(
          icon: Icons.search_off,
          message: 'Tidak ada resep yang cocok.',
          action: TextButton(
            onPressed: clearSearch,
            child: const Text('Tampilkan semua resep'),
          ),
        ),
      for (final recipe in recipes)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BookmarkCard(
            recipe: recipe,
            removeLabel: 'Hapus ${recipe.name} dari ${category.name}',
            onRemove: () => removeRecipe(category, recipe),
          ),
        ),
    ];
  }
}

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard({
    required this.categories,
    required this.selected,
    required this.onSelect,
    required this.onCreate,
  });

  final List<BookmarkCategory> categories;
  final BookmarkCategory? selected;
  final ValueChanged<BookmarkCategory> onSelect;
  final VoidCallback onCreate;

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
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Kategori',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('Baru'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (categories.isEmpty)
              Text(
                'Belum ada kategori. Buat kategori untuk mulai menyimpan resep.',
                style: TextStyle(color: colors.onSurfaceVariant),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _CategoryChip(
                          category: category,
                          selected: category == selected,
                          onTap: () => onSelect(category),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final BookmarkCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: colors.primary,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.name,
            style: TextStyle(
              color: selected ? colors.onPrimary : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${category.recipes.length}',
              style: TextStyle(
                color: colors.onSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, size: 36, color: colors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurface),
          ),
          ?action,
        ],
      ),
    );
  }
}

class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog({
    required this.title,
    required this.store,
    this.editing,
  });

  final String title;
  final BookmarksStore store;
  final BookmarkCategory? editing;

  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
  late final _controller = TextEditingController(text: widget.editing?.name);
  String? error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void submit() {
    final message = widget.store.validateName(
      _controller.text,
      editing: widget.editing,
    );
    if (message != null) {
      setState(() => error = message);
      return;
    }
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: BookmarksStore.maxNameLength,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => submit(),
        decoration: InputDecoration(
          labelText: 'Nama kategori',
          errorText: error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: submit, child: const Text('Simpan')),
      ],
    );
  }
}
