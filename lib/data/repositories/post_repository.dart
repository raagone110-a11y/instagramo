import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../models/post_model.dart';

/// Custom post exception
class PostException implements Exception {
  final String message;
  final String code;
  const PostException(this.message, this.code);

  @override
  String toString() => 'PostException($code): $message';
}

/// Post repository provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

/// Post repository handling all post-related Firestore operations
class PostRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid = const Uuid();

  PostRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  // ============================================================================
  // Create Post
  // ============================================================================

  /// Create a new post
  Future<PostModel> createPost({
    required String userId,
    required String username,
    String? userProfilePic,
    String? displayName,
    String? caption,
    required List<File> mediaFiles,
    required String mediaType,
    List<String> hashtags = const [],
    List<String> taggedUsers = const [],
    PostLocation? location,
    String? musicUrl,
    String? musicTitle,
    String? musicArtist,
    String visibility = 'public',
    bool commentsEnabled = true,
    bool likesEnabled = true,
    bool sharingEnabled = true,
  }) async {
    try {
      // Upload media files
      final mediaUrls = <String>[];
      for (final file in mediaFiles) {
        final url = await _uploadMedia(
            file: file, userId: userId, mediaType: mediaType);
        mediaUrls.add(url);
      }

      final postId = _uuid.v4();
      final now = DateTime.now();

      // Extract hashtags from caption if not provided
      final extractedHashtags =
          hashtags.isEmpty ? _extractHashtags(caption ?? '') : hashtags;

      final post = PostModel(
        postId: postId,
        userId: userId,
        username: username,
        userProfilePic: userProfilePic,
        displayName: displayName,
        caption: caption,
        mediaUrls: mediaUrls,
        mediaType: mediaType,
        mediaCount: mediaUrls.length,
        likes: [],
        likeCount: 0,
        comments: [],
        commentCount: 0,
        shares: 0,
        saves: 0,
        hashtags: extractedHashtags,
        taggedUsers: taggedUsers,
        location: location,
        musicUrl: musicUrl,
        musicTitle: musicTitle,
        musicArtist: musicArtist,
        isLiked: false,
        isSaved: false,
        isShared: false,
        visibility: visibility,
        commentsEnabled: commentsEnabled,
        likesEnabled: likesEnabled,
        sharingEnabled: sharingEnabled,
        createdAt: now,
        updatedAt: now,
      );

      // Save post to Firestore
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .set(post.toJson());

      // Update user's post count
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'totalPosts': FieldValue.increment(1),
        'updatedAt': now.toIso8601String(),
      });

      return post;
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw PostException(
        AppConstants.genericError,
        'create_post_error',
      );
    }
  }

  // ============================================================================
  // Get Posts
  // ============================================================================

  /// Get a single post by ID
  Future<PostModel?> getPostById(String postId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .get();

      if (!doc.exists) return null;
      return PostModel.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw PostException(
        AppConstants.genericError,
        'fetch_post_error',
      );
    }
  }

  /// Stream a single post by ID
  Stream<PostModel?> watchPostById(String postId) {
    return _firestore
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return PostModel.fromJson(doc.data()!);
    });
  }

  /// Get user's posts
  Future<List<PostModel>> getUserPosts({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(AppConstants.postsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw PostException(
        AppConstants.genericError,
        'fetch_user_posts_error',
      );
    }
  }

  /// Stream user's posts
  Stream<List<PostModel>> watchUserPosts(String userId) {
    return _firestore
        .collection(AppConstants.postsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromJson(doc.data()))
            .toList());
  }

  // ============================================================================
  // Home Feed
  // ============================================================================

  /// Get the home feed (posts from followed users)
  Future<List<PostModel>> getFeed({
    required String userId,
    required List<String> followingIds,
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      if (followingIds.isEmpty) {
        // Return general/explore feed if not following anyone
        return getExploreFeed(limit: limit, startAfter: startAfter);
      }

      // Batch query in groups of 10 (Firestore whereIn limit)
      final posts = <PostModel>[];
      final chunks = _chunkList(followingIds, 10);

      for (final chunk in chunks) {
        Query<Map<String, dynamic>> query = _firestore
            .collection(AppConstants.postsCollection)
            .where('userId', whereIn: chunk)
            .where('visibility', isEqualTo: 'public')
            .orderBy('createdAt', descending: true)
            .limit(limit);

        if (startAfter != null && chunks.indexOf(chunk) == 0) {
          query = query.startAfterDocument(startAfter);
        }

        final snapshot = await query.get();
        posts.addAll(
          snapshot.docs.map((doc) => PostModel.fromJson(doc.data())),
        );
      }

      // Sort by createdAt descending
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return posts.take(limit).toList();
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw PostException(
        AppConstants.genericError,
        'fetch_feed_error',
      );
    }
  }

  /// Get explore/discover feed
  Future<List<PostModel>> getExploreFeed({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(AppConstants.postsCollection)
          .where('visibility', isEqualTo: 'public')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw PostException(
        AppConstants.genericError,
        'fetch_explore_error',
      );
    }
  }

  /// Stream the home feed
  Stream<List<PostModel>> watchFeed({
    required String userId,
    required List<String> followingIds,
  }) {
    if (followingIds.isEmpty) {
      return _firestore
          .collection(AppConstants.postsCollection)
          .where('visibility', isEqualTo: 'public')
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.feedPageSize)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PostModel.fromJson(doc.data()))
              .toList());
    }

    return _firestore
        .collection(AppConstants.postsCollection)
        .where('userId', whereIn: followingIds.take(10).toList())
        .where('visibility', isEqualTo: 'public')
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.feedPageSize)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromJson(doc.data()))
            .toList());
  }

  // ============================================================================
  // Update/Delete Post
  // ============================================================================

  /// Update a post
  Future<void> updatePost(PostModel post) async {
    try {
      final data = post.toJson();
      data['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(post.postId)
          .update(data);
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  /// Update post caption
  Future<void> updateCaption({
    required String postId,
    required String caption,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .update({
        'caption': caption,
        'hashtags': _extractHashtags(caption),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  /// Delete a post
  Future<void> deletePost(
      {required String postId, required String userId}) async {
    try {
      final post = await getPostById(postId);
      if (post == null) return;

      final batch = _firestore.batch();

      // Delete post document
      batch.delete(
        _firestore.collection(AppConstants.postsCollection).doc(postId),
      );

      // Update user's post count
      batch.update(
        _firestore.collection(AppConstants.usersCollection).doc(userId),
        {
          'totalPosts': FieldValue.increment(-1),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      await batch.commit();

      // Delete media from storage
      for (final mediaUrl in post.mediaUrls) {
        await _deleteMediaFromStorage(mediaUrl);
      }
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  // ============================================================================
  // Like Operations
  // ============================================================================

  /// Like a post
  Future<void> likePost(
      {required String postId, required String userId}) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore.collection(AppConstants.postsCollection).doc(postId),
        {
          'likes': FieldValue.arrayUnion([userId]),
          'likeCount': FieldValue.increment(1),
        },
      );

      batch.set(
        _firestore
            .collection(AppConstants.postsCollection)
            .doc(postId)
            .collection(AppConstants.likesCollection)
            .doc(userId),
        {
          'userId': userId,
          'likedAt': DateTime.now().toIso8601String(),
        },
      );

      await batch.commit();
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  /// Unlike a post
  Future<void> unlikePost(
      {required String postId, required String userId}) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore.collection(AppConstants.postsCollection).doc(postId),
        {
          'likes': FieldValue.arrayRemove([userId]),
          'likeCount': FieldValue.increment(-1),
        },
      );

      batch.delete(
        _firestore
            .collection(AppConstants.postsCollection)
            .doc(postId)
            .collection(AppConstants.likesCollection)
            .doc(userId),
      );

      await batch.commit();
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  // ============================================================================
  // Comment Operations
  // ============================================================================

  /// Add a comment to a post
  Future<CommentModel> addComment({
    required String postId,
    required String userId,
    required String username,
    String? userProfilePic,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final commentId = _uuid.v4();
      final now = DateTime.now();

      final comment = CommentModel(
        commentId: commentId,
        postId: postId,
        userId: userId,
        username: username,
        userProfilePic: userProfilePic,
        content: content,
        parentCommentId: parentCommentId,
        likes: [],
        likeCount: 0,
        createdAt: now,
      );

      final batch = _firestore.batch();

      // Add comment to post's comments subcollection
      batch.set(
        _firestore
            .collection(AppConstants.postsCollection)
            .doc(postId)
            .collection(AppConstants.commentsCollection)
            .doc(commentId),
        comment.toJson(),
      );

      // Update post's comment count
      batch.update(
        _firestore.collection(AppConstants.postsCollection).doc(postId),
        {
          'commentCount': FieldValue.increment(1),
        },
      );

      await batch.commit();

      return comment;
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  /// Delete a comment
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final batch = _firestore.batch();

      batch.delete(
        _firestore
            .collection(AppConstants.postsCollection)
            .doc(postId)
            .collection(AppConstants.commentsCollection)
            .doc(commentId),
      );

      batch.update(
        _firestore.collection(AppConstants.postsCollection).doc(postId),
        {
          'commentCount': FieldValue.increment(-1),
        },
      );

      await batch.commit();
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  /// Like a comment
  Future<void> likeComment({
    required String postId,
    required String commentId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.commentsCollection)
          .doc(commentId)
          .update({
        'likes': FieldValue.arrayUnion([userId]),
        'likeCount': FieldValue.increment(1),
      });
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  /// Get comments for a post
  Future<List<CommentModel>> getComments({
    required String postId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.commentsCollection)
          .orderBy('createdAt', descending: false)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CommentModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  /// Stream comments for a post
  Stream<List<CommentModel>> watchComments(String postId) {
    return _firestore
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .collection(AppConstants.commentsCollection)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromJson(doc.data()))
            .toList());
  }

  // ============================================================================
  // Share Operations
  // ============================================================================

  /// Share a post
  Future<void> sharePost(
      {required String postId, required String userId}) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .update({
        'shares': FieldValue.increment(1),
      });

      // Record share activity
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection('shares')
          .add({
        'userId': userId,
        'sharedAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  // ============================================================================
  // Save Operations
  // ============================================================================

  /// Save a post
  Future<void> savePost(
      {required String postId, required String userId}) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore.collection(AppConstants.postsCollection).doc(postId),
        {
          'saves': FieldValue.increment(1),
        },
      );

      batch.set(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .collection(AppConstants.savesCollection)
            .doc(postId),
        {
          'postId': postId,
          'savedAt': DateTime.now().toIso8601String(),
        },
      );

      await batch.commit();
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  /// Unsave a post
  Future<void> unsavePost(
      {required String postId, required String userId}) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore.collection(AppConstants.postsCollection).doc(postId),
        {
          'saves': FieldValue.increment(-1),
        },
      );

      batch.delete(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .collection(AppConstants.savesCollection)
            .doc(postId),
      );

      await batch.commit();
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  /// Get user's saved posts
  Future<List<PostModel>> getSavedPosts({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final savedSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.savesCollection)
          .orderBy('savedAt', descending: true)
          .limit(limit)
          .get();

      final postIds =
          savedSnapshot.docs.map((doc) => doc['postId'] as String).toList();

      if (postIds.isEmpty) return [];

      final posts = <PostModel>[];
      for (final postId in postIds) {
        final post = await getPostById(postId);
        if (post != null) posts.add(post);
      }

      return posts;
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  // ============================================================================
  // Hashtag Posts
  // ============================================================================

  /// Get posts by hashtag
  Future<List<PostModel>> getPostsByHashtag({
    required String hashtag,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      final normalizedHashtag = hashtag.startsWith('#')
          ? hashtag.substring(1).toLowerCase()
          : hashtag.toLowerCase();

      Query<Map<String, dynamic>> query = _firestore
          .collection(AppConstants.postsCollection)
          .where('hashtags', arrayContains: normalizedHashtag)
          .where('visibility', isEqualTo: 'public')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw PostException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Upload media file to Firebase Storage
  Future<String> _uploadMedia({
    required File file,
    required String userId,
    required String mediaType,
  }) async {
    final fileName = '${_uuid.v4()}.${_getFileExtension(file)}';
    final storagePath = mediaType == 'video'
        ? '${AppConstants.postVideosPath}/$userId/$fileName'
        : '${AppConstants.postImagesPath}/$userId/$fileName';

    final storageRef = _storage.ref().child(storagePath);

    final uploadTask = await storageRef.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Delete media from Firebase Storage
  Future<void> _deleteMediaFromStorage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Silently fail if deletion fails
    }
  }

  /// Get file extension
  String _getFileExtension(File file) {
    final path = file.path;
    final extension = path.split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi']
            .contains(extension.toLowerCase())
        ? extension.toLowerCase()
        : 'jpg';
  }

  /// Extract hashtags from text
  List<String> _extractHashtags(String text) {
    final regex = AppConstants.hashtagRegExp;
    final matches = regex.allMatches(text);
    return matches
        .map((m) => m.group(1)?.toLowerCase() ?? '')
        .where((h) => h.isNotEmpty)
        .toList();
  }

  /// Chunk a list into sublists of given size
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, (i + chunkSize > list.length) ? list.length : i + chunkSize));
    }
    return chunks.isEmpty ? [list] : chunks;
  }
}
