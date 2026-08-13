import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─── Feed Data Models ─────────────────────────────────────────────────────────

class PostModel {
  final String id;
  final String username;
  final String userAvatar;
  final String mediaUrl;
  final String caption;
  final DateTime timestamp;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final bool isSaved;
  final bool isVerified;

  PostModel({
    required this.id,
    required this.username,
    required this.userAvatar,
    required this.mediaUrl,
    required this.caption,
    required this.timestamp,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    this.isLiked = false,
    this.isSaved = false,
    this.isVerified = false,
  });
}

class StoryModel {
  final String id;
  final String username;
  final String avatar;
  final bool isViewed;
  final bool isOwn;

  StoryModel({
    required this.id,
    required this.username,
    required this.avatar,
    this.isViewed = false,
    this.isOwn = false,
  });
}

// ─── Feed Provider ────────────────────────────────────────────────────────────

final storiesProvider = StateProvider<List<StoryModel>>((ref) => [
      StoryModel(
        id: '1',
        username: 'Your Story',
        avatar: 'https://i.pravatar.cc/100?img=1',
        isOwn: true,
      ),
      for (int i = 2; i <= 10; i++)
        StoryModel(
          id: i.toString(),
          username: 'user_$i',
          avatar: 'https://i.pravatar.cc/100?img=$i',
          isViewed: i > 5,
        ),
    ]);

final feedPostsProvider = StateProvider<List<PostModel>>((ref) => [
      PostModel(
        id: '1',
        username: 'sarah_travels',
        userAvatar: 'https://i.pravatar.cc/100?img=1',
        mediaUrl: 'https://picsum.photos/seed/ig1/800/800',
        caption: 'Exploring the hidden gems of Bali ✨ #travel #bali #paradise',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likeCount: 2341,
        commentCount: 156,
        shareCount: 89,
        isLiked: true,
        isSaved: false,
        isVerified: true,
      ),
      PostModel(
        id: '2',
        username: 'alex_photo',
        userAvatar: 'https://i.pravatar.cc/100?img=2',
        mediaUrl: 'https://picsum.photos/seed/ig2/800/1000',
        caption: 'Golden hour magic 🌅 Never gets old!',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likeCount: 892,
        commentCount: 67,
        shareCount: 34,
        isLiked: false,
        isSaved: true,
      ),
      PostModel(
        id: '3',
        username: 'foodie_mike',
        userAvatar: 'https://i.pravatar.cc/100?img=3',
        mediaUrl: 'https://picsum.photos/seed/ig3/800/800',
        caption: 'Homemade pasta from scratch 🍝 Recipe in bio!',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        likeCount: 4521,
        commentCount: 298,
        shareCount: 167,
        isLiked: true,
        isVerified: true,
      ),
      PostModel(
        id: '4',
        username: 'fit_emma',
        userAvatar: 'https://i.pravatar.cc/100?img=4',
        mediaUrl: 'https://picsum.photos/seed/ig4/800/1000',
        caption: 'Morning workout done! 💪 Consistency is key.',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        likeCount: 1567,
        commentCount: 89,
        shareCount: 45,
        isLiked: false,
      ),
      PostModel(
        id: '5',
        username: 'art_studio',
        userAvatar: 'https://i.pravatar.cc/100?img=5',
        mediaUrl: 'https://picsum.photos/seed/ig5/800/800',
        caption: 'New digital art piece - "Ethereal Dreams" 🎨',
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        likeCount: 3892,
        commentCount: 234,
        shareCount: 123,
        isLiked: true,
        isVerified: true,
      ),
    ]);

final isFeedLoadingProvider = StateProvider<bool>((ref) => false);
final isLikedProvider = StateProvider<Map<String, bool>>((ref) => {});
final isSavedProvider = StateProvider<Map<String, bool>>((ref) => {});

// ─── Feed Screen ──────────────────────────────────────────────────────────────

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(feedPostsProvider);
    final isLoading = ref.watch(isFeedLoadingProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(isFeedLoadingProvider.notifier).state = true;
        await Future.delayed(const Duration(seconds: 2));
        ref.read(isFeedLoadingProvider.notifier).state = false;
      },
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const _StoriesRow();
          }
          final post = posts[index - 1];
          return PostCard(post: post, index: index);
        },
      ),
    );
  }
}

// ─── Stories Row ──────────────────────────────────────────────────────────────

class _StoriesRow extends ConsumerWidget {
  const _StoriesRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(storiesProvider);

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final story = stories[index];
          return _StoryAvatar(story: story);
        },
      ),
    );
  }
}

// ─── Story Avatar ─────────────────────────────────────────────────────────────

class _StoryAvatar extends StatelessWidget {
  final StoryModel story;

  const _StoryAvatar({required this.story});

  @override
  Widget build(BuildContext context) {
    final isViewed = story.isViewed && !story.isOwn;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isViewed
          ? [
              Theme.of(context).colorScheme.outline.withOpacity(0.3),
              Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ]
          : [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              const Color(0xFFFF6B35),
            ],
    );

    return GestureDetector(
      onTap: () => context.push('/story/${story.id}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(38),
            ),
            child: Container(
              width: 68,
              height: 68,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(36),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: Image.network(
                  story.avatar,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child: Icon(
                      Icons.person,
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
          const SizedBox(height: 6),
          SizedBox(
            width: 68,
            child: Text(
              story.username,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Post Card ────────────────────────────────────────────────────────────────

class PostCard extends ConsumerWidget {
  final PostModel post;
  final int index;

  const PostCard({required this.post, required this.index, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customLikes = ref.watch(isLikedProvider);
    final customSaves = ref.watch(isSavedProvider);
    final isLiked = customLikes[post.id] ?? post.isLiked;
    final isSaved = customSaves[post.id] ?? post.isSaved;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.05),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Post Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // User Avatar
                GestureDetector(
                  onTap: () => context.push('/profile/${post.username}'),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          Theme.of(context).colorScheme.surface,
                      child: ClipOval(
                        child: Image.network(
                          post.userAvatar,
                          width: 34,
                          height: 34,
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
                ),
                const SizedBox(width: 10),
                // Username & Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.username,
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                          if (post.isVerified)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        _formatTimestamp(post.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                      ),
                    ],
                  ),
                ),
                // More Options
                IconButton(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    // Show bottom sheet with options
                  },
                ),
              ],
            ),
          ),

          // ── Post Media ─────────────────────────────────────────────────────
          GestureDetector(
            onDoubleTap: () {
              ref.read(isLikedProvider.notifier).state = {
                ...ref.read(isLikedProvider),
                post.id: !isLiked,
              };
            },
            child: Image.network(
              post.mediaUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 400,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.3),
                ),
              ),
            ),
          ),

          // ── Post Actions ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Like Button
                _AnimatedIconButton(
                  icon: isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isLiked
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurface,
                  onTap: () {
                    ref.read(isLikedProvider.notifier).state = {
                      ...ref.read(isLikedProvider),
                      post.id: !isLiked,
                    };
                  },
                ),

                // Comment Button
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 26,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    // Open comments
                  },
                ),

                // Share Button
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    // Share post
                  },
                ),

                const Spacer(),

                // Save Button
                _AnimatedIconButton(
                  icon: isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  onTap: () {
                    ref.read(isSavedProvider.notifier).state = {
                      ...ref.read(isSavedProvider),
                      post.id: !isSaved,
                    };
                  },
                ),
              ],
            ),
          ),

          // ── Likes Count ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${isLiked ? post.likeCount + 1 : post.likeCount} likes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Caption ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${post.username}  ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: post.caption,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── View Comments ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'View all ${post.commentCount} comments',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

// ─── Animated Icon Button ─────────────────────────────────────────────────────

class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedBuilder(
        animation: _controller,
        child: Icon(
          widget.icon,
          size: 28,
          color: widget.color,
        ),
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + 0.25 * _controller.value,
            child: child,
          );
        },
      ),
      onPressed: _handleTap,
    );
  }
}
