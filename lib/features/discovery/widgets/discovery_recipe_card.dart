import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/discovery/models/discovery.dart';

class DiscoveryRecipeCard extends StatelessWidget {
  const DiscoveryRecipeCard({
    super.key,
    required this.match,
    required this.saved,
    required this.onSave,
  });

  final RecipeMatch match;
  final bool saved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final metaStyle = TextStyle(color: colors.onSurfaceVariant, fontSize: 13);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 110, child: _MatchPanel(match: match)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.recipe.name,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _MissingText(match: match),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              _Meta(
                                icon: Icons.schedule,
                                label: '${match.recipe.minutes ?? '-'} min',
                                style: metaStyle,
                              ),
                              _Meta(
                                icon: Icons.person_outline,
                                label: '${match.entry.servings} serv.',
                                style: metaStyle,
                              ),
                            ],
                          ),
                        ),
                        IconButton.outlined(
                          tooltip: 'Save ${match.recipe.name}',
                          onPressed: onSave,
                          style: IconButton.styleFrom(
                            backgroundColor: saved
                                ? colors.errorContainer
                                : Colors.white,
                            side: BorderSide(
                              color: saved
                                  ? colors.error
                                  : colors.outlineVariant,
                            ),
                          ),
                          icon: Icon(
                            saved ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: saved ? colors.error : colors.onSurface,
                          ),
                        ),
                      ],
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

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, required this.style});

  final IconData icon;
  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: style.color),
        const SizedBox(width: 3),
        Text(label, style: style),
      ],
    );
  }
}

class _MissingText extends StatelessWidget {
  const _MissingText({required this.match});

  final RecipeMatch match;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = TextStyle(color: colors.onSurfaceVariant, fontSize: 13);
    if (match.complete) {
      return Text("Everything's in your fridge", style: base);
    }
    return Text.rich(
      TextSpan(
        text: 'Missing: ',
        style: base,
        children: [
          TextSpan(
            text: match.missing.join(', '),
            style: TextStyle(color: colors.error, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _MatchPanel extends StatelessWidget {
  const _MatchPanel({required this.match});

  final RecipeMatch match;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final complete = match.complete;
    final badgeFg = complete ? colors.onPrimary : colors.onSecondary;
    return ColoredBox(
      color: colors.primary,
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.restaurant_outlined,
              size: 32,
              color: colors.onPrimary.withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: complete ? colors.onSurface : colors.secondary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (complete) ...[
                    Icon(Icons.check, size: 12, color: badgeFg),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    '${match.have}/${match.total} in fridge',
                    style: TextStyle(
                      color: badgeFg,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
