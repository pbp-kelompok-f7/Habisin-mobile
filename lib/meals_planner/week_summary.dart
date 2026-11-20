import 'package:flutter/material.dart';

import 'plan.dart';
import 'planner_style.dart';

class WeekSummary extends StatelessWidget {
  const WeekSummary({super.key, required this.plan});

  final WeeklyPlan plan;

  @override
  Widget build(BuildContext context) {
    final ingredients = plan.ingredients;
    final progress = '${plan.total} dari 21';
    final headingStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: plannerInk,
      fontWeight: FontWeight.w700,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: plannerLine),
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
                  style: const TextStyle(
                    color: plannerGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'waktu makan terisi',
                  style: TextStyle(color: plannerMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ExcludeSemantics(
            child: LinearProgressIndicator(
              value: plan.total / 21,
              minHeight: 7,
              color: plannerGreen,
              backgroundColor: plannerCream,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const Divider(height: 34, color: plannerLine),
          Text('Bahan untuk minggu ini', style: headingStyle),
          const SizedBox(height: 10),
          if (ingredients.isEmpty)
            Text(
              plan.total == 0
                  ? 'Pilih menu untuk melihat daftar bahan.'
                  : 'Resep yang dipilih belum mencantumkan bahan.',
              style: const TextStyle(color: plannerMuted),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ingredient in ingredients)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: plannerPeach,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      child: Text(
                        ingredient,
                        style: const TextStyle(color: plannerInk),
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
