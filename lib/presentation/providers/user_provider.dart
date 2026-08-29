import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_provider.dart';

/// Current user model provider
final currentUserModelProvider = FutureProvider<UserModel?>((ref) async {
  final userId = ref.watch(firebaseUserIdProvider);
  if (userId == null) return null;

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getUserById(userId);
});

/// Watch current user model (streaming)
final watchCurrentUserModelProvider = StreamProvider<UserModel?>((ref) {
  final userId = ref.watch(firebaseUserIdProvider);
  if (userId == null) return Stream.value(null);

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.watchUserById(userId);
});

/// Firebase user ID provider
final firebaseUserIdProvider = Provider<String?>((ref) {
  final firebaseUser = ref.watch(firebaseUserProvider);
  return firebaseUser.valueOrNull?.uid;
});

/// User state model
class UserState {
  final UserModel? currentUser;
  final bool isLoading;
  final String? errorMessage;
  final bool isUpdating;

  const UserState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
    this.isUpdating = false,
  });

  UserState copyWith({
    UserModel? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool? isUpdating,
  }) =>
      UserState(
        currentUser: currentUser ?? this.currentUser,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        isUpdating: isUpdating ?? this.isUpdating,
      );
}

/// User notifier
class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _userRepository;
  final Ref _ref;

  UserNotifier(this._userRepository, this._ref)
      : super(const UserState());

  /// Load current user
  Future<void> loadCurrentUser(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await _userRepository.getUserById(userId);
      state = state.copyWith(currentUser: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load user by ID
  Future<UserModel?> loadUser(String userId) async {
    try {
      return await _userRepository.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUser(UserModel user) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      await _userRepository.updateUser(user);
      state = state.copyWith(
        currentUser: user,
        isUpdating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Update user bio
  Future<bool> updateBio(String bio) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final userId = state.currentUser?.uid;
      if (userId == null) return false;

      await _userRepository.updateUserFields(userId, {'bio': bio});

      state = state.copyWith(
        currentUser: state.currentUser!.copyWith(bio: bio),
        isUpdating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Update user profile picture
  Future<bool> updateProfilePicture(File imageFile) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final userId = state.currentUser?.uid;
      if (userId == null) return false;

      final downloadUrl = await _userRepository.uploadProfilePicture(
        uid: userId,
        imageFile: imageFile,
      );

      state = state.copyWith(
        currentUser: state.currentUser!.copyWith(profilePicUrl: downloadUrl),
        isUpdating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Update user cover photo
  Future<bool> updateCoverPhoto(File imageFile) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final userId = state.currentUser?.uid;
      if (userId == null) return false;

      final downloadUrl = await _userRepository.uploadCoverPhoto(
        uid: userId,
        imageFile: imageFile,
      );

      state = state.copyWith(
        currentUser: state.currentUser!.copyWith(coverPhotoUrl: downloadUrl),
        isUpdating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Follow a user
  Future<bool> followUser(String targetUserId) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final currentUserId = state.currentUser?.uid;
      if (currentUserId == null) return false;

      await _userRepository.followUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );

      state = state.copyWith(
        currentUser: state.currentUser!.copyWith(
          following: [...state.currentUser!.following, targetUserId],
        ),
        isUpdating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Unfollow a user
  Future<bool> unfollowUser(String targetUserId) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final currentUserId = state.currentUser?.uid;
      if (currentUserId == null) return false;

      await _userRepository.unfollowUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );

      state = state.copyWith(
        currentUser: state.currentUser!.copyWith(
          following:
              state.currentUser!.following.where((id) => id != targetUserId).toList(),
        ),
        isUpdating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Block a user
  Future<bool> blockUser(String targetUserId) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final currentUserId = state.currentUser?.uid;
      if (currentUserId == null) return false;

      await _userRepository.blockUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );

      state = state.copyWith(
        currentUser: state.currentUser!.copyWith(
          blockedUsers: [
            ...state.currentUser!.blockedUsers,
            targetUserId,
          ],
        ),
        isUpdating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Unblock a user
  Future<bool> unblockUser(String targetUserId) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final currentUserId = state.currentUser?.uid;
      if (currentUserId == null) return false;

      await _userRepository.unblockUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );

      state = state.copyWith(
        currentUser: state.currentUser!.copyWith(
          blockedUsers: state.currentUser!.blockedUsers
              .where((id) => id != targetUserId)
              .toList(),
        ),
        isUpdating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Update privacy settings
  Future<bool> updatePrivacySettings(PrivacySettings settings) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final userId = state.currentUser?.uid;
      if (userId == null) return false;

      await _userRepository.updatePrivacySettings(uid: userId, settings: settings);

      state = state.copyWith(
        currentUser: state.currentUser!.copyWith(privacySettings: settings),
        isUpdating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Update user's location
  Future<bool> updateLocation(double latitude, double longitude) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final userId = state.currentUser?.uid;
      if (userId == null) return false;

      await _userRepository.updateLocation(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
      );

      state = state.copyWith(
        currentUser: state.currentUser!.copyWith(
          location: UserLocation(latitude: latitude, longitude: longitude),
        ),
        isUpdating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Get suggested users
  Future<List<UserModel>> getSuggestedUsers(int limit) async {
    final currentUserId = state.currentUser?.uid;
    if (currentUserId == null) return [];

    try {
      return await _userRepository.getSuggestedUsers(
        currentUserId: currentUserId,
        limit: limit,
      );
    } catch (e) {
      return [];
    }
  }

  /// Search users
  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    try {
      return await _userRepository.searchUsers(query: query, limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Get followers
  Future<List<UserModel>> getFollowers(String userId, {int limit = 20}) async {
    try {
      return await _userRepository.getFollowers(userId: userId, limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Get following
  Future<List<UserModel>> getFollowing(String userId, {int limit = 20}) async {
    try {
      return await _userRepository.getFollowing(userId: userId, limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Get nearby friends
  Future<List<UserModel>> getNearbyFriends({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int limit = 15,
  }) async {
    final currentUserId = state.currentUser?.uid;
    if (currentUserId == null) return [];

    try {
      return await _userRepository.getNearbyFriends(
        userId: currentUserId,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        limit: limit,
      );
    } catch (e) {
      return [];
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// User notifier provider
final userNotifierProvider =
    StateNotifierProvider<UserNotifier, UserState>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return UserNotifier(userRepo, ref);
});

/// Check if current user follows target user
final isFollowingProvider =
    FutureProvider.family<bool, String>((ref, targetUserId) async {
  final currentUserId = ref.watch(firebaseUserIdProvider);
  if (currentUserId == null) return false;

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.isFollowing(
    currentUserId: currentUserId,
    targetUserId: targetUserId,
  );
});

/// Get followers list provider
final followersProvider = FutureProvider.family<List<UserModel>, String>((ref, userId) async {
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getFollowers(userId: userId);
});

/// Get following list provider
final followingProvider = FutureProvider.family<List<UserModel>, String>((ref, userId) async {
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getFollowing(userId: userId);
});

/// Suggested users provider
final suggestedUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final currentUserId = ref.watch(firebaseUserIdProvider);
  if (currentUserId == null) return [];

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getSuggestedUsers(currentUserId: currentUserId);
});
