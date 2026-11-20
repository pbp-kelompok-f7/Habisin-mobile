import 'package:flutter/material.dart';


/// Identifies which page in the Saved Meals & History module is active.
enum SavedMealsTab { saved, history }

/// Pill switcher matching the web tab bar between Saved Meals and History.
class SavedMealsTabSwitcher extends StatelessWidget {
  final SavedMealsTab activeTab;
  final VoidCallback? onSelectSaved;
  final VoidCallback? onSelectHistory;

  const SavedMealsTabSwitcher({
    super.key,
    required this.activeTab,
    this.onSelectSaved,
    this.onSelectHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _TabPillButton(
          label: 'Saved Meals',
          isActive: activeTab == SavedMealsTab.saved,
          onTap: activeTab == SavedMealsTab.saved ? null : onSelectSaved,
        ),
        _TabPillButton(
          label: 'History',
          isActive: activeTab == SavedMealsTab.history,
          onTap: activeTab == SavedMealsTab.history ? null : onSelectHistory,
        ),
      ],
    );
  }
}

class _TabPillButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _TabPillButton({
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: isActive
          ? colors.primary
          : colors.secondary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? colors.onPrimary : colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
