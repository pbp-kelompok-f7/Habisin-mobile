import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/comments/comment.dart';
import 'package:habisin_mobile/features/comments/comments_screen.dart';
import 'package:habisin_mobile/main.dart';
import 'package:habisin_mobile/shared/widgets/left_drawer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final commentsStore = CommentsStore();

  void openRoute(String route) {
    Navigator.of(context, rootNavigator: true).pushReplacementNamed(route);
  }

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
            Text(
              'Selamat Datang!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _HomeCard(
              title: 'Community Reviews',
              subtitle: 'Bagikan tips memasak, variasi bahan sisa, dan sukai ulasan pengguna lain.',
              actions: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.onSurface,
                    foregroundColor: colors.surface,
                  ),
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsScreen(store: commentsStore),
                    ),
                  ),
                  icon: const Icon(Icons.forum_outlined),
                  label: const Text('Buka Community Reviews'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _HomeCard(
              title: 'Saved Meals & History',
              subtitle: 'Lacak porsi terselamatkan dan riwayat masakan yang sudah dibuat.',
              actions: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  onPressed: () => openRoute(AppRoutes.savedMeals),
                  icon: const Icon(Icons.bookmark_added_outlined),
                  label: const Text('Saved Meals'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.onSurface,
                    side: BorderSide(color: colors.primary),
                  ),
                  onPressed: () => openRoute(AppRoutes.history),
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
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
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(spacing: 12, runSpacing: 12, children: actions),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
