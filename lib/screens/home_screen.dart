import 'package:flutter/material.dart';

import '../meals_planner/plan.dart';
import '../meals_planner/planner_screen.dart';
import '../meals_planner/planner_style.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final weeks = <DateTime, WeeklyPlan>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: plannerCream,
      appBar: AppBar(
        backgroundColor: plannerCream,
        foregroundColor: plannerInk,
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
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  color: plannerGreen,
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
                                backgroundColor: plannerPeach,
                                foregroundColor: plannerInk,
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
          ],
        ),
      ),
    );
  }
}
