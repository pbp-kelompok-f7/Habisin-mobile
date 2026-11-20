import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/discovery/models/discovery.dart';

class FridgeIngredientsCard extends StatelessWidget {
  const FridgeIngredientsCard({
    super.key,
    required this.fridge,
    required this.selected,
    required this.onToggle,
    required this.onAdd,
    this.onManage,
  });

  final List<FridgeIngredient> fridge;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onAdd;
  final VoidCallback? onManage;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'In your fridge',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (onManage != null)
                  FilledButton.tonalIcon(
                    onPressed: onManage,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.secondary,
                      foregroundColor: colors.onSecondary,
                    ),
                    icon: const Icon(Icons.kitchen_outlined, size: 18),
                    label: const Text('Manage fridge'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                text: "Pick ingredients and we'll find recipes that use them. ",
                style: TextStyle(color: colors.onSurfaceVariant),
                children: [
                  TextSpan(
                    text: 'Red days',
                    style: TextStyle(
                      color: colors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' = expiring soon.'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in fridge)
                  _IngredientChip(
                    item: item,
                    selected: selected.contains(item.name),
                    onTap: () => onToggle(item.name),
                  ),
                ActionChip(
                  onPressed: onAdd,
                  avatar: Icon(Icons.add, size: 18, color: colors.onSurface),
                  label: const Text('Add ingredient'),
                  backgroundColor: colors.surface,
                  shape: StadiumBorder(
                    side: BorderSide(color: colors.outlineVariant),
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

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FridgeIngredient item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final days = item.daysLeft;
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: true,
      checkmarkColor: colors.onSecondary,
      selectedColor: colors.secondary,
      backgroundColor: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? colors.secondary : colors.outlineVariant,
        ),
      ),
      label: Text.rich(
        TextSpan(
          text: _capitalize(item.name),
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
          children: [
            if (days != null)
              TextSpan(
                text: ' · $days days',
                style: TextStyle(
                  fontSize: 12,
                  color: item.expiringSoon
                      ? colors.error
                      : colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
