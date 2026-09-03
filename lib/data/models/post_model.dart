import 'package:flutter/foundation.dart';

/// Location data for a post
class PostLocation {
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final String? placeId;

  const PostLocation({
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'placeId': placeId,
      };

  factory PostLocation.fromJson(Map<String, dynamic> json) => PostLocation(
        name: json['name'] as String? ?? '',
        address: json['address'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        placeId: json['placeId'] as String?,
      );

  PostLocation copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? placeId,
  }) =>
      PostLocation(
        name: name ?? this.name,
        address: address ?? this.address,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        placeId: placeId ?? this.placeId,
      );
}

/// Comment model
class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String username;
  final String? userProfilePic;
  final String content;
  final String? parentCommentId; // For nested replies
  final List<String> likes;
  final int likeCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.username,
    this.userProfilePic,
    required this.content,
    this.parentCommentId,
    this.likes = const [],
    this.likeCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'commentId': commentId,
        'postId': postId,
        'userId': userId,
        'username': username,
        'userProfilePic': userProfilePic,
        'content': content,
        'parentCommentId': parentCommentId,
        'likes': likes,
        'likeCount': likeCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        commentId: json['commentId'] as String? ?? '',
        postId: json['postId'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        username: json['username'] as String? ?? '',
        userProfilePic: json['userProfilePic'] as String?,
        content: json['content'] as String? ?? '',
        parentCommentId: json['parentCommentId'] as String?,
        likes: List<String>.from(json['likes'] ?? []),
        likeCount: json['likeCount'] as int? ?? 0,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String)
            : null,
      );

  CommentModel copyWith({
    String? commentId,
    String? postId,
    String? userId,
    String? username,
    String? userProfilePic,
    String? content,
    String? parentCommentId,
    List<String>? likes,
    int? likeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      CommentModel(
        commentId: commentId ?? this.commentId,
        postId: postId ?? this.postId,
        userId: userId ?? this.userId,
        username: username ?? this.username,
        userProfilePic: userProfilePic ?? this.userProfilePic,
        content: content ?? this.content,
        parentCommentId: parentCommentId ?? this.parentCommentId,
        likes: likes ?? this.likes,
        likeCount: likeCount ?? this.likeCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

/// Main Post model
class PostModel {
  final String postId;
  final String userId;
  final String username;
  final String? userProfilePic;
  final String? displayName;
  final String? caption;
  final List<String> mediaUrls;
  final String mediaType; // 'image', 'video', 'carousel'
  final int mediaCount;
  final List<String> likes;
  final int likeCount;
  final List<CommentModel> comments;
  final int commentCount;
  final int shares;
  final int saves;
  final List<String> hashtags;
  final List<String> taggedUsers;
  final PostLocation? location;
  final String? musicUrl;
  final String? musicTitle;
  final String? musicArtist;
  final bool isLiked;
  final bool isSaved;
  final bool isShared;
  final String? visibility; // 'public', 'private', 'friends'
  final bool commentsEnabled;
  final bool likesEnabled;
  final bool sharingEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PostModel({
    required this.postId,
    required this.userId,
    required this.username,
    this.userProfilePic,
    this.displayName,
    this.caption,
    this.mediaUrls = const [],
    this.mediaType = 'image',
    this.mediaCount = 1,
    this.likes = const [],
    this.likeCount = 0,
    this.comments = const [],
    this.commentCount = 0,
    this.shares = 0,
    this.saves = 0,
    this.hashtags = const [],
    this.taggedUsers = const [],
    this.location,
    this.musicUrl,
    this.musicTitle,
    this.musicArtist,
    this.isLiked = false,
    this.isSaved = false,
    this.isShared = false,
    this.visibility = 'public',
    this.commentsEnabled = true,
    this.likesEnabled = true,
    this.sharingEnabled = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a [PostModel] from a Firestore document
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      userProfilePic: json['userProfilePic'] as String?,
      displayName: json['displayName'] as String?,
      caption: json['caption'] as String?,
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      mediaType: json['mediaType'] as String? ?? 'image',
      mediaCount: json['mediaCount'] as int? ?? 1,
      likes: List<String>.from(json['likes'] ?? []),
      likeCount: json['likeCount'] as int? ?? 0,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      commentCount: json['commentCount'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      saves: json['saves'] as int? ?? 0,
      hashtags: List<String>.from(json['hashtags'] ?? []),
      taggedUsers: List<String>.from(json['taggedUsers'] ?? []),
      location: json['location'] != null
          ? PostLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      musicUrl: json['musicUrl'] as String?,
      musicTitle: json['musicTitle'] as String?,
      musicArtist: json['musicArtist'] as String?,
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      isShared: json['isShared'] as bool? ?? false,
      visibility: json['visibility'] as String? ?? 'public',
      commentsEnabled: json['commentsEnabled'] as bool? ?? true,
      likesEnabled: json['likesEnabled'] as bool? ?? true,
      sharingEnabled: json['sharingEnabled'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert the [PostModel] to a Map for Firestore
  Map<String, dynamic> toJson() => {
        'postId': postId,
        'userId': userId,
        'username': username,
        'userProfilePic': userProfilePic,
        'displayName': displayName,
        'caption': caption,
        'mediaUrls': mediaUrls,
        'mediaType': mediaType,
        'mediaCount': mediaCount,
        'likes': likes,
        'likeCount': likeCount,
        'comments': comments.map((c) => c.toJson()).toList(),
        'commentCount': commentCount,
        'shares': shares,
        'saves': saves,
        'hashtags': hashtags,
        'taggedUsers': taggedUsers,
        'location': location?.toJson(),
        'musicUrl': musicUrl,
        'musicTitle': musicTitle,
        'musicArtist': musicArtist,
        'isLiked': isLiked,
        'isSaved': isSaved,
        'isShared': isShared,
        'visibility': visibility,
        'commentsEnabled': commentsEnabled,
        'likesEnabled': likesEnabled,
        'sharingEnabled': sharingEnabled,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  /// Create a copy of this [PostModel] with the given fields replaced
  PostModel copyWith({
    String? postId,
    String? userId,
    String? username,
    String? userProfilePic,
    String? displayName,
    String? caption,
    List<String>? mediaUrls,
    String? mediaType,
    int? mediaCount,
    List<String>? likes,
    int? likeCount,
    List<CommentModel>? comments,
    int? commentCount,
    int? shares,
    int? saves,
    List<String>? hashtags,
    List<String>? taggedUsers,
    PostLocation? location,
    String? musicUrl,
    String? musicTitle,
    String? musicArtist,
    bool? isLiked,
    bool? isSaved,
    bool? isShared,
    String? visibility,
    bool? commentsEnabled,
    bool? likesEnabled,
    bool? sharingEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      PostModel(
        postId: postId ?? this.postId,
        userId: userId ?? this.userId,
        username: username ?? this.username,
        userProfilePic: userProfilePic ?? this.userProfilePic,
        displayName: displayName ?? this.displayName,
        caption: caption ?? this.caption,
        mediaUrls: mediaUrls ?? this.mediaUrls,
        mediaType: mediaType ?? this.mediaType,
        mediaCount: mediaCount ?? this.mediaCount,
        likes: likes ?? this.likes,
        likeCount: likeCount ?? this.likeCount,
        comments: comments ?? this.comments,
        commentCount: commentCount ?? this.commentCount,
        shares: shares ?? this.shares,
        saves: saves ?? this.saves,
        hashtags: hashtags ?? this.hashtags,
        taggedUsers: taggedUsers ?? this.taggedUsers,
        location: location ?? this.location,
        musicUrl: musicUrl ?? this.musicUrl,
        musicTitle: musicTitle ?? this.musicTitle,
        musicArtist: musicArtist ?? this.musicArtist,
        isLiked: isLiked ?? this.isLiked,
        isSaved: isSaved ?? this.isSaved,
        isShared: isShared ?? this.isShared,
        visibility: visibility ?? this.visibility,
        commentsEnabled: commentsEnabled ?? this.commentsEnabled,
        likesEnabled: likesEnabled ?? this.likesEnabled,
        sharingEnabled: sharingEnabled ?? this.sharingEnabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
