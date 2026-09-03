import 'package:flutter/foundation.dart';

/// Story reaction
class StoryReaction {
  final String userId;
  final String username;
  final String? userProfilePic;
  final String emoji;
  final DateTime reactedAt;

  const StoryReaction({
    required this.userId,
    required this.username,
    this.userProfilePic,
    required this.emoji,
    required this.reactedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'userProfilePic': userProfilePic,
        'emoji': emoji,
        'reactedAt': reactedAt.toIso8601String(),
      };

  factory StoryReaction.fromJson(Map<String, dynamic> json) => StoryReaction(
        userId: json['userId'] as String? ?? '',
        username: json['username'] as String? ?? '',
        userProfilePic: json['userProfilePic'] as String?,
        emoji: json['emoji'] as String? ?? '❤️',
        reactedAt: json['reactedAt'] != null
            ? DateTime.tryParse(json['reactedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// Story reply/message
class StoryReply {
  final String replyId;
  final String userId;
  final String username;
  final String? userProfilePic;
  final String content;
  final String? mediaUrl;
  final DateTime repliedAt;

  const StoryReply({
    required this.replyId,
    required this.userId,
    required this.username,
    this.userProfilePic,
    required this.content,
    this.mediaUrl,
    required this.repliedAt,
  });

  Map<String, dynamic> toJson() => {
        'replyId': replyId,
        'userId': userId,
        'username': username,
        'userProfilePic': userProfilePic,
        'content': content,
        'mediaUrl': mediaUrl,
        'repliedAt': repliedAt.toIso8601String(),
      };

  factory StoryReply.fromJson(Map<String, dynamic> json) => StoryReply(
        replyId: json['replyId'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        username: json['username'] as String? ?? '',
        userProfilePic: json['userProfilePic'] as String?,
        content: json['content'] as String? ?? '',
        mediaUrl: json['mediaUrl'] as String?,
        repliedAt: json['repliedAt'] != null
            ? DateTime.tryParse(json['repliedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// Story music
class StoryMusic {
  final String title;
  final String artist;
  final String audioUrl;
  final String? albumArtUrl;
  final double? startOffset; // in seconds

  const StoryMusic({
    required this.title,
    required this.artist,
    required this.audioUrl,
    this.albumArtUrl,
    this.startOffset,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'artist': artist,
        'audioUrl': audioUrl,
        'albumArtUrl': albumArtUrl,
        'startOffset': startOffset,
      };

  factory StoryMusic.fromJson(Map<String, dynamic> json) => StoryMusic(
        title: json['title'] as String? ?? '',
        artist: json['artist'] as String? ?? '',
        audioUrl: json['audioUrl'] as String? ?? '',
        albumArtUrl: json['albumArtUrl'] as String?,
        startOffset: (json['startOffset'] as num?)?.toDouble(),
      );
}

/// Story text overlay
class StoryTextOverlay {
  final String text;
  final double x;
  final double y;
  final double rotation;
  final double fontSize;
  final int color;
  final String fontFamily;

  const StoryTextOverlay({
    required this.text,
    required this.x,
    required this.y,
    this.rotation = 0,
    this.fontSize = 20,
    this.color = 0xFFFFFFFF,
    this.fontFamily = 'Montserrat',
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'x': x,
        'y': y,
        'rotation': rotation,
        'fontSize': fontSize,
        'color': color,
        'fontFamily': fontFamily,
      };

  factory StoryTextOverlay.fromJson(Map<String, dynamic> json) =>
      StoryTextOverlay(
        text: json['text'] as String? ?? '',
        x: (json['x'] as num?)?.toDouble() ?? 0,
        y: (json['y'] as num?)?.toDouble() ?? 0,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 20,
        color: json['color'] as int? ?? 0xFFFFFFFF,
        fontFamily: json['fontFamily'] as String? ?? 'Montserrat',
      );
}

/// Main Story model
class StoryModel {
  final String storyId;
  final String userId;
  final String username;
  final String? userProfilePic;
  final String? displayName;
  final String mediaUrl;
  final String mediaType; // 'image', 'video'
  final int mediaDuration; // in seconds
  final String? caption;
  final List<StoryReaction> reactions;
  final List<StoryReply> replies;
  final List<String> viewers;
  final int viewCount;
  final StoryMusic? music;
  final List<StoryTextOverlay> textOverlays;
  final String? stickerType; // 'location', 'hashtag', 'mention', 'poll', 'quiz'
  final Map<String, dynamic>? stickerData;
  final bool isHighlighted;
  final String? highlightName;
  final DateTime expiresAt;
  final DateTime createdAt;

  const StoryModel({
    required this.storyId,
    required this.userId,
    required this.username,
    this.userProfilePic,
    this.displayName,
    required this.mediaUrl,
    this.mediaType = 'image',
    this.mediaDuration = 15,
    this.caption,
    this.reactions = const [],
    this.replies = const [],
    this.viewers = const [],
    this.viewCount = 0,
    this.music,
    this.textOverlays = const [],
    this.stickerType,
    this.stickerData,
    this.isHighlighted = false,
    this.highlightName,
    required this.expiresAt,
    required this.createdAt,
  });

  /// Whether this story has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Whether the given user has viewed this story
  bool hasViewed(String viewerId) => viewers.contains(viewerId);

  /// Create a [StoryModel] from a Firestore document
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      storyId: json['storyId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      userProfilePic: json['userProfilePic'] as String?,
      displayName: json['displayName'] as String?,
      mediaUrl: json['mediaUrl'] as String? ?? '',
      mediaType: json['mediaType'] as String? ?? 'image',
      mediaDuration: json['mediaDuration'] as int? ?? 15,
      caption: json['caption'] as String?,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => StoryReaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => StoryReply.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      viewers: List<String>.from(json['viewers'] ?? []),
      viewCount: json['viewCount'] as int? ?? 0,
      music: json['music'] != null
          ? StoryMusic.fromJson(json['music'] as Map<String, dynamic>)
          : null,
      textOverlays: (json['textOverlays'] as List<dynamic>?)
              ?.map((e) => StoryTextOverlay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      stickerType: json['stickerType'] as String?,
      stickerData: json['stickerData'] as Map<String, dynamic>?,
      isHighlighted: json['isHighlighted'] as bool? ?? false,
      highlightName: json['highlightName'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String) ??
              DateTime.now().add(const Duration(hours: 24))
          : DateTime.now().add(const Duration(hours: 24)),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert the [StoryModel] to a Map for Firestore
  Map<String, dynamic> toJson() => {
        'storyId': storyId,
        'userId': userId,
        'username': username,
        'userProfilePic': userProfilePic,
        'displayName': displayName,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'mediaDuration': mediaDuration,
        'caption': caption,
        'reactions': reactions.map((r) => r.toJson()).toList(),
        'replies': replies.map((r) => r.toJson()).toList(),
        'viewers': viewers,
        'viewCount': viewCount,
        'music': music?.toJson(),
        'textOverlays': textOverlays.map((t) => t.toJson()).toList(),
        'stickerType': stickerType,
        'stickerData': stickerData,
        'isHighlighted': isHighlighted,
        'highlightName': highlightName,
        'expiresAt': expiresAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  /// Create a copy of this [StoryModel] with the given fields replaced
  StoryModel copyWith({
    String? storyId,
    String? userId,
    String? username,
    String? userProfilePic,
    String? displayName,
    String? mediaUrl,
    String? mediaType,
    int? mediaDuration,
    String? caption,
    List<StoryReaction>? reactions,
    List<StoryReply>? replies,
    List<String>? viewers,
    int? viewCount,
    StoryMusic? music,
    List<StoryTextOverlay>? textOverlays,
    String? stickerType,
    Map<String, dynamic>? stickerData,
    bool? isHighlighted,
    String? highlightName,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) =>
      StoryModel(
        storyId: storyId ?? this.storyId,
        userId: userId ?? this.userId,
        username: username ?? this.username,
        userProfilePic: userProfilePic ?? this.userProfilePic,
        displayName: displayName ?? this.displayName,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        mediaType: mediaType ?? this.mediaType,
        mediaDuration: mediaDuration ?? this.mediaDuration,
        caption: caption ?? this.caption,
        reactions: reactions ?? this.reactions,
        replies: replies ?? this.replies,
        viewers: viewers ?? this.viewers,
        viewCount: viewCount ?? this.viewCount,
        music: music ?? this.music,
        textOverlays: textOverlays ?? this.textOverlays,
        stickerType: stickerType ?? this.stickerType,
        stickerData: stickerData ?? this.stickerData,
        isHighlighted: isHighlighted ?? this.isHighlighted,
        highlightName: highlightName ?? this.highlightName,
        expiresAt: expiresAt ?? this.expiresAt,
        createdAt: createdAt ?? this.createdAt,
      );
}

/// Story highlight model (persistent stories)
class StoryHighlightModel {
  final String highlightId;
  final String userId;
  final String title;
  final String? coverImageUrl;
  final List<StoryModel> stories;
  final DateTime createdAt;

  const StoryHighlightModel({
    required this.highlightId,
    required this.userId,
    required this.title,
    this.coverImageUrl,
    this.stories = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'highlightId': highlightId,
        'userId': userId,
        'title': title,
        'coverImageUrl': coverImageUrl,
        'stories': stories.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory StoryHighlightModel.fromJson(Map<String, dynamic> json) =>
      StoryHighlightModel(
        highlightId: json['highlightId'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        coverImageUrl: json['coverImageUrl'] as String?,
        stories: (json['stories'] as List<dynamic>?)
                ?.map((e) => StoryModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}
