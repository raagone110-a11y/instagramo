import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─── Nearby Friends Data Models ───────────────────────────────────────────────

enum DistanceRange { km1, km5, km10 }

class NearbyUser {
  final String id;
  final String username;
  final String displayName;
  final String avatar;
  final double distanceKm;
  final bool isOnline;
  final bool isVerified;
  final bool isFollowing;
  final List<String> mutualFriends;

  NearbyUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatar,
    required this.distanceKm,
    this.isOnline = false,
    this.isVerified = false,
    this.isFollowing = false,
    this.mutualFriends = const [],
  });
}

// ─── Nearby Friends Providers ─────────────────────────────────────────────────

final distanceRangeProvider =
    StateProvider<DistanceRange>((ref) => DistanceRange.km5);
final privacyEnabledProvider = StateProvider<bool>((ref) => true);
final isLocationLoadingProvider = StateProvider<bool>((ref) => false);

final allNearbyUsersProvider = StateProvider<List<NearbyUser>>((ref) => [
      NearbyUser(
        id: '1',
        username: 'sarah_travels',
        displayName: 'Sarah Wilson',
        avatar: 'https://i.pravatar.cc/100?img=1',
        distanceKm: 0.4,
        isOnline: true,
        isVerified: true,
        mutualFriends: ['alex_photo', 'foodie_mike'],
      ),
      NearbyUser(
        id: '2',
        username: 'alex_photo',
        displayName: 'Alex Martinez',
        avatar: 'https://i.pravatar.cc/100?img=2',
        distanceKm: 0.8,
        isOnline: true,
        mutualFriends: ['sarah_travels'],
      ),
      NearbyUser(
        id: '3',
        username: 'foodie_mike',
        displayName: 'Mike Chen',
        avatar: 'https://i.pravatar.cc/100?img=3',
        distanceKm: 1.2,
        isOnline: false,
        isVerified: true,
        isFollowing: true,
        mutualFriends: ['sarah_travels', 'alex_photo', 'fit_emma'],
      ),
      NearbyUser(
        id: '4',
        username: 'fit_emma',
        displayName: 'Emma Johnson',
        avatar: 'https://i.pravatar.cc/100?img=4',
        distanceKm: 2.3,
        isOnline: true,
        mutualFriends: ['foodie_mike'],
      ),
      NearbyUser(
        id: '5',
        username: 'art_studio',
        displayName: 'Digital Art Studio',
        avatar: 'https://i.pravatar.cc/100?img=5',
        distanceKm: 3.5,
        isOnline: false,
        isVerified: true,
        mutualFriends: [],
      ),
      NearbyUser(
        id: '6',
        username: 'music_lover',
        displayName: 'Music Vibes',
        avatar: 'https://i.pravatar.cc/100?img=6',
        distanceKm: 4.1,
        isOnline: true,
        mutualFriends: ['alex_photo'],
      ),
      NearbyUser(
        id: '7',
        username: 'dev_tom',
        displayName: 'Tom Anderson',
        avatar: 'https://i.pravatar.cc/100?img=7',
        distanceKm: 6.2,
        isOnline: false,
        mutualFriends: ['fit_emma', 'music_lover'],
      ),
      NearbyUser(
        id: '8',
        username: 'yoga_lisa',
        displayName: 'Lisa Park',
        avatar: 'https://i.pravatar.cc/100?img=8',
        distanceKm: 7.8,
        isOnline: false,
        isVerified: true,
        mutualFriends: ['fit_emma'],
      ),
      NearbyUser(
        id: '9',
        username: 'chef_marco',
        displayName: 'Marco Rossi',
        avatar: 'https://i.pravatar.cc/100?img=9',
        distanceKm: 8.5,
        isOnline: true,
        mutualFriends: ['foodie_mike', 'sarah_travels'],
      ),
      NearbyUser(
        id: '10',
        username: 'nature_kate',
        displayName: 'Kate Brown',
        avatar: 'https://i.pravatar.cc/100?img=10',
        distanceKm: 9.3,
        isOnline: false,
        mutualFriends: [],
      ),
    ]);

// ─── Nearby Friends Screen ────────────────────────────────────────────────────

class NearbyFriendsScreen extends ConsumerWidget {
  const NearbyFriendsScreen({super.key});

  static const Map<DistanceRange, String> _distanceLabels = {
    DistanceRange.km1: '1 km',
    DistanceRange.km5: '5 km',
    DistanceRange.km10: '10 km',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDistance = ref.watch(distanceRangeProvider);
    final privacyEnabled = ref.watch(privacyEnabledProvider);
    final isLoading = ref.watch(isLocationLoadingProvider);
    final users = ref.watch(allNearbyUsersProvider);
    final maxDistance = selectedDistance == DistanceRange.km1
        ? 1.0
        : selectedDistance == DistanceRange.km5
            ? 5.0
            : 10.0;

    final filteredUsers = users
        .where((u) => u.distanceKm <= maxDistance)
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

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
          'Nearby Friends',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        actions: [
          // Privacy Toggle
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: privacyEnabled
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  privacyEnabled
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: 16,
                  color: privacyEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  privacyEnabled ? 'Visible' : 'Hidden',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: privacyEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Distance Selector ──────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: DistanceRange.values.map((range) {
                final isSelected = selectedDistance == range;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(distanceRangeProvider.notifier).state = range,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _distanceLabels[range]!,
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0),

          // ── Results Count ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredUsers.length} people nearby',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
                Text(
                  'Updated just now',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
                      ),
                ),
              ],
            ),
          ),

          // ── Users List ─────────────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Finding people nearby...',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ],
                    ),
                  )
                : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_rounded,
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No one nearby right now',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredUsers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return _NearbyUserCard(
                            user: user,
                            onTapProfile: () =>
                                context.push('/profile/${user.username}'),
                            onTapMessage: () => context.push('/chat'),
                          )
                              .animate(
                                  delay: Duration(milliseconds: 70 * index))
                              .fade(duration: 400.ms)
                              .slideY(begin: 0.15, end: 0);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Nearby User Card ─────────────────────────────────────────────────────────

class _NearbyUserCard extends ConsumerWidget {
  final NearbyUser user;
  final VoidCallback onTapProfile;
  final VoidCallback onTapMessage;

  const _NearbyUserCard({
    required this.user,
    required this.onTapProfile,
    required this.onTapMessage,
  });

  String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar with online indicator
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 28,
                child: ClipOval(
                  child: Image.network(
                    user.avatar,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.5),
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
              if (user.isOnline)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: GestureDetector(
              onTap: onTapProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.username,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                          overflow: TextOverflow.ellipsis,
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
                  const SizedBox(height: 2),
                  Text(
                    user.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.near_me_rounded,
                        size: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Approx. ${_formatDistance(user.distanceKm)} away',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                      ),
                      if (user.mutualFriends.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            '${user.mutualFriends.length} mutual',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Action Buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!user.isFollowing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Follow',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Following',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.message_rounded,
                      size: 13,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Message',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
