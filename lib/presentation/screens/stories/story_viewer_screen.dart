import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─── Story Data Model ─────────────────────────────────────────────────────────

class StoryItem {
  final String id;
  final String mediaUrl;
  final String? caption;
  final DateTime timestamp;
  final Duration duration;

  StoryItem({
    required this.id,
    required this.mediaUrl,
    this.caption,
    required this.timestamp,
    this.duration = const Duration(seconds: 5),
  });
}

class StoryUser {
  final String username;
  final String avatar;
  final List<StoryItem> stories;

  StoryUser({
    required this.username,
    required this.avatar,
    required this.stories,
  });
}

// ─── Story Providers ──────────────────────────────────────────────────────────

final storyUsersProvider = StateProvider<List<StoryUser>>((ref) => [
      StoryUser(
        username: 'sarah_travels',
        avatar: 'https://i.pravatar.cc/100?img=1',
        stories: [
          StoryItem(
            id: '1',
            mediaUrl: 'https://picsum.photos/seed/story1/800/1400',
            caption: 'Morning vibes in Bali 🌴',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          StoryItem(
            id: '2',
            mediaUrl: 'https://picsum.photos/seed/story2/800/1400',
            caption: 'Hidden waterfall found! 💦',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          StoryItem(
            id: '3',
            mediaUrl: 'https://picsum.photos/seed/story3/800/1400',
            caption: 'Sunset at Uluwatu 🌅',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      StoryUser(
        username: 'alex_photo',
        avatar: 'https://i.pravatar.cc/100?img=2',
        stories: [
          StoryItem(
            id: '4',
            mediaUrl: 'https://picsum.photos/seed/story4/800/1400',
            caption: 'New camera setup 📷',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          StoryItem(
            id: '5',
            mediaUrl: 'https://picsum.photos/seed/story5/800/1400',
            caption: 'Golden hour magic ✨',
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          ),
        ],
      ),
      StoryUser(
        username: 'foodie_mike',
        avatar: 'https://i.pravatar.cc/100?img=3',
        stories: [
          StoryItem(
            id: '6',
            mediaUrl: 'https://picsum.photos/seed/story6/800/1400',
            caption: 'Fresh pasta from scratch 🍝',
            timestamp: DateTime.now().subtract(const Duration(hours: 7)),
          ),
        ],
      ),
    ]);

final storyUserIndexProvider = StateProvider<int>((ref) => 0);
final storyItemIndexProvider = StateProvider<int>((ref) => 0);
final progressProvider = StateProvider<double>((ref) => 0.0);
final replyInputProvider = StateProvider<String>((ref) => '');
final isReplyFocusedProvider = StateProvider<bool>((ref) => false);

// ─── Story Viewer Screen ──────────────────────────────────────────────────────

class StoryViewerScreen extends ConsumerStatefulWidget {
  final String? storyId;

  const StoryViewerScreen({this.storyId, super.key});

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _dismissController;
  double _dragOffset = 0.0;
  final double _closeThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _startStoryTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dismissController.dispose();
    super.dispose();
  }

  void _startStoryTimer() {
    _timer?.cancel();
    ref.read(progressProvider.notifier).state = 0.0;
    final users = ref.read(storyUsersProvider);
    final userIndex = ref.read(storyUserIndexProvider);
    if (userIndex >= users.length) return;

    final user = users[userIndex];
    final itemIndex = ref.read(storyItemIndexProvider);
    final story = user.stories[itemIndex];
    const tick = Duration(milliseconds: 50);
    final increment = tick.inMilliseconds / story.duration.inMilliseconds;

    _timer = Timer.periodic(tick, (_) {
      final progress = ref.read(progressProvider) + increment;
      if (progress >= 1.0) {
        _timer?.cancel();
        _goToNext();
      } else {
        ref.read(progressProvider.notifier).state = progress;
      }
    });
  }

  void _goToNext() {
    final users = ref.read(storyUsersProvider);
    final userIndex = ref.read(storyUserIndexProvider);
    final user = users[userIndex];
    final itemIndex = ref.read(storyItemIndexProvider);

    if (itemIndex < user.stories.length - 1) {
      ref.read(storyItemIndexProvider.notifier).state = itemIndex + 1;
      _startStoryTimer();
    } else if (userIndex < users.length - 1) {
      ref.read(storyUserIndexProvider.notifier).state = userIndex + 1;
      ref.read(storyItemIndexProvider.notifier).state = 0;
      _startStoryTimer();
    } else {
      // No more stories - close viewer
      context.pop();
    }
  }

  void _goToPrevious() {
    final itemIndex = ref.read(storyItemIndexProvider);
    if (itemIndex > 0) {
      ref.read(storyItemIndexProvider.notifier).state = itemIndex - 1;
      _startStoryTimer();
    } else if (ref.read(storyUserIndexProvider) > 0) {
      final userIndex = ref.read(storyUserIndexProvider);
      ref.read(storyUserIndexProvider.notifier).state = userIndex - 1;
      ref.read(storyItemIndexProvider.notifier).state = 0;
      _startStoryTimer();
    }
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      if (_dragOffset.abs() > _closeThreshold) {
        _dismissController.forward();
      }
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > _closeThreshold) {
      context.pop();
    } else {
      setState(() => _dragOffset = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(storyUsersProvider);
    final userIndex = ref.watch(storyUserIndexProvider);
    final itemIndex = ref.watch(storyItemIndexProvider);
    final progress = ref.watch(progressProvider);

    if (userIndex >= users.length) {
      return const Scaffold(
        backgroundColor: Colors.black,
      );
    }

    final user = users[userIndex];
    final story = user.stories[itemIndex];
    final isReplyFocused = ref.watch(isReplyFocusedProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onVerticalDragUpdate: _handleVerticalDragUpdate,
        onVerticalDragEnd: _handleVerticalDragEnd,
        child: AnimatedBuilder(
          animation: _dismissController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _dragOffset),
              child: Transform.rotate(
                angle: _dragOffset / 1000,
                child: child,
              ),
            );
          },
          child: Stack(
            children: [
              // ── Story Media ────────────────────────────────────────────────
              Positioned.fill(
                child: Image.network(
                  story.mediaUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0.0, 0.2, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Progress Bars ──────────────────────────────────────────────
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                right: 12,
                child: Row(
                  children: List.generate(user.stories.length, (index) {
                    final storyProgress = index == itemIndex
                        ? progress
                        : index < itemIndex
                            ? 1.0
                            : 0.0;
                    return Expanded(
                      child: Container(
                        height: 2.5,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: storyProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ).animate().fade(duration: 400.ms),

              // ── Top Bar: User Info ─────────────────────────────────────────
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE1306C), Color(0xFF833AB4)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.network(
                            user.avatar,
                            width: 34,
                            height: 34,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[700],
                              child: const Icon(Icons.person,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            _timeAgo(story.timestamp),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 24),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ).animate().fade(duration: 500.ms).slideY(begin: -0.2, end: 0),

              // ── Tap Zones: Previous / Next ─────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                width: MediaQuery.of(context).size.width * 0.35,
                bottom: isReplyFocused ? 60 : 0,
                child: GestureDetector(
                  onTap: _goToPrevious,
                  behavior: HitTestBehavior.translucent,
                  child: Container(),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                width: MediaQuery.of(context).size.width * 0.35,
                bottom: isReplyFocused ? 60 : 0,
                child: GestureDetector(
                  onTap: _goToNext,
                  behavior: HitTestBehavior.translucent,
                  child: Container(),
                ),
              ),

              // ── Story Caption ──────────────────────────────────────────────
              if (story.caption != null)
                Positioned(
                  bottom: 90,
                  left: 20,
                  right: 20,
                  child: Text(
                    story.caption!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fade(delay: 300.ms, duration: 500.ms),

              // ── Bottom Bar: Reply Input ────────────────────────────────────
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          onChanged: (value) => ref
                              .read(replyInputProvider.notifier)
                              .state = value,
                          decoration: InputDecoration(
                            hintText: 'Send message...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            ref.read(replyInputProvider.notifier).state = '';
                            ref.read(isReplyFocusedProvider.notifier).state =
                                false;
                            // Send reply logic
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 600.ms).slideY(begin: 0.2, end: 0),

              // ── Right Side Actions ─────────────────────────────────────────
              Positioned(
                right: 12,
                top: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  children: [
                    _StoryActionButton(
                      icon: Icons.reply_rounded,
                      onTap: () {
                        ref.read(isReplyFocusedProvider.notifier).state = true;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

// ─── Story Action Button ──────────────────────────────────────────────────────

class _StoryActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StoryActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
