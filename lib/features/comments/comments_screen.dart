import 'package:flutter/material.dart';

import 'comment.dart';
import 'comments_api.dart';

const _commentLikeOrange = Color(0xFFF0531C);
const _commentInputBg = Color(0xFFF7EDDA);
const _commentInputBorder = Color(0xFFECDCC0);
const _commentAlertBg = Color(0xFFFDE3D8);
const _commentAlertFg = Color(0xFF8A2B0B);

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({
    super.key,
    required this.store,
    this.initialRecipeId,
    this.apiUrl = commentsApiUrl,
  });

  final CommentsStore store;
  final int? initialRecipeId;
  final String apiUrl;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  static const int _initialCommentCount = 5;

  late int _selectedRecipeId;
  final TextEditingController _commentController = TextEditingController();
  bool _showAll = false;
  bool _loading = false;
  bool _offlineFallback = false;
  String? _errorMessage;

  CommunityRecipe get _selectedRecipe => sampleCommunityRecipes.firstWhere(
    (r) => r.recipeId == _selectedRecipeId,
    orElse: () => sampleCommunityRecipes.first,
  );

  String? get _activeToken {
    final storeToken = widget.store.authToken;
    if (storeToken != null && storeToken.trim().isNotEmpty) {
      return storeToken.trim();
    }
    if (commentsAuthToken.trim().isNotEmpty) {
      return commentsAuthToken.trim();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _selectedRecipeId =
        widget.initialRecipeId ?? sampleCommunityRecipes.first.recipeId;
    if (widget.apiUrl.isNotEmpty) {
      _loadFromApi();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadFromApi() async {
    setState(() {
      _loading = true;
      _offlineFallback = false;
      _errorMessage = null;
    });
    try {
      final remote = await fetchRecipeComments(
        widget.apiUrl,
        _selectedRecipeId,
        token: _activeToken,
      );
      if (!mounted) return;
      setState(() {
        widget.store.replaceComments(_selectedRecipeId, remote);
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _offlineFallback = true;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _selectRecipe(int recipeId) {
    if (_selectedRecipeId == recipeId) return;
    setState(() {
      _selectedRecipeId = recipeId;
      _showAll = false;
      _errorMessage = null;
    });
    if (widget.apiUrl.isNotEmpty) {
      _loadFromApi();
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'Comment cannot be empty.');
      return;
    }
    if (text.length > 1000) {
      setState(() => _errorMessage = 'Comment cannot exceed 1000 characters.');
      return;
    }

    setState(() => _errorMessage = null);
    final token = _activeToken;

    if (widget.apiUrl.isNotEmpty && token != null && !_offlineFallback) {
      try {
        final created = await postRecipeComment(
          widget.apiUrl,
          _selectedRecipeId,
          text,
          token: token,
        );
        if (!mounted) return;
        setState(() {
          widget.store.upsertServerComment(_selectedRecipeId, created);
          _commentController.clear();
        });
        FocusScope.of(context).unfocus();
        return;
      } on Exception {
        if (!mounted) return;
      }
    }

    setState(() {
      widget.store.addLocalComment(_selectedRecipeId, text);
      _commentController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _toggleLike(RecipeComment comment) async {
    final token = _activeToken;
    if (widget.apiUrl.isNotEmpty && token != null && !_offlineFallback) {
      try {
        final updated = await toggleCommentLike(
          widget.apiUrl,
          comment.id,
          token: token,
        );
        if (!mounted) return;
        setState(() {
          widget.store.upsertServerComment(_selectedRecipeId, updated);
        });
        return;
      } on Exception {
        if (!mounted) return;
      }
    }
    setState(() {
      widget.store.toggleLocalLike(_selectedRecipeId, comment.id);
    });
  }

  Future<void> _deleteComment(RecipeComment comment) async {
    final token = _activeToken;
    if (widget.apiUrl.isNotEmpty && token != null && !_offlineFallback) {
      try {
        await deleteRecipeComment(widget.apiUrl, comment.id, token: token);
      } on Exception {
        if (!mounted) return;
      }
    }
    setState(() {
      widget.store.deleteLocalComment(_selectedRecipeId, comment.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final allComments = widget.store.commentsFor(_selectedRecipeId);
    final shownComments = _showAll
        ? allComments
        : allComments.take(_initialCommentCount).toList();
    final hasMore = allComments.length > shownComments.length;
    final currentUser = widget.store.currentUser;
    final hasDraft = _commentController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        title: const Text(
          'Community Reviews',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RecipeSelectorHeader(
                    recipes: sampleCommunityRecipes,
                    selected: _selectedRecipe,
                    onSelect: _selectRecipe,
                  ),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(
                        semanticsLabel: 'Memuat komentar resep',
                      ),
                    ),
                  if (_offlineFallback)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Server komentar offline. Menampilkan komentar lokal.',
                          ),
                          TextButton(
                            onPressed: _loadFromApi,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Heading: Comments + count badge
                  Row(
                    children: [
                      Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        key: const Key('comment-count-badge'),
                        constraints: const BoxConstraints(minWidth: 28),
                        height: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${allComments.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _commentAlertBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: _commentAlertFg,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Compose card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _UserAvatar(user: currentUser, isCurrentUser: true),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Write a comment',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                key: const Key('comment-input'),
                                controller: _commentController,
                                minLines: 3,
                                maxLines: 5,
                                maxLength: 1000,
                                onChanged: (_) => setState(() {}),
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 15,
                                  height: 1.45,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Share your tips or ingredient variations...',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF8A8A7F),
                                  ),
                                  counterText: '',
                                  filled: true,
                                  fillColor: _commentInputBg,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: _commentInputBorder,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton(
                                  key: const Key('comment-send-button'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: hasDraft
                                        ? colors.onSurface
                                        : const Color(0xFFE8DCC3),
                                    foregroundColor: hasDraft
                                        ? _commentInputBg
                                        : const Color(0xFF7C7462),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _submitComment,
                                  child: const Text(
                                    'Send',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (shownComments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: Text(
                        'No comments yet. Be the first to share tips for this recipe!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                    )
                  else
                    for (final comment in shownComments)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CommentItemCard(
                          comment: comment,
                          onLike: () => _toggleLike(comment),
                          onDelete: () => _deleteComment(comment),
                        ),
                      ),
                  if (hasMore)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Center(
                        child: OutlinedButton(
                          key: const Key('view-more-comments-button'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: colors.onSurface,
                            side: BorderSide(color: colors.outlineVariant),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => setState(() => _showAll = true),
                          child: const Text(
                            'View more comments',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeSelectorHeader extends StatelessWidget {
  const _RecipeSelectorHeader({
    required this.recipes,
    required this.selected,
    required this.onSelect,
  });

  final List<CommunityRecipe> recipes;
  final CommunityRecipe selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Resep untuk Diskusi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < recipes.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(recipes[i].name),
                    selected: recipes[i].recipeId == selected.recipeId,
                    selectedColor: colors.primary,
                    backgroundColor: colors.surface,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: recipes[i].recipeId == selected.recipeId
                          ? Colors.white
                          : colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (_) => onSelect(recipes[i].recipeId),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 24, color: colors.outlineVariant),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox.square(
                  dimension: 64,
                  child: selected.assetImage != null
                      ? Image.asset(
                          selected.assetImage!,
                          fit: BoxFit.cover,
                          excludeFromSemantics: true,
                        )
                      : ColoredBox(
                          color: colors.surface,
                          child: Icon(
                            Icons.restaurant_outlined,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selected.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentItemCard extends StatelessWidget {
  const _CommentItemCard({
    required this.comment,
    required this.onLike,
    required this.onDelete,
  });

  final RecipeComment comment;
  final VoidCallback onLike;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final likeColor = comment.isLiked ? _commentLikeOrange : colors.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserAvatar(user: comment.user),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      comment.user.displayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      comment.timeAgo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7C8C80),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF2B3D36),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Semantics(
                      button: true,
                      toggled: comment.isLiked,
                      label: 'Like this comment',
                      child: InkWell(
                        key: Key('like-comment-${comment.id}'),
                        borderRadius: BorderRadius.circular(8),
                        onTap: onLike,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                comment.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: likeColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${comment.likeCount}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: likeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (comment.canDelete) ...[
                      const SizedBox(width: 16),
                      InkWell(
                        key: Key('delete-comment-${comment.id}'),
                        borderRadius: BorderRadius.circular(8),
                        onTap: onDelete,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7C8C80),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user, this.isCurrentUser = false});

  final CommentUser user;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (bg, fg) = isCurrentUser
        ? (const Color(0xFFB6E3F4), colors.onSurface)
        : avatarColorsForUser(user.id);
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: isCurrentUser
              ? Border.all(color: colors.onSurface, width: 2)
              : null,
        ),
        child: Text(
          user.initials,
          style: TextStyle(
            color: fg,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
