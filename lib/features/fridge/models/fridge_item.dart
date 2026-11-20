enum FridgeSpace {
  fridge('Fridge'),
  freezer('Freezer'),
  pantry('Pantry');

  const FridgeSpace(this.label);
  final String label;
}

class FridgeItem {
  FridgeItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.space,
    this.expiry,
  });

  final String id;
  final String name;
  final double quantity;
  final String unit;
  final FridgeSpace space;
  final DateTime? expiry;

  int? get daysLeft {
    final e = expiry;
    if (e == null) return null;
    final now = DateTime.now();
    return DateTime(e.year, e.month, e.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }
}
