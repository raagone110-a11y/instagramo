import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─── Chat Data Models ─────────────────────────────────────────────────────────

class ConversationModel {
  final String id;
  final String username;
  final String avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isTyping;
  final bool isVerified;

  ConversationModel({
    required this.id,
    required this.username,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isTyping = false,
    this.isVerified = false,
  });
}

// ─── Chat List Provider ───────────────────────────────────────────────────────

final conversationsProvider = StateProvider<List<ConversationModel>>((ref) => [
      ConversationModel(
        id: '1',
        username: 'sarah_travels',
        avatar: 'https://i.pravatar.cc/100?img=1',
        lastMessage: 'That photo from Bali was amazing! 📸',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        isOnline: true,
        isVerified: true,
      ),
      ConversationModel(
        id: '2',
        username: 'alex_photo',
        avatar: 'https://i.pravatar.cc/100?img=2',
        lastMessage: 'Hey! Are you free this weekend?',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
        unreadCount: 0,
        isOnline: true,
      ),
      ConversationModel(
        id: '3',
        username: 'foodie_mike',
        avatar: 'https://i.pravatar.cc/100?img=3',
        lastMessage: 'The restaurant was incredible!',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
        unreadCount: 5,
        isOnline: false,
        isVerified: true,
      ),
      ConversationModel(
        id: '4',
        username: 'fit_emma',
        avatar: 'https://i.pravatar.cc/100?img=4',
        lastMessage: 'Don\'t forget about the gym session tomorrow!',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
        unreadCount: 0,
        isOnline: false,
      ),
      ConversationModel(
        id: '5',
        username: 'art_studio',
        avatar: 'https://i.pravatar.cc/100?img=5',
        lastMessage: 'Just finished a new piece, check it out!',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 8)),
        unreadCount: 1,
        isOnline: true,
        isVerified: true,
      ),
      ConversationModel(
        id: '6',
        username: 'music_lover',
        avatar: 'https://i.pravatar.cc/100?img=6',
        lastMessage: 'Check out this playlist I made for you',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 12)),
        unreadCount: 0,
        isOnline: false,
      ),
      ConversationModel(
        id: '7',
        username: 'dev_tom',
        avatar: 'https://i.pravatar.cc/100?img=7',
        lastMessage: 'The app update is ready for review',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 18)),
        unreadCount: 0,
        isOnline: false,
      ),
      ConversationModel(
        id: '8',
        username: 'yoga_lisa',
        avatar: 'https://i.pravatar.cc/100?img=8',
        lastMessage: 'Morning meditation session was peaceful',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
        isOnline: false,
      ),
    ]);

final searchQueryProvider = StateProvider<String>((ref) => '');

// ─── Chat List Screen ─────────────────────────────────────────────────────────

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final filteredConversations = searchQuery.isEmpty
        ? conversations
        : conversations
            .where((c) =>
                c.username.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
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
        title: Text(
          'Messages',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                        onPressed: () =>
                            ref.read(searchQueryProvider.notifier).state = '',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0),

          // ── Conversations List ─────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredConversations.length,
              separatorBuilder: (_, __) => Divider(
                height: 0,
                indent: 76,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
              itemBuilder: (context, index) {
                final conversation = filteredConversations[index];
                return _ConversationTile(
                  conversation: conversation,
                  onTap: () => context.push('/chat/${conversation.id}'),
                )
                    .animate(delay: Duration(milliseconds: 50 * index))
                    .fade(duration: 300.ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new message
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.edit_rounded,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

// ─── Conversation Tile ────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = conversation.isOnline;
    final hasUnread = conversation.unreadCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // ── Avatar ───────────────────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: ClipOval(
                      child: Image.network(
                        conversation.avatar,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Icon(
                            Icons.person,
                            size: 28,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Online Indicator
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Conversation Info ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        conversation.username,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (conversation.isVerified)
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.isTyping
                              ? 'typing...'
                              : conversation.lastMessage,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: hasUnread
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Unread Badge ─────────────────────────────────────────────────
            if (hasUnread)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  conversation.unreadCount > 99
                      ? '99+'
                      : conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day}/${time.month}';
  }
}
