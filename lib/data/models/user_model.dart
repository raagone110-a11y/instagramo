import 'package:equatable/equatable.dart';

/// Privacy settings model
class PrivacySettings {
  final bool isPrivate;
  final bool allowMessagesFromAnyone;
  final bool showOnlineStatus;
  final bool showReadReceipts;
  final bool allowTags;
  final bool allowComments;
  final bool showActivityStatus;

  const PrivacySettings({
    this.isPrivate = false,
    this.allowMessagesFromAnyone = true,
    this.showOnlineStatus = true,
    this.showReadReceipts = true,
    this.allowTags = true,
    this.allowComments = true,
    this.showActivityStatus = true,
  });

  Map<String, dynamic> toJson() => {
        'isPrivate': isPrivate,
        'allowMessagesFromAnyone': allowMessagesFromAnyone,
        'showOnlineStatus': showOnlineStatus,
        'showReadReceipts': showReadReceipts,
        'allowTags': allowTags,
        'allowComments': allowComments,
        'showActivityStatus': showActivityStatus,
      };

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      PrivacySettings(
        isPrivate: json['isPrivate'] as bool? ?? false,
        allowMessagesFromAnyone:
            json['allowMessagesFromAnyone'] as bool? ?? true,
        showOnlineStatus: json['showOnlineStatus'] as bool? ?? true,
        showReadReceipts: json['showReadReceipts'] as bool? ?? true,
        allowTags: json['allowTags'] as bool? ?? true,
        allowComments: json['allowComments'] as bool? ?? true,
        showActivityStatus: json['showActivityStatus'] as bool? ?? true,
      );

  PrivacySettings copyWith({
    bool? isPrivate,
    bool? allowMessagesFromAnyone,
    bool? showOnlineStatus,
    bool? showReadReceipts,
    bool? allowTags,
    bool? allowComments,
    bool? showActivityStatus,
  }) =>
      PrivacySettings(
        isPrivate: isPrivate ?? this.isPrivate,
        allowMessagesFromAnyone:
            allowMessagesFromAnyone ?? this.allowMessagesFromAnyone,
        showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
        showReadReceipts: showReadReceipts ?? this.showReadReceipts,
        allowTags: allowTags ?? this.allowTags,
        allowComments: allowComments ?? this.allowComments,
        showActivityStatus: showActivityStatus ?? this.showActivityStatus,
      );
}

/// GeoPoint representation for user location
class UserLocation {
  final double latitude;
  final double longitude;

  const UserLocation({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  factory UserLocation.fromJson(Map<String, dynamic> json) => UserLocation(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      );

  UserLocation copyWith({double? latitude, double? longitude}) =>
      UserLocation(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );
}

/// Main User model for the Instagramo application
class UserModel {
  final String uid;
  final String username;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? bio;
  final String? profilePicUrl;
  final String? coverPhotoUrl;
  final String? website;
  final String? gender;
  final DateTime? dateOfBirth;
  final UserLocation? location;
  final List<String> followers;
  final List<String> following;
  final List<String> blockedUsers;
  final bool isVerified;
  final bool isCreator;
  final bool isOnline;
  final PrivacySettings privacySettings;
  final bool nearbyFriendsEnabled;
  final DateTime? lastActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? totalPosts;
  final int? totalReels;
  final int? totalStories;
  final String? fcmToken;
  final Map<String, dynamic>? socialLinks;
  final String? accountStatus; // 'active', 'suspended', 'deleted'

  const UserModel({
    required this.uid,
    required this.username,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.bio,
    this.profilePicUrl,
    this.coverPhotoUrl,
    this.website,
    this.gender,
    this.dateOfBirth,
    this.location,
    this.followers = const [],
    this.following = const [],
    this.blockedUsers = const [],
    this.isVerified = false,
    this.isCreator = false,
    this.isOnline = false,
    this.privacySettings = const PrivacySettings(),
    this.nearbyFriendsEnabled = false,
    this.lastActive,
    this.createdAt,
    this.updatedAt,
    this.totalPosts = 0,
    this.totalReels = 0,
    this.totalStories = 0,
    this.fcmToken,
    this.socialLinks,
    this.accountStatus = 'active',
  });

  /// Create a [UserModel] from a Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
      profilePicUrl: json['profilePicUrl'] as String?,
      coverPhotoUrl: json['coverPhotoUrl'] as String?,
      website: json['website'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      location: json['location'] != null
          ? UserLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      isVerified: json['isVerified'] as bool? ?? false,
      isCreator: json['isCreator'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      privacySettings: json['privacySettings'] != null
          ? PrivacySettings.fromJson(
              json['privacySettings'] as Map<String, dynamic>)
          : const PrivacySettings(),
      nearbyFriendsEnabled:
          json['nearbyFriendsEnabled'] as bool? ?? false,
      lastActive: json['lastActive'] != null
          ? DateTime.tryParse(json['lastActive'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      totalPosts: json['totalPosts'] as int?,
      totalReels: json['totalReels'] as int?,
      totalStories: json['totalStories'] as int?,
      fcmToken: json['fcmToken'] as String?,
      socialLinks: json['socialLinks'] as Map<String, dynamic>?,
      accountStatus: json['accountStatus'] as String? ?? 'active',
    );
  }

  /// Convert the [UserModel] to a Map for Firestore
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'displayName': displayName,
        'bio': bio,
        'profilePicUrl': profilePicUrl,
        'coverPhotoUrl': coverPhotoUrl,
        'website': website,
        'gender': gender,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'location': location?.toJson(),
        'followers': followers,
        'following': following,
        'blockedUsers': blockedUsers,
        'isVerified': isVerified,
        'isCreator': isCreator,
        'isOnline': isOnline,
        'privacySettings': privacySettings.toJson(),
        'nearbyFriendsEnabled': nearbyFriendsEnabled,
        'lastActive': lastActive?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'totalPosts': totalPosts,
        'totalReels': totalReels,
        'totalStories': totalStories,
        'fcmToken': fcmToken,
        'socialLinks': socialLinks,
        'accountStatus': accountStatus,
      };

  /// Create a copy of this [UserModel] with the given fields replaced
  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? bio,
    String? profilePicUrl,
    String? coverPhotoUrl,
    String? website,
    String? gender,
    DateTime? dateOfBirth,
    UserLocation? location,
    List<String>? followers,
    List<String>? following,
    List<String>? blockedUsers,
    bool? isVerified,
    bool? isCreator,
    bool? isOnline,
    PrivacySettings? privacySettings,
    bool? nearbyFriendsEnabled,
    DateTime? lastActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalPosts,
    int? totalReels,
    int? totalStories,
    String? fcmToken,
    Map<String, dynamic>? socialLinks,
    String? accountStatus,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        username: username ?? this.username,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        displayName: displayName ?? this.displayName,
        bio: bio ?? this.bio,
        profilePicUrl: profilePicUrl ?? this.profilePicUrl,
        coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
        website: website ?? this.website,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        location: location ?? this.location,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        blockedUsers: blockedUsers ?? this.blockedUsers,
        isVerified: isVerified ?? this.isVerified,
        isCreator: isCreator ?? this.isCreator,
        isOnline: isOnline ?? this.isOnline,
        privacySettings: privacySettings ?? this.privacySettings,
        nearbyFriendsEnabled:
            nearbyFriendsEnabled ?? this.nearbyFriendsEnabled,
        lastActive: lastActive ?? this.lastActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        totalPosts: totalPosts ?? this.totalPosts,
        totalReels: totalReels ?? this.totalReels,
        totalStories: totalStories ?? this.totalStories,
        fcmToken: fcmToken ?? this.fcmToken,
        socialLinks: socialLinks ?? this.socialLinks,
        accountStatus: accountStatus ?? this.accountStatus,
      );
}
