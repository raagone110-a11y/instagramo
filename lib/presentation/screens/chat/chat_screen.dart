import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─── Message Data Model ───────────────────────────────────────────────────────

enum MessageType { text, image, voice, system }

enum MessageStatus { sent, delivered, read }

class MessageModel {
  final String id;
  final String content;
  final MessageType type;
  final bool isSentByMe;
  final DateTime timestamp;
  final MessageStatus status;

  MessageModel({
    required this.id,
    required this.content,
    required this.type,
    required this.isSentByMe,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });
}

class ChatUser {
  final String id;
  final String username;
  final String avatar;
  final bool isOnline;
  final bool isVerified;

  ChatUser({
    required this.id,
    required this.username,
    required this.avatar,
    this.isOnline = true,
    this.isVerified = false,
  });
}

// ─── Chat Providers ───────────────────────────────────────────────────────────

final chatUserProvider = StateProvider<ChatUser>((ref) => ChatUser(
      id: '1',
      username: 'sarah_travels',
      avatar: 'https://i.pravatar.cc/100?img=1',
      isOnline: true,
      isVerified: true,
    ));

final messagesProvider = StateProvider<List<MessageModel>>((ref) => [
      MessageModel(
        id: '1',
        content: 'Hey! How are you doing?',
        type: MessageType.text,
        isSentByMe: false,
        timestamp:
            DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      ),
      MessageModel(
        id: '2',
        content: "I'm great! Just got back from Bali 🌴",
        type: MessageType.text,
        isSentByMe: true,
        timestamp:
            DateTime.now().subtract(const Duration(hours: 2, minutes: 28)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: '3',
        content: 'That photo from Bali was amazing! 📸',
        type: MessageType.text,
        isSentByMe: false,
        timestamp:
            DateTime.now().subtract(const Duration(hours: 2, minutes: 25)),
      ),
      MessageModel(
        id: '4',
        content: 'Thank you! The sunsets there were incredible',
        type: MessageType.text,
        isSentByMe: true,
        timestamp:
            DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: '5',
        content: 'Would you recommend the Ubud area?',
        type: MessageType.text,
        isSentByMe: false,
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
      MessageModel(
        id: '6',
        content:
            "Absolutely! The rice terraces and temples are breathtaking. Let me send you some pics!",
        type: MessageType.text,
        isSentByMe: true,
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: '7',
        content: 'That would be amazing! 😍',
        type: MessageType.text,
        isSentByMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      MessageModel(
        id: '8',
        content: 'https://picsum.photos/seed/chat1/400/300',
        type: MessageType.image,
        isSentByMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        status: MessageStatus.delivered,
      ),
      MessageModel(
        id: '9',
        content: 'The Tegallalang Rice Terrace at sunrise! 🌅',
        type: MessageType.text,
        isSentByMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 24)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: '10',
        content: 'Wow, that is absolutely stunning!',
        type: MessageType.text,
        isSentByMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ]);

final messageInputProvider = StateProvider<String>((ref) => '');
final isTypingProvider = StateProvider<bool>((ref) => false);
final scrollControllerProvider = Provider((ref) => ScrollController());

// ─── Chat Screen ──────────────────────────────────────────────────────────────

class ChatScreen extends ConsumerWidget {
  final String? chatId;

  const ChatScreen({this.chatId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(chatUserProvider);
    final messages = ref.watch(messagesProvider);
    final isTyping = ref.watch(isTypingProvider);
    final scrollController = ref.watch(scrollControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context, user),
      body: Column(
        children: [
          // ── Messages List ──────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              reverse: true,
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (isTyping && index == 0) {
                  return const _TypingIndicator()
                      .animate()
                      .fade(duration: 300.ms);
                }
                final messageIndex = isTyping ? index - 1 : index;
                if (messageIndex >= messages.length)
                  return const SizedBox.shrink();
                final message = messages[messages.length - 1 - messageIndex];
                return _MessageBubble(message: message);
              },
            ),
          ),

          // ── Input Bar ──────────────────────────────────────────────────────
          _ChatInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatUser user) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Theme.of(context).colorScheme.onSurface,
          size: 22,
        ),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: ClipOval(
                child: Image.network(
                  user.avatar,
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person,
                    size: 20,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    user.username,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (user.isVerified)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  if (user.isOnline)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Text(
                    user.isOnline ? 'Online' : 'Offline',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.phone_outlined,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.videocam_outlined,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final MessageModel message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSentByMe;

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isSent ? 60 : 0,
          right: isSent ? 0 : 60,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 10,
                  bottom: message.type == MessageType.image ? 4 : 10,
                ),
                decoration: BoxDecoration(
                  color: isSent
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isSent ? 18 : 4),
                    bottomRight: Radius.circular(isSent ? 4 : 18),
                  ),
                ),
                child: message.type == MessageType.image
                    ? _buildImageMessage(context)
                    : _buildTextMessage(context),
              ),
            ),
            if (isSent)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _buildStatusIcon(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextMessage(BuildContext context) {
    return Text(
      message.content,
      style: TextStyle(
        color: message.isSentByMe
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        message.content,
        width: 240,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 240,
          height: 160,
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.5),
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    switch (message.status) {
      case MessageStatus.sent:
        return Icon(
          Icons.check_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Typing Indicator ─────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4, right: 80),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 150),
            const SizedBox(width: 4),
            _Dot(delay: 300),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final int delay;

  const _Dot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .then(delay: Duration(milliseconds: delay))
        .moveY(
          begin: -4,
          end: 4,
          duration: 400.ms,
          curve: Curves.easeInOut,
        );
  }
}

// ─── Chat Input Bar ───────────────────────────────────────────────────────────

class _ChatInputBar extends ConsumerStatefulWidget {
  const _ChatInputBar();

  @override
  ConsumerState<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<_ChatInputBar> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = ref.read(messageInputProvider);
    if (text.trim().isEmpty) return;

    final messages = ref.read(messagesProvider);
    final newMessage = MessageModel(
      id: (messages.length + 1).toString(),
      content: text.trim(),
      type: MessageType.text,
      isSentByMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    ref.read(messagesProvider.notifier).state = [...messages, newMessage];
    ref.read(messageInputProvider.notifier).state = '';

    // Simulate typing response
    Future.delayed(const Duration(seconds: 1), () {
      ref.read(isTypingProvider.notifier).state = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      ref.read(isTypingProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Image Attachment
          IconButton(
            icon: Icon(
              Icons.photo_camera_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            onPressed: () {
              // Open image picker
            },
          ),

          // Voice/Attachment
          IconButton(
            icon: Icon(
              Icons.attach_file_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            onPressed: () {
              // Open attachment options
            },
          ),

          const SizedBox(width: 4),

          // Text Input
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: TextEditingController.fromValue(
                TextEditingValue(text: ref.read(messageInputProvider)),
              ),
              onChanged: (value) =>
                  ref.read(messageInputProvider.notifier).state = value,
              onSubmitted: (_) => _sendMessage(),
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Send Button
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(21),
            ),
            child: IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
