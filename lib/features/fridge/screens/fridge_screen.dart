import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/fridge/models/fridge_item.dart';
import 'package:habisin_mobile/features/auth/services/auth_service.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  final List<FridgeItem> items = [];
  FridgeSpace space = FridgeSpace.fridge;
  String query = '';

  List<FridgeItem> get visible => items
      .where((i) =>
          i.space == space &&
          i.name.toLowerCase().contains(query.trim().toLowerCase()))
      .toList();

  String get initial {
    final email = AuthService.instance.email;
    return (email == null || email.isEmpty) ? '?' : email[0].toUpperCase();
  }

  Future<void> addItem() async {
    final item = await showModalBottomSheet<FridgeItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => AddItemSheet(space: space),
    );
    if (item != null) setState(() => items.add(item));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final list = visible;
    return Scaffold(
      backgroundColor: colors.surface,
      floatingActionButton: items.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: addItem,
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              tooltip: 'Tambah item',
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, color: colors.primary),
                      const SizedBox(width: 6),
                      Text('Habisin',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface)),
                      const Spacer(),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colors.secondary,
                        child: Text(initial,
                            style: TextStyle(color: colors.onSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('My Fridge',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final s in FridgeSpace.values)
                        ChoiceChip(
                          label: Text(s.label),
                          selected: space == s,
                          showCheckmark: true,
                          selectedColor: colors.secondary,
                          backgroundColor: Colors.white,
                          onSelected: (_) => setState(() => space = s),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (v) => setState(() => query = v),
                    decoration: InputDecoration(
                      hintText: 'Search items',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: list.isEmpty
                        ? _EmptyState(
                            space: space,
                            searching: query.isNotEmpty,
                            onAdd: addItem,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 88),
                            itemCount: list.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (_, i) => _ItemTile(
                              item: list[i],
                              onDelete: () =>
                                  setState(() => items.remove(list[i])),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(
      {required this.space, required this.searching, required this.onAdd});
  final FridgeSpace space;
  final bool searching;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Card(
        color: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(searching
                  ? 'No matching items.'
                  : 'No items in ${space.label} yet.'),
              if (!searching) ...[
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Add your first item'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.onDelete});
  final FridgeItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final days = item.daysLeft;
    final qty = item.quantity % 1 == 0
        ? item.quantity.toInt().toString()
        : item.quantity.toString();
    String? badge;
    Color badgeColor = colors.primary;
    if (days != null) {
      if (days < 0) {
        badge = 'Kedaluwarsa';
        badgeColor = colors.error;
      } else if (days <= 3) {
        badge = days == 0 ? 'Hari ini' : '$days hari lagi';
        badgeColor = Colors.orange.shade800;
      } else {
        badge = '$days hari lagi';
      }
    }
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: colors.error,
            borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.delete_outline, color: colors.onError),
      ),
      child: Card(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        child: ListTile(
          title: Text(item.name,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('$qty ${item.unit}'),
          trailing: badge == null
              ? null
              : Text(badge,
                  style: TextStyle(
                      color: badgeColor, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key, required this.space});
  final FridgeSpace space;

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  String unit = 'pcs';
  DateTime? expiry;
  late FridgeSpace space = widget.space;

  @override
  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: expiry ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (d != null) setState(() => expiry = d);
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      FridgeItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: nameCtrl.text.trim(),
        quantity: double.parse(qtyCtrl.text.replaceAll(',', '.')),
        unit: unit,
        space: space,
        expiry: expiry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          18, 18, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add item',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Nama bahan', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: qtyCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Jumlah', border: OutlineInputBorder()),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                        return (n == null || n <= 0) ? 'Angka > 0' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: unit,
                      decoration: const InputDecoration(
                          labelText: 'Satuan', border: OutlineInputBorder()),
                      items: const ['pcs', 'g', 'kg', 'ml', 'l', 'pack']
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) => setState(() => unit = v ?? unit),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<FridgeSpace>(
                initialValue: space,
                decoration: const InputDecoration(
                    labelText: 'Disimpan di', border: OutlineInputBorder()),
                items: FridgeSpace.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (v) => setState(() => space = v ?? space),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: pickDate,
                icon: const Icon(Icons.event),
                label: Text(expiry == null
                    ? 'Tanggal kedaluwarsa (opsional)'
                    : '${expiry!.day}/${expiry!.month}/${expiry!.year}'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: save,
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
