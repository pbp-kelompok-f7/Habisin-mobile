import 'package:flutter/material.dart';
import 'package:habisin_mobile/saved_meals/screens/history_page.dart';
import 'package:habisin_mobile/saved_meals/screens/saved_meals_page.dart';
import 'package:habisin_mobile/screens/home_screen.dart';

/// Named route constants shared across application modules.
abstract final class AppRoutes {
  static const String home = '/';
  static const String savedMeals = '/saved-meals';
  static const String history = '/history';
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habisin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF344C3D),
          secondary: Colors.amber[700],
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const MyHomePage(),
        AppRoutes.savedMeals: (context) => const SavedMealsPage(),
        AppRoutes.history: (context) => const HistoryPage(),
      },
    );
  }
}
