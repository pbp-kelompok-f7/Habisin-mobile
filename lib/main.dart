import 'package:flutter/material.dart';
import 'package:habisin_mobile/app/main_shell.dart';

abstract final class AppRoutes {
  static const String home = '/';
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E503E),
      primary: const Color(0xFF2E503E),
      onPrimary: Colors.white,
      secondary: const Color(0xFFF8D9A8),
      onSecondary: const Color(0xFF153D32),
      surface: const Color(0xFFFAF1E3),
      onSurface: const Color(0xFF153D32),
      onSurfaceVariant: const Color(0xFF51685B),
      outlineVariant: const Color(0xFFDDD8C9),
    );
    return MaterialApp(
      title: 'Habisin',
      theme: ThemeData(
        colorScheme: scheme,
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const MainShell(),
      },
    );
  }
}
