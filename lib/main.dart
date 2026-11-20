import 'package:material_ui/material_ui.dart';
import 'package:habisin_mobile/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habisin',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color(0xFF2E503E),
          primary: const Color(0xFF2E503E),
          onPrimary: Colors.white,
          secondary: const Color(0xFFF8D9A8),
          onSecondary: const Color(0xFF153D32),
          surface: const Color(0xFFFAF1E3),
          onSurface: const Color(0xFF153D32),
          onSurfaceVariant: const Color(0xFF51685B),
          outlineVariant: const Color(0xFFDDD8C9),
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}
