import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/planner/models/weekly_plan.dart';
import 'package:habisin_mobile/shared/models/recipe.dart';
import 'package:habisin_mobile/features/planner/screens/recipe_picker.dart';
import 'package:habisin_mobile/features/planner/services/recipe_catalog.dart';
import 'package:habisin_mobile/features/planner/widgets/meal_card.dart';
import 'package:habisin_mobile/features/planner/widgets/week_strip.dart';
import 'package:habisin_mobile/features/planner/widgets/week_summary.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key, required this.weeks});

  // Owned by the home page so returning there keeps this session's menu.
  final Map<DateTime, WeeklyPlan> weeks;

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late DateTime monday;
  late int day;
  List<MealRecipe> recipes = sampleRecipes;
  bool loading = false;
  bool failed = false;

  WeeklyPlan get plan => widget.weeks.putIfAbsent(monday, WeeklyPlan.new);

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    day = today.weekday - 1;
    monday = dayOffset(today, -day);
    if (plannerApiUrl.isNotEmpty) loadCatalog();
  }

  Future<void> loadCatalog() async {
    setState(() {
      loading = true;
      failed = false;
    });
    try {
      final result = await fetchPlannerRecipes(Uri.parse(plannerApiUrl));
      if (mounted) setState(() => recipes = result);
    } on Exception {
      if (mounted) {
        setState(() {
          failed = true;
          recipes = sampleRecipes;
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> chooseMeal(MealSlot slot) async {
    final recipe = await Navigator.push<MealRecipe>(
      context,
      MaterialPageRoute(
        builder: (_) => RecipePicker(
          recipes: recipes,
          dayLabel: dayNames[day],
          slotLabel: slot.label,
        ),
      ),
    );
    if (!mounted || recipe == null) return;
    setState(() => plan.assign(day, slot, recipe));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = dayOffset(monday, day);
    final caption = DateUtils.isSameDay(selected, DateTime.now())
        ? 'Hari ini · ${shortDate(selected)}'
        : '${dayNames[day]} · ${shortDate(selected)}';
    final daily = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          caption,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        for (final slot in MealSlot.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MealCard(
              slot: slot,
              recipe: plan.mealFor(day, slot),
              onChoose: () => chooseMeal(slot),
              onRemove: () => setState(() => plan.remove(day, slot)),
            ),
          ),
      ],
    );
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        title: const Text(
          'Meals Planner',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WeekStrip(
                    monday: monday,
                    day: day,
                    onDay: (index) => setState(() => day = index),
                    onWeek: (direction) => setState(
                      () => monday = dayOffset(monday, 7 * direction),
                    ),
                  ),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(
                        semanticsLabel: 'Memuat katalog resep',
                      ),
                    ),
                  if (failed)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Katalog offline. Resep contoh tersedia.'),
                        TextButton(
                          onPressed: loadCatalog,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 26),
                  LayoutBuilder(
                    builder: (context, bounds) {
                      if (bounds.maxWidth < 720) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            daily,
                            const SizedBox(height: 12),
                            WeekSummary(plan: plan),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: daily),
                          const SizedBox(width: 22),
                          Expanded(flex: 2, child: WeekSummary(plan: plan)),
                        ],
                      );
                    },
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
