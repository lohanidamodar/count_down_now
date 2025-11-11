import 'dart:math';

class Countdown {
  final String? id;
  final String slug;
  final String title;
  final String? description;
  final String? emoji;
  final DateTime targetDateTime;
  final String themeColor;
  final String? ownerId;
  final bool isPublic;
  final DateTime createdAt;

  const Countdown({
    this.id,
    required this.slug,
    required this.title,
    this.description,
    this.emoji,
    required this.targetDateTime,
    required this.themeColor,
    this.ownerId,
    this.isPublic = true,
    required this.createdAt,
  });

  /// Generate a random URL-safe slug
  static String generateSlug() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Create from Appwrite document
  factory Countdown.fromMap(Map<String, dynamic> map) {
    return Countdown(
      id: map['\$id'] as String?,
      slug: map['slug'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      emoji: map['emoji'] as String?,
      targetDateTime: DateTime.parse(map['targetDateTime'] as String),
      themeColor: map['themeColor'] as String,
      ownerId: map['ownerId'] as String?,
      isPublic: map['isPublic'] as bool? ?? true,
      createdAt: map['\$createdAt'] != null
          ? DateTime.parse(map['\$createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to Appwrite document
  Map<String, dynamic> toMap() {
    return {
      'slug': slug,
      'title': title,
      'description': description,
      'emoji': emoji,
      'targetDateTime': targetDateTime.toIso8601String(),
      'themeColor': themeColor,
      'ownerId': ownerId,
      'isPublic': isPublic,
    };
  }

  /// Create a copy with updated fields
  Countdown copyWith({
    String? id,
    String? slug,
    String? title,
    String? description,
    String? emoji,
    DateTime? targetDateTime,
    String? themeColor,
    String? ownerId,
    bool? isPublic,
    DateTime? createdAt,
  }) {
    return Countdown(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      targetDateTime: targetDateTime ?? this.targetDateTime,
      themeColor: themeColor ?? this.themeColor,
      ownerId: ownerId ?? this.ownerId,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Calculate time remaining
  Duration get timeRemaining {
    final now = DateTime.now();
    return targetDateTime.difference(now);
  }

  /// Check if countdown has finished
  bool get isFinished {
    return timeRemaining.isNegative;
  }
}
