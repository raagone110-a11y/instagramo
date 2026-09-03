import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository.dart';

/// Feed state model
class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final DocumentSnapshot? lastDocument;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.lastDocument,
  });

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    DocumentSnapshot? lastDocument,
  }) =>
      FeedState(
        posts: posts ?? this.posts,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        errorMessage: errorMessage ?? this.errorMessage,
        lastDocument: lastDocument ?? this.lastDocument,
      );
}

/// Feed notifier
class FeedNotifier extends StateNotifier<FeedState> {
  final PostRepository _postRepository;
  final Ref _ref;

  FeedNotifier(this._postRepository, this._ref) : super(const FeedState());

  /// Load initial feed
  Future<void> loadFeed({
    required String userId,
    required List<String> followingIds,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final posts = await _postRepository.getFeed(
        userId: userId,
        followingIds: followingIds,
        limit: AppConstants.feedPageSize,
      );

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasMore: posts.length >= AppConstants.feedPageSize,
        lastDocument:
            posts.isNotEmpty ? _createDocumentSnapshot(posts.last) : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load more posts (infinite scroll)
  Future<void> loadMoreFeed({
    required String userId,
    required List<String> followingIds,
  }) async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final posts = await _postRepository.getFeed(
        userId: userId,
        followingIds: followingIds,
        limit: AppConstants.feedPageSize,
        startAfter: state.lastDocument,
      );

      state = state.copyWith(
        posts: [...state.posts, ...posts],
        isLoadingMore: false,
        hasMore: posts.length >= AppConstants.feedPageSize,
        lastDocument:
            posts.isNotEmpty ? _createDocumentSnapshot(posts.last) : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load explore feed
  Future<void> loadExploreFeed() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final posts = await _postRepository.getExploreFeed(
        limit: AppConstants.feedPageSize,
      );

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasMore: posts.length >= AppConstants.feedPageSize,
        lastDocument:
            posts.isNotEmpty ? _createDocumentSnapshot(posts.last) : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load more explore posts
  Future<void> loadMoreExploreFeed() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final posts = await _postRepository.getExploreFeed(
        limit: AppConstants.feedPageSize,
        startAfter: state.lastDocument,
      );

      state = state.copyWith(
        posts: [...state.posts, ...posts],
        isLoadingMore: false,
        hasMore: posts.length >= AppConstants.feedPageSize,
        lastDocument:
            posts.isNotEmpty ? _createDocumentSnapshot(posts.last) : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh feed
  Future<void> refreshFeed({
    required String userId,
    required List<String> followingIds,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final posts = await _postRepository.getFeed(
        userId: userId,
        followingIds: followingIds,
        limit: AppConstants.feedPageSize,
      );

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasMore: posts.length >= AppConstants.feedPageSize,
        lastDocument:
            posts.isNotEmpty ? _createDocumentSnapshot(posts.last) : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Toggle like on a post
  Future<void> toggleLike({
    required String postId,
    required String userId,
    required bool currentIsLiked,
  }) async {
    // Optimistic update
    final updatedPosts = state.posts.map((post) {
      if (post.postId == postId) {
        return post.copyWith(
          isLiked: !currentIsLiked,
          likeCount: currentIsLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
      return post;
    }).toList();

    state = state.copyWith(posts: updatedPosts);

    try {
      if (currentIsLiked) {
        await _postRepository.unlikePost(postId: postId, userId: userId);
      } else {
        await _postRepository.likePost(postId: postId, userId: userId);
      }
    } catch (e) {
      // Revert on error
      final revertedPosts = state.posts.map((post) {
        if (post.postId == postId) {
          return post.copyWith(
            isLiked: currentIsLiked,
            likeCount: currentIsLiked ? post.likeCount + 1 : post.likeCount - 1,
          );
        }
        return post;
      }).toList();

      state = state.copyWith(posts: revertedPosts);
    }
  }

  /// Toggle save on a post
  Future<void> toggleSave({
    required String postId,
    required String userId,
    required bool currentIsSaved,
  }) async {
    // Optimistic update
    final updatedPosts = state.posts.map((post) {
      if (post.postId == postId) {
        return post.copyWith(
          isSaved: !currentIsSaved,
          saves: currentIsSaved ? post.saves - 1 : post.saves + 1,
        );
      }
      return post;
    }).toList();

    state = state.copyWith(posts: updatedPosts);

    try {
      if (currentIsSaved) {
        await _postRepository.unsavePost(postId: postId, userId: userId);
      } else {
        await _postRepository.savePost(postId: postId, userId: userId);
      }
    } catch (e) {
      // Revert on error
      final revertedPosts = state.posts.map((post) {
        if (post.postId == postId) {
          return post.copyWith(
            isSaved: currentIsSaved,
            saves: currentIsSaved ? post.saves + 1 : post.saves - 1,
          );
        }
        return post;
      }).toList();

      state = state.copyWith(posts: revertedPosts);
    }
  }

  /// Add a comment to a post
  Future<void> addComment({
    required String postId,
    required String userId,
    required String username,
    String? userProfilePic,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final comment = await _postRepository.addComment(
        postId: postId,
        userId: userId,
        username: username,
        userProfilePic: userProfilePic,
        content: content,
        parentCommentId: parentCommentId,
      );

      // Update local state
      final updatedPosts = state.posts.map((post) {
        if (post.postId == postId) {
          return post.copyWith(
            comments: [...post.comments, comment],
            commentCount: post.commentCount + 1,
          );
        }
        return post;
      }).toList();

      state = state.copyWith(posts: updatedPosts);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Share a post
  Future<void> sharePost({
    required String postId,
    required String userId,
  }) async {
    // Optimistic update
    final updatedPosts = state.posts.map((post) {
      if (post.postId == postId) {
        return post.copyWith(shares: post.shares + 1);
      }
      return post;
    }).toList();

    state = state.copyWith(posts: updatedPosts);

    try {
      await _postRepository.sharePost(postId: postId, userId: userId);
    } catch (e) {
      // Revert on error
      final revertedPosts = state.posts.map((post) {
        if (post.postId == postId) {
          return post.copyWith(shares: post.shares - 1);
        }
        return post;
      }).toList();

      state = state.copyWith(posts: revertedPosts);
    }
  }

  /// Delete a post
  Future<void> deletePost({
    required String postId,
    required String userId,
  }) async {
    try {
      await _postRepository.deletePost(postId: postId, userId: userId);

      // Remove from local state
      final updatedPosts =
          state.posts.where((post) => post.postId != postId).toList();

      state = state.copyWith(posts: updatedPosts);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset feed state
  void reset() {
    state = const FeedState();
  }

  /// Create a mock DocumentSnapshot for pagination
  DocumentSnapshot _createDocumentSnapshot(PostModel post) {
    return MockDocumentSnapshot(
      id: post.postId,
      data: post.toJson(),
    );
  }
}

/// Mock DocumentSnapshot for pagination cursor
class MockDocumentSnapshot implements DocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;

  MockDocumentSnapshot({required String id, required Map<String, dynamic> data})
      : _id = id,
        _data = data;

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  Object? operator [](Object field) => _data[field];

  @override
  bool get exists => true;

  @override
  DocumentReference<Map<String, dynamic>> get reference =>
      throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  dynamic get(Object field) => _data[field];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Feed notifier provider
final feedNotifierProvider =
    StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final postRepo = ref.watch(postRepositoryProvider);
  return FeedNotifier(postRepo, ref);
});

/// Get user posts provider
final userPostsProvider =
    FutureProvider.family<List<PostModel>, String>((ref, userId) async {
  final postRepo = ref.watch(postRepositoryProvider);
  return postRepo.getUserPosts(userId: userId);
});

/// Watch user posts provider (streaming)
final watchUserPostsProvider =
    StreamProvider.family<List<PostModel>, String>((ref, userId) {
  final postRepo = ref.watch(postRepositoryProvider);
  return postRepo.watchUserPosts(userId);
});

/// Get post by ID provider
final postByIdProvider =
    FutureProvider.family<PostModel?, String>((ref, postId) async {
  final postRepo = ref.watch(postRepositoryProvider);
  return postRepo.getPostById(postId);
});

/// Watch post by ID provider (streaming)
final watchPostByIdProvider =
    StreamProvider.family<PostModel?, String>((ref, postId) {
  final postRepo = ref.watch(postRepositoryProvider);
  return postRepo.watchPostById(postId);
});

/// Get comments for a post provider
final postCommentsProvider =
    FutureProvider.family<List<CommentModel>, String>((ref, postId) async {
  final postRepo = ref.watch(postRepositoryProvider);
  return postRepo.getComments(postId: postId);
});

/// Watch comments for a post provider (streaming)
final watchPostCommentsProvider =
    StreamProvider.family<List<CommentModel>, String>((ref, postId) {
  final postRepo = ref.watch(postRepositoryProvider);
  return postRepo.watchComments(postId);
});

/// Get posts by hashtag provider
final hashtagPostsProvider =
    FutureProvider.family<List<PostModel>, String>((ref, hashtag) async {
  final postRepo = ref.watch(postRepositoryProvider);
  return postRepo.getPostsByHashtag(hashtag: hashtag);
});

/// Get saved posts provider
final savedPostsProvider = FutureProvider<List<PostModel>>((ref) async {
  final postRepo = ref.watch(postRepositoryProvider);
  final userId = ref.watch(firebaseUserIdProviderForPosts);
  if (userId == null) return [];

  return postRepo.getSavedPosts(userId: userId);
});

/// Firebase user ID for posts (re-declared to avoid circular dependency)
final firebaseUserIdProviderForPosts = Provider<String?>((ref) {
  final firebaseUser = ref.watch(firebaseUserForPostsProvider);
  return firebaseUser?.uid;
});

/// Firebase user for posts (re-declared)
final firebaseUserForPostsProvider = Provider<dynamic>((ref) {
  return null; // Will be overridden by auth_provider
});
