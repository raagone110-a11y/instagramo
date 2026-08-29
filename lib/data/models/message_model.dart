/// Message type enumeration
enum MessageType {
  text,
  image,
  video,
  voice,
  document,
  sticker,
  gif,
  system;

  String get value => name;

  static MessageType fromString(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'voice':
        return MessageType.voice;
      case 'document':
        return MessageType.document;
      case 'sticker':
        return MessageType.sticker;
      case 'gif':
        return MessageType.gif;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }
}

/// Message status
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed;

  String get value => name;

  static MessageStatus fromString(String status) {
    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }
}

/// Message reply
class MessageReply {
  final String messageId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;

  const MessageReply({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'type': type.value,
      };

  factory MessageReply.fromJson(Map<String, dynamic> json) => MessageReply(
        messageId: json['messageId'] as String? ?? '',
        senderId: json['senderId'] as String? ?? '',
        senderName: json['senderName'] as String? ?? '',
        content: json['content'] as String? ?? '',
        type: MessageType.fromString(json['type'] as String? ?? 'text'),
      );
}

/// Main Message model
class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String chatId;
  final String content;
  final MessageType type;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final int? mediaDuration; // in seconds, for voice/video
  final MessageReply? replyTo;
  final List<String> reactions; // user IDs who reacted
  final Map<String, String> reactionDetails; // {userId: emoji}
  final MessageStatus status;
  final DateTime? readAt;
  final DateTime? deliveredAt;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime createdAt;

  const MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.chatId,
    required this.content,
    required this.type,
    this.mediaUrl,
    this.thumbnailUrl,
    this.mediaDuration,
    this.replyTo,
    this.reactions = const [],
    this.reactionDetails = const {},
    this.status = MessageStatus.sending,
    this.readAt,
    this.deliveredAt,
    this.editedAt,
    this.isDeleted = false,
    required this.createdAt,
  });

  /// Create a [MessageModel] from a Firestore document
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: MessageType.fromString(json['type'] as String? ?? 'text'),
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      mediaDuration: json['mediaDuration'] as int?,
      replyTo: json['replyTo'] != null
          ? MessageReply.fromJson(json['replyTo'] as Map<String, dynamic>)
          : null,
      reactions: List<String>.from(json['reactions'] ?? []),
      reactionDetails:
          Map<String, String>.from(json['reactionDetails'] ?? {}),
      status: MessageStatus.fromString(json['status'] as String? ?? 'sent'),
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'] as String)
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'] as String)
          : null,
      editedAt: json['editedAt'] != null
          ? DateTime.tryParse(json['editedAt'] as String)
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert the [MessageModel] to a Map for Firestore
  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'senderId': senderId,
        'receiverId': receiverId,
        'chatId': chatId,
        'content': content,
        'type': type.value,
        'mediaUrl': mediaUrl,
        'thumbnailUrl': thumbnailUrl,
        'mediaDuration': mediaDuration,
        'replyTo': replyTo?.toJson(),
        'reactions': reactions,
        'reactionDetails': reactionDetails,
        'status': status.value,
        'readAt': readAt?.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'editedAt': editedAt?.toIso8601String(),
        'isDeleted': isDeleted,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Create a copy of this [MessageModel] with the given fields replaced
  MessageModel copyWith({
    String? messageId,
    String? senderId,
    String? receiverId,
    String? chatId,
    String? content,
    MessageType? type,
    String? mediaUrl,
    String? thumbnailUrl,
    int? mediaDuration,
    MessageReply? replyTo,
    List<String>? reactions,
    Map<String, String>? reactionDetails,
    MessageStatus? status,
    DateTime? readAt,
    DateTime? deliveredAt,
    DateTime? editedAt,
    bool? isDeleted,
    DateTime? createdAt,
  }) =>
      MessageModel(
        messageId: messageId ?? this.messageId,
        senderId: senderId ?? this.senderId,
        receiverId: receiverId ?? this.receiverId,
        chatId: chatId ?? this.chatId,
        content: content ?? this.content,
        type: type ?? this.type,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        mediaDuration: mediaDuration ?? this.mediaDuration,
        replyTo: replyTo ?? this.replyTo,
        reactions: reactions ?? this.reactions,
        reactionDetails: reactionDetails ?? this.reactionDetails,
        status: status ?? this.status,
        readAt: readAt ?? this.readAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
        editedAt: editedAt ?? this.editedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
      );
}

/// Chat model representing a conversation between users
class ChatModel {
  final String chatId;
  final List<String> participantIds;
  final Map<String, String> participantNames; // {userId: displayName}
  final Map<String, String> participantAvatars; // {userId: avatarUrl}
  final String? lastMessage;
  final MessageType? lastMessageType;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final Map<String, DateTime> lastReadAt; // {userId: DateTime}
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;
  final bool isGroup;
  final String? groupName;
  final String? groupAvatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChatModel({
    required this.chatId,
    required this.participantIds,
    this.participantNames = const {},
    this.participantAvatars = const {},
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.lastReadAt = const {},
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.isGroup = false,
    this.groupName,
    this.groupAvatarUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a [ChatModel] from a Firestore document
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['chatId'] as String? ?? '',
      participantIds: List<String>.from(json['participantIds'] ?? []),
      participantNames:
          Map<String, String>.from(json['participantNames'] ?? {}),
      participantAvatars:
          Map<String, String>.from(json['participantAvatars'] ?? {}),
      lastMessage: json['lastMessage'] as String?,
      lastMessageType: json['lastMessageType'] != null
          ? MessageType.fromString(json['lastMessageType'] as String)
          : null,
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'] as String)
          : null,
      lastReadAt: json['lastReadAt'] != null
          ? Map<String, DateTime>.from(
              (json['lastReadAt'] as Map).map(
                (key, value) => MapEntry(
                  key,
                  DateTime.tryParse(value as String) ?? DateTime.now(),
                ),
              ),
            )
          : const {},
      unreadCount: json['unreadCount'] as int? ?? 0,
      isMuted: json['isMuted'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      isGroup: json['isGroup'] as bool? ?? false,
      groupName: json['groupName'] as String?,
      groupAvatarUrl: json['groupAvatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert the [ChatModel] to a Map for Firestore
  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'participantIds': participantIds,
        'participantNames': participantNames,
        'participantAvatars': participantAvatars,
        'lastMessage': lastMessage,
        'lastMessageType': lastMessageType?.value,
        'lastMessageSenderId': lastMessageSenderId,
        'lastMessageAt': lastMessageAt?.toIso8601String(),
        'lastReadAt': lastReadAt.map(
          (key, value) => MapEntry(key, value.toIso8601String()),
        ),
        'unreadCount': unreadCount,
        'isMuted': isMuted,
        'isPinned': isPinned,
        'isGroup': isGroup,
        'groupName': groupName,
        'groupAvatarUrl': groupAvatarUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  ChatModel copyWith({
    String? chatId,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String>? participantAvatars,
    String? lastMessage,
    MessageType? lastMessageType,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,
    Map<String, DateTime>? lastReadAt,
    int? unreadCount,
    bool? isMuted,
    bool? isPinned,
    bool? isGroup,
    String? groupName,
    String? groupAvatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ChatModel(
        chatId: chatId ?? this.chatId,
        participantIds: participantIds ?? this.participantIds,
        participantNames: participantNames ?? this.participantNames,
        participantAvatars:
            participantAvatars ?? this.participantAvatars,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageType: lastMessageType ?? this.lastMessageType,
        lastMessageSenderId:
            lastMessageSenderId ?? this.lastMessageSenderId,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        lastReadAt: lastReadAt ?? this.lastReadAt,
        unreadCount: unreadCount ?? this.unreadCount,
        isMuted: isMuted ?? this.isMuted,
        isPinned: isPinned ?? this.isPinned,
        isGroup: isGroup ?? this.isGroup,
        groupName: groupName ?? this.groupName,
        groupAvatarUrl: groupAvatarUrl ?? this.groupAvatarUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
