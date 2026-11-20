import 'package:flutter/material.dart';

import 'package:habisin_mobile/features/planner/models/weekly_plan.dart';

class WeekSummary extends StatelessWidget {
  const WeekSummary({super.key, required this.plan});

  final WeeklyPlan plan;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ingredients = plan.ingredients;
    final progress = '${plan.total} dari 21';
    final headingStyle = Theme.of(context).textTheme.titleMedium
        ?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w700);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progres minggu ini', style: headingStyle),
          const SizedBox(height: 6),
          Semantics(
            label: '$progress waktu makan terisi',
            excludeSemantics: true,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 6,
              children: [
                Text(
                  progress,
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'waktu makan terisi',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ExcludeSemantics(
            child: LinearProgressIndicator(
              value: plan.total / 21,
              minHeight: 7,
              color: colors.primary,
              backgroundColor: colors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Divider(height: 34, color: colors.outlineVariant),
          Text('Bahan untuk minggu ini', style: headingStyle),
          const SizedBox(height: 10),
          if (ingredients.isEmpty)
            Text(
              plan.total == 0
                  ? 'Pilih menu untuk melihat daftar bahan.'
                  : 'Resep yang dipilih belum mencantumkan bahan.',
              style: TextStyle(color: colors.onSurfaceVariant),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ingredient in ingredients)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      child: Text(
                        ingredient,
                        style: TextStyle(color: colors.onSurface),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
