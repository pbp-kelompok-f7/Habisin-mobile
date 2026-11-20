import 'package:flutter/material.dart';
import 'package:habisin_mobile/main.dart';
import 'package:habisin_mobile/models/plan.dart';
import 'package:habisin_mobile/screens/planner_screen.dart';
import 'package:habisin_mobile/widgets/left_drawer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final weeks = <DateTime, WeeklyPlan>{};

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        title: const Text(
          'Habisin',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      drawer: const LeftDrawer(currentRoute: AppRoutes.home),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
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
                                backgroundColor: colors.secondary,
                                foregroundColor: colors.onSurface,
                              ),
                              onPressed: () => Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlannerScreen(weeks: weeks),
                                ),
                              ),
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: const Text('Buka Meals Planner'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                    side: BorderSide(color: colors.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Meals & History',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Lacak porsi terselamatkan dan riwayat masakan yang sudah dibuat.',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
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
                                foregroundColor: colors.onSurface,
                                side: BorderSide(color: colors.primary),
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
