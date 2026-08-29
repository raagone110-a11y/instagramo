import 'dart:math' as math;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Custom user exception
class UserException implements Exception {
  final String message;
  final String code;
  const UserException(this.message, this.code);

  @override
  String toString() => 'UserException($code): $message';
}

/// User repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

/// User repository handling all user-related Firestore operations
class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  // ============================================================================
  // Get User
  // ============================================================================

  /// Get a user by UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.genericError,
        'fetch_user_error',
      );
    }
  }

  /// Stream a user by UID
  Stream<UserModel?> watchUserById(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    });
  }

  /// Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return UserModel.fromJson(querySnapshot.docs.first.data());
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.genericError,
        'fetch_user_error',
      );
    }
  }

  /// Check if a username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // Create User
  // ============================================================================

  /// Create a new user document in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toJson());
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.genericError,
        'create_user_error',
      );
    }
  }

  // ============================================================================
  // Update User
  // ============================================================================

  /// Update a user profile
  Future<void> updateUser(UserModel user) async {
    try {
      final data = user.toJson();
      data['updatedAt'] = DateTime.now().toIso8601String();
      data.remove('uid'); // Cannot update uid

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(data);
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.genericError,
        'update_user_error',
      );
    }
  }

  /// Update specific fields of a user
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    try {
      fields['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(fields);
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.genericError,
        'update_user_error',
      );
    }
  }

  /// Update user's profile picture
  Future<String> uploadProfilePicture({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final storageRef = _storage
          .ref()
          .child('${AppConstants.profileImagesPath}/$uid/profile.jpg');

      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update user document with new profile picture
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'profilePicUrl': downloadUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.uploadError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.uploadError,
        'upload_profile_pic_error',
      );
    }
  }

  /// Update user's cover photo
  Future<String> uploadCoverPhoto({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final storageRef = _storage
          .ref()
          .child('${AppConstants.profileImagesPath}/$uid/cover.jpg');

      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'coverPhotoUrl': downloadUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.uploadError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.uploadError,
        'upload_cover_photo_error',
      );
    }
  }

  // ============================================================================
  // Follow/Unfollow
  // ============================================================================

  /// Follow a user
  Future<void> followUser({required String currentUserId, required String targetUserId}) async {
    try {
      final batch = _firestore.batch();

      // Add target user to current user's following
      batch.update(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(currentUserId),
        {
          'following': FieldValue.arrayUnion([targetUserId]),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      // Add current user to target user's followers
      batch.update(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(targetUserId),
        {
          'followers': FieldValue.arrayUnion([currentUserId]),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      // Create follow record
      batch.set(
        _firestore
            .collection(AppConstants.followsCollection)
            .doc('${currentUserId}_$targetUserId'),
        {
          'followerId': currentUserId,
          'followingId': targetUserId,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      await batch.commit();
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.genericError,
        'follow_error',
      );
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser({required String currentUserId, required String targetUserId}) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(currentUserId),
        {
          'following': FieldValue.arrayRemove([targetUserId]),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      batch.update(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(targetUserId),
        {
          'followers': FieldValue.arrayRemove([currentUserId]),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      batch.delete(
        _firestore
            .collection(AppConstants.followsCollection)
            .doc('${currentUserId}_$targetUserId'),
      );

      await batch.commit();
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.genericError,
        'unfollow_error',
      );
    }
  }

  /// Check if current user follows target user
  Future<bool> isFollowing({required String currentUserId, required String targetUserId}) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .get();

      final following = List<String>.from(doc.data()?['following'] ?? []);
      return following.contains(targetUserId);
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // Followers/Following
  // ============================================================================

  /// Get user's followers
  Future<List<UserModel>> getFollowers({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      final user = await getUserById(userId);
      final followerIds = user?.followers ?? [];

      if (followerIds.isEmpty) return [];

      Query<Map<String, dynamic>> query = _firestore
          .collection(AppConstants.usersCollection)
          .where('uid', whereIn: followerIds)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.genericError,
        'fetch_followers_error',
      );
    }
  }

  /// Get user's following
  Future<List<UserModel>> getFollowing({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      final user = await getUserById(userId);
      final followingIds = user?.following ?? [];

      if (followingIds.isEmpty) return [];

      Query<Map<String, dynamic>> query = _firestore
          .collection(AppConstants.usersCollection)
          .where('uid', whereIn: followingIds)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.genericError,
        'fetch_following_error',
      );
    }
  }

  // ============================================================================
  // Search
  // ============================================================================

  /// Search users by username or display name
  Future<List<UserModel>> searchUsers({
    required String query,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('username', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.genericError,
        'search_users_error',
      );
    }
  }

  // ============================================================================
  // Nearby Friends
  // ============================================================================

  /// Get nearby friends based on geolocation
  Future<List<UserModel>> getNearbyFriends({
    required String userId,
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int limit = 15,
  }) async {
    try {
      // Get current user's following list
      final currentUser = await getUserById(userId);
      final followingIds = currentUser?.following ?? [];

      if (followingIds.isEmpty) return [];

      // Query nearby users (simplified - in production, use GeoFirestore)
      final nearbyUsers = <UserModel>[];

      for (final followingId in followingIds) {
        final user = await getUserById(followingId);
        if (user != null && user.nearbyFriendsEnabled && user.location != null) {
          final distance = _calculateDistance(
            latitude,
            longitude,
            user.location!.latitude,
            user.location!.longitude,
          );

          if (distance <= radiusKm) {
            nearbyUsers.add(user);
          }
        }

        if (nearbyUsers.length >= limit) break;
      }

      return nearbyUsers;
    } catch (e) {
      throw UserException(
        AppConstants.genericError,
        'nearby_friends_error',
      );
    }
  }

  /// Update user's location
  Future<void> updateLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  // ============================================================================
  // Block/Unblock
  // ============================================================================

  /// Block a user
  Future<void> blockUser({required String currentUserId, required String targetUserId}) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(currentUserId),
        {
          'blockedUsers': FieldValue.arrayUnion([targetUserId]),
          'following': FieldValue.arrayRemove([targetUserId]),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      batch.update(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(targetUserId),
        {
          'followers': FieldValue.arrayRemove([currentUserId]),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      await batch.commit();
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  /// Unblock a user
  Future<void> unblockUser({required String currentUserId, required String targetUserId}) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .update({
        'blockedUsers': FieldValue.arrayRemove([targetUserId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  // ============================================================================
  // Delete User
  // ============================================================================

  /// Delete a user account (soft delete)
  Future<void> deactivateAccount(String uid) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'accountStatus': 'deleted',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  // ============================================================================
  // Suggested Users
  // ============================================================================

  /// Get suggested users to follow
  Future<List<UserModel>> getSuggestedUsers({
    required String currentUserId,
    int limit = 10,
  }) async {
    try {
      // Get users that the current user doesn't follow
      final currentUser = await getUserById(currentUserId);
      final followingIds = currentUser?.following ?? [];

      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('uid', isNotEqualTo: currentUserId)
          .where('accountStatus', isEqualTo: 'active')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .where((user) => !followingIds.contains(user.uid))
          .toList();
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    } catch (e) {
      throw UserException(
        AppConstants.genericError,
        'suggested_users_error',
      );
    }
  }

  // ============================================================================
  // Privacy Settings
  // ============================================================================

  /// Update user's privacy settings
  Future<void> updatePrivacySettings({
    required String uid,
    required PrivacySettings settings,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'privacySettings': settings.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw UserException(
        e.message ?? AppConstants.genericError,
        e.code,
      );
    }
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) =>
      degrees * (math.pi / 180);
}
