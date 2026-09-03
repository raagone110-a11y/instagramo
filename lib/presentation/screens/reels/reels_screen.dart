import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─── Reel Data Model ──────────────────────────────────────────────────────────

class ReelModel {
  final String id;
  final String username;
  final String userAvatar;
  final String videoUrl;
  final String thumbnailUrl;
  final String caption;
  final String audioName;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final bool isFollowing;
  final bool isVerified;

  ReelModel({
    required this.id,
    required this.username,
    required this.userAvatar,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.audioName,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    this.isLiked = false,
    this.isFollowing = false,
    this.isVerified = false,
  });
}

// ─── Reels Providers ──────────────────────────────────────────────────────────

final reelsProvider = StateProvider<List<ReelModel>>((ref) => [
      ReelModel(
        id: '1',
        username: 'sarah_travels',
        userAvatar: 'https://i.pravatar.cc/100?img=1',
        videoUrl: 'https://example.com/reel1.mp4',
        thumbnailUrl: 'https://picsum.photos/seed/reel1/600/1200',
        caption: 'Hidden waterfall in Bali you NEED to visit 💦 #travel #bali',
        audioName: 'original audio - sarah_travels',
        likeCount: 12400,
        commentCount: 432,
        shareCount: 89,
        isLiked: false,
        isFollowing: true,
        isVerified: true,
      ),
      ReelModel(
        id: '2',
        username: 'alex_photo',
        userAvatar: 'https://i.pravatar.cc/100?img=2',
        videoUrl: 'https://example.com/reel2.mp4',
        thumbnailUrl: 'https://picsum.photos/seed/reel2/600/1200',
        caption: 'How to shoot cinematic videos on your phone 🎬',
        audioName: 'Cinematic Vibes - Alex Photo',
        likeCount: 8920,
        commentCount: 234,
        shareCount: 156,
        isLiked: true,
        isFollowing: false,
      ),
      ReelModel(
        id: '3',
        username: 'foodie_mike',
        userAvatar: 'https://i.pravatar.cc/100?img=3',
        videoUrl: 'https://example.com/reel3.mp4',
        thumbnailUrl: 'https://picsum.photos/seed/reel3/600/1200',
        caption: 'Making fresh pasta from scratch 🍝 Full recipe on my page!',
        audioName: 'Italian Kitchen Sounds',
        likeCount: 23500,
        commentCount: 789,
        shareCount: 445,
        isLiked: false,
        isFollowing: false,
        isVerified: true,
      ),
      ReelModel(
        id: '4',
        username: 'fit_emma',
        userAvatar: 'https://i.pravatar.cc/100?img=4',
        videoUrl: 'https://example.com/reel4.mp4',
        thumbnailUrl: 'https://picsum.photos/seed/reel4/600/1200',
        caption: '5-minute morning workout routine 💪 No equipment needed!',
        audioName: 'Workout Mix 2024 - FitBeats',
        likeCount: 15600,
        commentCount: 345,
        shareCount: 234,
        isLiked: false,
        isFollowing: true,
      ),
      ReelModel(
        id: '5',
        username: 'art_studio',
        userAvatar: 'https://i.pravatar.cc/100?img=5',
        videoUrl: 'https://example.com/reel5.mp4',
        thumbnailUrl: 'https://picsum.photos/seed/reel5/600/1200',
        caption: 'Digital art process: "Ethereal Dreams" 🎨',
        audioName: 'original audio - art_studio',
        likeCount: 31200,
        commentCount: 987,
        shareCount: 567,
        isLiked: true,
        isFollowing: true,
        isVerified: true,
      ),
    ]);

final likedReelsProvider = StateProvider<Map<String, bool>>((ref) => {});

// ─── Reels Screen ─────────────────────────────────────────────────────────────

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final reels = ref.watch(reelsProvider);
    final likedReels = ref.watch(likedReelsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Vertical PageView ──────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            itemBuilder: (context, index) {
              final reel = reels[index];
              final isLiked = likedReels[reel.id] ?? reel.isLiked;

              return GestureDetector(
                onDoubleTap: () {
                  ref.read(likedReelsProvider.notifier).state = {
                    ...ref.read(likedReelsProvider),
                    reel.id: !isLiked,
                  };
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Video / Thumbnail
                    Image.network(
                      reel.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.broken_image_rounded,
                          size: 64,
                          color: Colors.white38,
                        ),
                      ),
                    ),

                    // Gradient overlays
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.0, 0.25, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // ── Top Bar ──────────────────────────────────────────────
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Reels',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 500.ms),

                    // ── Right Side Actions ───────────────────────────────────
                    Positioned(
                      right: 12,
                      bottom: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Like Button
                          _ReelActionButton(
                            icon: isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            label: _formatCount(
                              isLiked ? reel.likeCount + 1 : reel.likeCount,
                            ),
                            color: isLiked
                                ? const Color(0xFFFF3B5C)
                                : Colors.white,
                            onTap: () {
                              ref.read(likedReelsProvider.notifier).state = {
                                ...ref.read(likedReelsProvider),
                                reel.id: !isLiked,
                              };
                            },
                          ),

                          const SizedBox(height: 16),

                          // Comment Button
                          _ReelActionButton(
                            icon: Icons.chat_bubble_rounded,
                            label: _formatCount(reel.commentCount),
                            color: Colors.white,
                            onTap: () {
                              // Open comments
                            },
                          ),

                          const SizedBox(height: 16),

                          // Share Button
                          _ReelActionButton(
                            icon: Icons.send_rounded,
                            label: _formatCount(reel.shareCount),
                            color: Colors.white,
                            onTap: () {
                              // Share reel
                            },
                          ),

                          const SizedBox(height: 24),

                          // Audio Disc (rotating)
                          _RotatingDisc(
                            imageUrl: reel.userAvatar,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fade(delay: 200.ms, duration: 500.ms)
                        .slideX(begin: 0.3, end: 0),

                    // ── Bottom User Info ─────────────────────────────────────
                    Positioned(
                      left: 16,
                      right: 80,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Username row
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: ClipOval(
                                  child: Image.network(
                                    reel.userAvatar,
                                    width: 34,
                                    height: 34,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[700],
                                      child: const Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        reel.username,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (reel.isVerified)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: Icon(
                                          Icons.verified_rounded,
                                          size: 15,
                                          color: Color(0xFF3897F0),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (!reel.isFollowing)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Follow',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Caption
                          Text(
                            reel.caption,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ).animate().fade(delay: 300.ms, duration: 500.ms),

                          const SizedBox(height: 8),

                          // Audio name
                          Row(
                            children: [
                              const Icon(
                                Icons.music_note_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  reel.audioName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ).animate().fade(delay: 400.ms, duration: 500.ms),
                        ],
                      ),
                    ),

                    // ── Double-tap Like Animation ────────────────────────────
                    if (isLiked)
                      const Positioned.fill(
                        child: Center(
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 100,
                            color: Color(0xFFFF3B5C),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // ── Back Button ────────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reel Action Button ───────────────────────────────────────────────────────

class _ReelActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ReelActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Rotating Disc Widget ─────────────────────────────────────────────────────

class _RotatingDisc extends StatefulWidget {
  final String imageUrl;

  const _RotatingDisc({required this.imageUrl});

  @override
  State<_RotatingDisc> createState() => _RotatingDiscState();
}

class _RotatingDiscState extends State<_RotatingDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white38, width: 1.5),
        ),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[800],
          child: ClipOval(
            child: Image.network(
              widget.imageUrl,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person,
                size: 14,
                color: Colors.white38,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
