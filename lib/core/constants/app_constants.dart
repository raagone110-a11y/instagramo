/// App-wide constants for Instagramo
class AppConstants {
  // App info
  static const String appName = 'Instagramo';
  static const String appTagline = 'Share Your Moment';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API & Firebase
  static const String firebaseProjectId = 'instagramo-project';
  static const String firebaseStorageBucket = 'instagramo-project.appspot.com';
  static const String defaultProfilePicture =
      'https://firebasestorage.googleapis.com/v0/b/instagramo-project/o/defaults%2Fprofile_placeholder.png?alt=media';
  static const String defaultCoverImage =
      'https://firebasestorage.googleapis.com/v0/b/instagramo-project/o/defaults%2Fcover_placeholder.png?alt=media';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String storiesCollection = 'stories';
  static const String messagesCollection = 'messages';
  static const String chatsCollection = 'chats';
  static const String notificationsCollection = 'notifications';
  static const String commentsCollection = 'comments';
  static const String likesCollection = 'likes';
  static const String followsCollection = 'follows';
  static const String savesCollection = 'saves';
  static const String reportsCollection = 'reports';
  static const String analyticsCollection = 'analytics';
  static const String settingsCollection = 'settings';
  static const String blockedUsersCollection = 'blocked_users';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String postImagesPath = 'post_images';
  static const String postVideosPath = 'post_videos';
  static const String storyMediaPath = 'story_media';
  static const String chatMediaPath = 'chat_media';
  static const String voiceMessagesPath = 'voice_messages';
  static const String reelsPath = 'reels';

  // Pagination
  static const int feedPageSize = 10;
  static const int searchPageSize = 20;
  static const int storiesPageSize = 10;
  static const int messagesPageSize = 30;
  static const int followersPageSize = 20;
  static const int nearbyFriendsPageSize = 15;

  // Limits
  static const int maxCaptionLength = 2200;
  static const int maxBioLength = 150;
  static const int maxUsernameLength = 30;
  static const int maxHashtagsPerPost = 30;
  static const int maxMediaPerPost = 10;
  static const int maxStoriesPerUser = 50;
  static const int maxStoryDurationSeconds = 15;
  static const int maxStoryLifespanHours = 24;
  static const int maxVideoDurationSeconds = 90;
  static const int maxReelDurationSeconds = 90;
  static const int maxImageFileSizeMB = 10;
  static const int maxVideoFileSizeMB = 100;
  static const int maxVoiceMessageSeconds = 60;
  static const int maxChatParticipants = 100;

  // Cache
  static const Duration cacheDuration = Duration(days: 7);
  static const Duration storyCacheDuration = Duration(hours: 1);
  static const Duration profileCacheDuration = Duration(days: 1);

  // Geolocation
  static const double nearbyFriendsRadiusKm = 10.0;
  static const double defaultLatitude = 0.0;
  static const double defaultLongitude = 0.0;
  static const int locationUpdateIntervalMs = 60000;

  // Notifications
  static const String likeNotificationChannelId = 'likes';
  static const String likeNotificationChannelName = 'Likes';
  static const String commentNotificationChannelId = 'comments';
  static const String commentNotificationChannelName = 'Comments';
  static const String followNotificationChannelId = 'follows';
  static const String followNotificationChannelName = 'Follows';
  static const String messageNotificationChannelId = 'messages';
  static const String messageNotificationChannelName = 'Messages';
  static const String storyNotificationChannelId = 'stories';
  static const String storyNotificationChannelName = 'Stories';
  static const String systemNotificationChannelId = 'system';
  static const String systemNotificationChannelName = 'System';

  // Shared Preferences Keys
  static const String themeModeKey = 'theme_mode';
  static const String userIdKey = 'user_id';
  static const String authTokenKey = 'auth_token';
  static const String fcmTokenKey = 'fcm_token';
  static const String locationEnabledKey = 'location_enabled';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String pushNotificationsEnabledKey = 'push_notifications';
  static const String lastLocationKey = 'last_location';

  // Validation
  static final RegExp emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp usernameRegExp = RegExp(
    r'^[a-zA-Z0-9_\.]+$',
  );
  static final RegExp phoneRegExp = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );
  static final RegExp urlRegExp = RegExp(
    r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
  );
  static final RegExp hashtagRegExp = RegExp(r'#([a-zA-Z0-9_]+)');

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // Asset paths
  static const String logoPath = 'assets/images/logo.png';
  static const String defaultAvatarPath = 'assets/images/default_avatar.png';
  static const String emptyFeedPath = 'assets/images/empty_feed.png';
  static const String noStoriesPath = 'assets/images/no_stories.png';
  static const String errorIllustrationPath = 'assets/images/error.png';
  static const String onboardingIllustrationPath =
      'assets/images/onboarding.png';

  // Error messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String uploadError = 'Upload failed. Please try again.';
  static const String permissionError = 'Permission denied.';
  static const String sessionExpired = 'Session expired. Please log in again.';
  static const String accountDisabled =
      'Your account has been disabled. Please contact support.';
  static const String rateLimited =
      'Too many requests. Please try again later.';
  static const String fileTooLarge = 'File size exceeds the maximum limit.';
  static const String unsupportedFormat = 'Unsupported file format.';
  static const String blockedError = 'You have been blocked by this user.';
}

/// Media type enumeration
enum MediaType {
  image,
  video,
  carousel,
  voice,
  document;

  String get value => name;

  static MediaType fromString(String type) {
    switch (type) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      case 'carousel':
        return MediaType.carousel;
      case 'voice':
        return MediaType.voice;
      case 'document':
        return MediaType.document;
      default:
        return MediaType.image;
    }
  }
}

/// Privacy settings enumeration
enum PrivacySetting {
  public,
  private,
  friendsOnly,
  custom;

  String get value => name;

  static PrivacySetting fromString(String setting) {
    switch (setting) {
      case 'public':
        return PrivacySetting.public;
      case 'private':
        return PrivacySetting.private;
      case 'friends_only':
        return PrivacySetting.friendsOnly;
      case 'custom':
        return PrivacySetting.custom;
      default:
        return PrivacySetting.public;
    }
  }
}

/// Verification status
enum VerificationStatus {
  none,
  pending,
  verified,
  rejected;

  String get value => name;

  static VerificationStatus fromString(String status) {
    switch (status) {
      case 'none':
        return VerificationStatus.none;
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.none;
    }
  }
}
