import 'package:flutter/material.dart';

feature/comments
import '../comments/comment.dart';
import '../comments/comments_screen.dart';
import '../meals_planner/plan.dart';
import '../meals_planner/planner_screen.dart';
import '../meals_planner/planner_style.dart';

import '../main.dart';
import '../saved_meals/theme/saved_meals_colors.dart';
import '../widgets/left_drawer.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

import 'package:habisin_mobile/models/plan.dart';
import 'package:habisin_mobile/screens/planner_screen.dart';
main

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final weeks = <DateTime, WeeklyPlan>{};
  final commentsStore = CommentsStore();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: SavedMealsColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Habisin'),
        backgroundColor: SavedMealsColors.brandGreenDark,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(currentRoute: AppRoutes.home),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: SavedMealsColors.headingDark,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: SavedMealsColors.brandGreen,
                    ),
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.savedMeals,
                    ),
                    icon: const Icon(Icons.bookmark_added_outlined),
                    label: const Text('Saved Meals'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SavedMealsColors.brandGreenDark,
                      side: const BorderSide(
                        color: SavedMealsColors.brandGreen,
                      ),
                    ),
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.history,
                    ),
                    icon: const Icon(Icons.history),
                    label: const Text('History'),
                  ),
                ],
              ),
            ],
          ),
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        title: const Text(
          'Habisin',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
feature/comments
                child: Column(
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      color: plannerGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),

                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  color: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        'assets/meals/soup.png',
                        height: 192,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
main
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.asset(
                            'assets/meals/soup.png',
                            height: 192,
                            fit: BoxFit.cover,
                            excludeFromSemantics: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Meals Planner',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Susun menu seminggu dan lihat bahan yang perlu disiapkan.',
                                  style: TextStyle(
                                    color: Color(0xFFF2EADB),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: plannerPeach,
                                    foregroundColor: plannerInk,
                                  ),
                                  onPressed: () => Navigator.push<void>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PlannerScreen(weeks: weeks),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.calendar_month_outlined,
                                  ),
                                  label: const Text('Buka Meals Planner'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                        side: const BorderSide(color: plannerLine),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Community Reviews',
                              style: TextStyle(
                                color: plannerInk,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Bagikan tips memasak, variasi bahan sisa, dan sukai ulasan pengguna lain.',
                              style: TextStyle(
                                color: plannerMuted,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
feature/comments
                                backgroundColor: plannerInk,
                                foregroundColor: plannerCream,

                                backgroundColor: colors.secondary,
                                foregroundColor: colors.onSurface,
main
                              ),
                              onPressed: () => Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CommentsScreen(store: commentsStore),
                                ),
                              ),
                              icon: const Icon(Icons.forum_outlined),
                              label: const Text('Buka Community Reviews'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
