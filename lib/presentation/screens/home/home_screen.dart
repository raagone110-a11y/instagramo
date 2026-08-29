import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'feed_screen.dart';

// ─── Navigation Provider ──────────────────────────────────────────────────────

final selectedIndexProvider = StateProvider<int>((ref) => 0);

// ─── Home Screen ──────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<String> _navLabels = [
    'Home',
    'Search',
    'Create',
    'Reels',
    'Profile',
  ];

  static const List<IconData> _navIcons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.add_box_rounded,
    Icons.movie_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          FeedScreen(),
          _SearchPlaceholder(),
          _CreatePlaceholder(),
          _ReelsPlaceholder(),
          _ProfilePlaceholder(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, ref, selectedIndex),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 20,
              color: Colors.white,
            ),
          )
              .animate()
              .fade(duration: 500.ms)
              .scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(width: 10),
          Text(
            'Instagramo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          )
              .animate()
              .fade(delay: 100.ms, duration: 500.ms)
              .slideX(begin: -0.2, end: 0),
        ],
      ),
      actions: [
        // Notifications
        _AppBarIconButton(
          icon: Icons.notifications_none_rounded,
          badgeCount: 5,
          onTap: () {
            // Navigate to notifications
          },
        ),
        const SizedBox(width: 4),
        // Messages
        _AppBarIconButton(
          icon: Icons.messenger_outline_rounded,
          badgeCount: 3,
          onTap: () => context.push('/chat'),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  // ── Bottom Navigation Bar ───────────────────────────────────────────────────

  Widget _buildBottomNav(
      BuildContext context, WidgetRef ref, int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: NavigationBar(
        height: 64,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
        backgroundColor: Colors.transparent,
        indicatorColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: List.generate(_navLabels.length, (index) {
          final isSelected = selectedIndex == index;
          return NavigationDestination(
            icon: _buildNavIcon(index, isSelected, context),
            selectedIcon: _buildNavIcon(index, true, context),
            label: _navLabels[index],
          );
        }),
      ),
    );
  }

  Widget _buildNavIcon(int index, bool isSelected, BuildContext context) {
    if (index == 2) {
      // Create button - special styling
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 22,
          color: Colors.white,
        ),
      );
    }

    return Icon(
      _navIcons[index],
      size: 26,
      color: isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
    );
  }
}

// ── App Bar Icon Button ──────────────────────────────────────────────────────

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;

  const _AppBarIconButton({
    required this.icon,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Placeholder Screens ──────────────────────────────────────────────────────

class _SearchPlaceholder extends ConsumerWidget {
  const _SearchPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Search Screen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }
}

class _CreatePlaceholder extends ConsumerWidget {
  const _CreatePlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Create Post',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }
}

class _ReelsPlaceholder extends ConsumerWidget {
  const _ReelsPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Reels Screen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePlaceholder extends ConsumerWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Profile Screen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }
}
