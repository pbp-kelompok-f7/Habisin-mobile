import 'package:flutter/material.dart';

class CommentUser {
  const CommentUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.initials,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final username = json['username'];
    final displayName = json['display_name'] ?? username;
    final initials = json['initials'];
    if (id is! int || username is! String || username.trim().isEmpty) {
      throw const FormatException('Invalid comment author.');
    }
    final nameStr = (displayName is String && displayName.trim().isNotEmpty)
        ? displayName.trim()
        : username.trim();
    final initStr = (initials is String && initials.trim().isNotEmpty)
        ? initials.trim().toUpperCase()
        : computeInitials(nameStr);
    return CommentUser(
      id: id,
      username: username.trim(),
      displayName: nameStr,
      initials: initStr,
    );
  }

  final int id;
  final String username;
  final String displayName;
  final String initials;

  static String computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final clean = name.trim();
    if (clean.isEmpty) return '?';
    return clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }
}

class RecipeComment {
  const RecipeComment({
    required this.id,
    required this.recipeId,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.timeAgo,
    required this.likeCount,
    required this.isLiked,
    required this.canDelete,
  });

  factory RecipeComment.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final recipeId = json['recipe_id'];
    final userMap = json['user'];
    final content = json['content'];
    final createdAtStr = json['created_at'];
    final timeAgo = json['time_ago'];
    final likeCount = json['like_count'] ?? 0;
    final isLiked = json['is_liked'] ?? false;
    final canDelete = json['can_delete'] ?? false;

    if (id is! int ||
        recipeId is! int ||
        userMap is! Map<String, dynamic> ||
        content is! String ||
        likeCount is! int ||
        isLiked is! bool ||
        canDelete is! bool) {
      throw const FormatException('Invalid comment payload.');
    }

    final parsedDate = createdAtStr is String
        ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
        : DateTime.now();

    return RecipeComment(
      id: id,
      recipeId: recipeId,
      user: CommentUser.fromJson(userMap),
      content: content,
      createdAt: parsedDate,
      timeAgo: (timeAgo is String && timeAgo.trim().isNotEmpty)
          ? timeAgo
          : formatTimeAgo(parsedDate),
      likeCount: likeCount,
      isLiked: isLiked,
      canDelete: canDelete,
    );
  }

  final int id;
  final int recipeId;
  final CommentUser user;
  final String content;
  final DateTime createdAt;
  final String timeAgo;
  final int likeCount;
  final bool isLiked;
  final bool canDelete;

  RecipeComment copyWith({
    int? id,
    int? recipeId,
    CommentUser? user,
    String? content,
    DateTime? createdAt,
    String? timeAgo,
    int? likeCount,
    bool? isLiked,
    bool? canDelete,
  }) {
    return RecipeComment(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      user: user ?? this.user,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      timeAgo: timeAgo ?? this.timeAgo,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      canDelete: canDelete ?? this.canDelete,
    );
  }

  static String formatTimeAgo(DateTime dateTime, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final seconds = reference.difference(dateTime).inSeconds;
    if (seconds < 60) return 'Just now';
    if (seconds < 3600) return '${seconds ~/ 60} mins ago';
    if (seconds < 86400) return '${seconds ~/ 3600} hours ago';
    final days = seconds ~/ 86400;
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    final d = dateTime.day.toString().padLeft(2, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    return '$d/$m/${dateTime.year}';
  }
}

class CommunityRecipe {
  const CommunityRecipe({
    required this.recipeId,
    required this.name,
    required this.subtitle,
    this.assetImage,
    this.imageUrl,
  });

  final int recipeId;
  final String name;
  final String subtitle;
  final String? assetImage;
  final String? imageUrl;
}

const sampleCommunityRecipes = [
  CommunityRecipe(
    recipeId: 52772,
    name: 'Sup Ayam Wortel Kentang',
    subtitle: 'Ayam, wortel, kentang, bawang putih, seledri',
    assetImage: 'assets/meals/soup.png',
  ),
  CommunityRecipe(
    recipeId: 52940,
    name: 'Nasi Goreng Sisa Sayur',
    subtitle: 'Nasi, wortel, telur, bawang putih, kecap manis',
    assetImage: 'assets/meals/fried-rice.png',
  ),
  CommunityRecipe(
    recipeId: 52977,
    name: 'Omelet Bayam Keju',
    subtitle: 'Telur, bayam, keju',
    assetImage: 'assets/meals/omelet.png',
  ),
];

(Color, Color) avatarColorsForUser(int userId, ColorScheme colors) {
  final palette = [
    (colors.secondary, colors.onSecondary),
    (colors.primary, colors.onPrimary),
    (colors.onSurface, colors.surface),
    (colors.outlineVariant, colors.onSurface),
  ];
  return palette[userId.abs() % palette.length];
}

class CommentsStore {
  CommentsStore({Map<int, List<RecipeComment>>? initial})
    : _byRecipe = initial ?? _defaultInitialComments();

  final Map<int, List<RecipeComment>> _byRecipe;
  int _nextId = 1000;
  String? authToken;
  CommentUser currentUser = const CommentUser(
    id: 99,
    username: 'melinda',
    displayName: 'Amelinda Fedora',
    initials: 'AF',
  );

  List<RecipeComment> commentsFor(int recipeId) {
    final list = _byRecipe[recipeId] ?? const <RecipeComment>[];
    return List<RecipeComment>.unmodifiable(list);
  }

  void replaceComments(int recipeId, List<RecipeComment> comments) {
    _byRecipe[recipeId] = List<RecipeComment>.from(comments);
  }

  RecipeComment? addLocalComment(int recipeId, String rawContent) {
    final content = rawContent.trim();
    if (content.isEmpty || content.length > 1000) {
      throw const FormatException(
        'Comment must be between 1 and 1000 characters.',
      );
    }
    final list = _byRecipe.putIfAbsent(recipeId, () => <RecipeComment>[]);
    final duplicate = list.any(
      (c) => c.user.id == currentUser.id && c.content == content,
    );
    if (duplicate) return null;

    final comment = RecipeComment(
      id: _nextId++,
      recipeId: recipeId,
      user: currentUser,
      content: content,
      createdAt: DateTime.now(),
      timeAgo: 'Just now',
      likeCount: 0,
      isLiked: false,
      canDelete: true,
    );
    list.insert(0, comment);
    return comment;
  }

  void upsertServerComment(int recipeId, RecipeComment comment) {
    final list = _byRecipe.putIfAbsent(recipeId, () => <RecipeComment>[]);
    final index = list.indexWhere((c) => c.id == comment.id);
    if (index >= 0) {
      list[index] = comment;
    } else {
      list.insert(0, comment);
    }
  }

  RecipeComment? toggleLocalLike(int recipeId, int commentId) {
    final list = _byRecipe[recipeId];
    if (list == null) return null;
    final index = list.indexWhere((c) => c.id == commentId);
    if (index < 0) return null;
    final current = list[index];
    final nextLiked = !current.isLiked;
    final nextCount = nextLiked
        ? current.likeCount + 1
        : (current.likeCount > 0 ? current.likeCount - 1 : 0);
    final updated = current.copyWith(
      isLiked: nextLiked,
      likeCount: nextCount,
    );
    list[index] = updated;
    return updated;
  }

  bool deleteLocalComment(int recipeId, int commentId) {
    final list = _byRecipe[recipeId];
    if (list == null) return false;
    final before = list.length;
    list.removeWhere((c) => c.id == commentId && c.canDelete);
    return list.length < before;
  }

  static Map<int, List<RecipeComment>> _defaultInitialComments() {
    const rachel = CommentUser(
      id: 1,
      username: 'rachel',
      displayName: 'Rachel',
      initials: 'RA',
    );
    const ahsan = CommentUser(
      id: 2,
      username: 'ahsan',
      displayName: 'Ahsan Rifqi',
      initials: 'AR',
    );
    const umar = CommentUser(
      id: 3,
      username: 'umar',
      displayName: 'Umar Faiz',
      initials: 'UF',
    );

    return {
      52772: [
        RecipeComment(
          id: 101,
          recipeId: 52772,
          user: rachel,
          content:
              'Kuahnya gurih walaupun cuma pakai wortel dan kentang sisa di kulkas. Tambah seledri di akhir bikin wangi!',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          timeAgo: '2 hours ago',
          likeCount: 3,
          isLiked: false,
          canDelete: false,
        ),
        RecipeComment(
          id: 102,
          recipeId: 52772,
          user: ahsan,
          content:
              'Tips: tumis bawang putihnya sampai agak keemasan dulu baru masukin air kaldu.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          timeAgo: 'Yesterday',
          likeCount: 1,
          isLiked: false,
          canDelete: false,
        ),
      ],
      52940: [
        RecipeComment(
          id: 103,
          recipeId: 52940,
          user: umar,
          content:
              'Cocok banget buat habisin nasi semalam dan sisa potongan sayur. Anak kos wajib coba!',
          createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
          timeAgo: '25 mins ago',
          likeCount: 2,
          isLiked: false,
          canDelete: false,
        ),
      ],
      52977: [],
    };
  }
}
