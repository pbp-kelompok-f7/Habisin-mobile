import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habisin_mobile/features/comments/comment.dart';
import 'package:habisin_mobile/main.dart';

void main() {
  test('parses RecipeComment from Django DRF JSON payload', () {
    final comment = RecipeComment.fromJson({
      'id': 42,
      'recipe_id': 52772,
      'user': {
        'id': 7,
        'username': 'melinda',
        'display_name': 'Amelinda Fedora',
        'initials': 'AF',
      },
      'content': 'Ganti seledri pakai daun bawang tetap enak!',
      'created_at': '2026-11-20T14:00:00Z',
      'time_ago': '5 mins ago',
      'like_count': 4,
      'is_liked': true,
      'can_delete': true,
    });

    expect(comment.id, 42);
    expect(comment.recipeId, 52772);
    expect(comment.user.displayName, 'Amelinda Fedora');
    expect(comment.user.initials, 'AF');
    expect(comment.likeCount, 4);
    expect(comment.isLiked, isTrue);
    expect(comment.canDelete, isTrue);
  });

  testWidgets('Open Community Reviews, add comment, like, switch recipe, and delete', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 950));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<void> tap(Finder target) async {
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const MyApp());
    await tap(find.text('Buka Community Reviews'));

    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('Rachel'), findsOneWidget);

    // Submitting empty comment shows validation alert
    await tap(find.byKey(const Key('comment-send-button')));
    expect(find.text('Comment cannot be empty.'), findsOneWidget);

    // Write and send a comment
    await tester.enterText(
      find.byKey(const Key('comment-input')),
      'Bumbu bawang putihnya pas banget!',
    );
    await tester.pumpAndSettle();
    await tap(find.byKey(const Key('comment-send-button')));

    expect(find.text('Bumbu bawang putihnya pas banget!'), findsOneWidget);
    expect(find.text('Amelinda Fedora'), findsOneWidget);

    // Like an existing comment (id 101 has 3 likes initially)
    await tap(find.byKey(const Key('like-comment-101')));
    expect(find.text('4'), findsOneWidget);

    // Delete our newly added comment (id 1000)
    await tap(find.byKey(const Key('delete-comment-1000')));
    expect(find.text('Bumbu bawang putihnya pas banget!'), findsNothing);

    // Switch to empty recipe chip ("Omelet Bayam Keju")
    await tap(find.text('Omelet Bayam Keju'));
    expect(
      find.text(
        'No comments yet. Be the first to share tips for this recipe!',
      ),
      findsOneWidget,
    );
  });
}
