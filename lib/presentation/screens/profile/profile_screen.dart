import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─── Profile Data Model ───────────────────────────────────────────────────────

class ProfileModel {
  final String username;
  final String displayName;
  final String bio;
  final String avatar;
  final String coverPhoto;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final bool isVerified;
  final bool isOwnProfile;

  ProfileModel({
    required this.username,
    required this.displayName,
    required this.bio,
    required this.avatar,
    required this.coverPhoto,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    this.isVerified = false,
    this.isOwnProfile = false,
  });
}

// ─── Profile Provider ─────────────────────────────────────────────────────────

final profileProvider = StateProvider<ProfileModel>((ref) => ProfileModel(
      username: 'johndoe_official',
      displayName: 'John Doe',
      bio: '📸 Photographer | 🌍 Traveler\n✨ Creating moments that matter\n🔗 Link below',
      avatar: 'https://i.pravatar.cc/200?img=12',
      coverPhoto: 'https://picsum.photos/seed/cover/800/400',
      postCount: 247,
      followerCount: 12400,
      followingCount: 892,
      isVerified: true,
      isOwnProfile: true,
    ));

final selectedTabProvider = StateProvider<int>((ref) => 0);
final gridPostsProvider = StateProvider<List<String>>((ref) => [
      for (int i = 1; i <= 18; i++) 'https://picsum.photos/seed/post$i/400/400',
    ]);

// ─── Profile Screen ───────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerWidget {
  final String? username;

  const ProfileScreen({this.username, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            floating: true,
            pinned: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 22,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              profile.username,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            actions: [
              if (profile.isOwnProfile)
                IconButton(
                  icon: Icon(
                    Icons.settings_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => context.push('/settings'),
                ),
              IconButton(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {
                  // More options
                },
              ),
            ],
          ),

          // ── Cover Photo ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(profile.coverPhoto),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(context).colorScheme.surface.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Avatar ───────────────────────────────────────────────────
                const SizedBox(height: 8),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor:
                            Theme.of(context).colorScheme.surface,
                        child: ClipOval(
                          child: Image.network(
                            profile.avatar,
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fade(duration: 500.ms)
                        .scale(duration: 500.ms, curve: Curves.easeOutBack),
                    if (profile.isVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Display Name & Username ──────────────────────────────────
                Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${profile.username}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                ),
                const SizedBox(height: 12),

                // ── Bio ──────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    profile.bio,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Stats ────────────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        count: profile.postCount,
                        label: 'Posts',
                      ),
                      Container(
                        width: 0.5,
                        height: 40,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                      ),
                      _StatItem(
                        count: profile.followerCount,
                        label: 'Followers',
                      ),
                      Container(
                        width: 0.5,
                        height: 40,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                      ),
                      _StatItem(
                        count: profile.followingCount,
                        label: 'Following',
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fade(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                // ── Action Buttons ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      if (profile.isOwnProfile)
                        Expanded(
                          child: _ProfileButton(
                            label: 'Edit Profile',
                            icon: Icons.edit_rounded,
                            onPressed: () {},
                            isPrimary: true,
                          ),
                        )
                      else ...[
                        Expanded(
                          child: _ProfileButton(
                            label: 'Follow',
                            icon: Icons.person_add_rounded,
                            onPressed: () {},
                            isPrimary: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ProfileButton(
                            label: 'Message',
                            icon: Icons.message_rounded,
                            onPressed: () => context.push('/chat'),
                            isPrimary: false,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Tab Bar ──────────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      _TabButton(
                        icon: Icons.grid_view_rounded,
                        isSelected: selectedTab == 0,
                        onTap: () => ref.read(selectedTabProvider.notifier).state = 0,
                      ),
                      _TabButton(
                        icon: Icons.movie_rounded,
                        isSelected: selectedTab == 1,
                        onTap: () => ref.read(selectedTabProvider.notifier).state = 1,
                      ),
                      _TabButton(
                        icon: Icons.tag_rounded,
                        isSelected: selectedTab == 2,
                        onTap: () => ref.read(selectedTabProvider.notifier).state = 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Content Grid ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final posts = ref.read(gridPostsProvider);
                  return _GridItem(imageUrl: posts[index]);
                },
                childCount: gridPostsProvider(ref).length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ─── Stat Item Widget ─────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final int count;
  final String label;

  const _StatItem({required this.count, required this.label});

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _formatCount(count),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}

// ─── Profile Button Widget ────────────────────────────────────────────────────

class _ProfileButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ProfileButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: isPrimary
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

// ─── Tab Button Widget ────────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            size: 24,
          ),
        ),
      ),
    );
  }
}

// ─── Grid Item Widget ─────────────────────────────────────────────────────────

class _GridItem extends StatelessWidget {
  final String imageUrl;

  const _GridItem({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
        ),
      ),
    );
  }
}
