import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─── Search Data Models ───────────────────────────────────────────────────────

class SuggestedUser {
  final String username;
  final String displayName;
  final String avatar;
  final bool isVerified;
  final bool isFollowing;

  SuggestedUser({
    required this.username,
    required this.displayName,
    required this.avatar,
    this.isVerified = false,
    this.isFollowing = false,
  });
}

class HashtagModel {
  final String tag;
  final int postCount;

  HashtagModel({required this.tag, required this.postCount});
}

class TrendingTopic {
  final String title;
  final String category;
  final int postCount;

  TrendingTopic({
    required this.title,
    required this.category,
    required this.postCount,
  });
}

// ─── Search Providers ─────────────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedSearchTabProvider = StateProvider<int>((ref) => 0);

final suggestedUsersProvider = StateProvider<List<SuggestedUser>>((ref) => [
      SuggestedUser(
        username: 'sarah_travels',
        displayName: 'Sarah Wilson',
        avatar: 'https://i.pravatar.cc/100?img=1',
        isVerified: true,
      ),
      SuggestedUser(
        username: 'alex_photo',
        displayName: 'Alex Martinez',
        avatar: 'https://i.pravatar.cc/100?img=2',
        isFollowing: true,
      ),
      SuggestedUser(
        username: 'foodie_mike',
        displayName: 'Mike Chen',
        avatar: 'https://i.pravatar.cc/100?img=3',
        isVerified: true,
      ),
      SuggestedUser(
        username: 'fit_emma',
        displayName: 'Emma Johnson',
        avatar: 'https://i.pravatar.cc/100?img=4',
      ),
      SuggestedUser(
        username: 'art_studio',
        displayName: 'Digital Art Studio',
        avatar: 'https://i.pravatar.cc/100?img=5',
        isVerified: true,
      ),
      SuggestedUser(
        username: 'music_lover',
        displayName: 'Music Vibes',
        avatar: 'https://i.pravatar.cc/100?img=6',
      ),
    ]);

final hashtagsProvider = StateProvider<List<HashtagModel>>((ref) => [
      HashtagModel(tag: 'photography', postCount: 1200000),
      HashtagModel(tag: 'travel', postCount: 890000),
      HashtagModel(tag: 'food', postCount: 650000),
      HashtagModel(tag: 'fitness', postCount: 540000),
      HashtagModel(tag: 'art', postCount: 430000),
      HashtagModel(tag: 'music', postCount: 380000),
      HashtagModel(tag: 'nature', postCount: 320000),
      HashtagModel(tag: 'fashion', postCount: 290000),
    ]);

final trendingTopicsProvider = StateProvider<List<TrendingTopic>>((ref) => [
      TrendingTopic(
        title: 'Summer Vibes 2024',
        category: 'Lifestyle',
        postCount: 45000,
      ),
      TrendingTopic(
        title: 'Bali Travel Guide',
        category: 'Travel',
        postCount: 32000,
      ),
      TrendingTopic(
        title: 'Healthy Recipes',
        category: 'Food',
        postCount: 28000,
      ),
      TrendingTopic(
        title: 'Digital Art Trends',
        category: 'Art',
        postCount: 21000,
      ),
      TrendingTopic(
        title: 'Morning Routines',
        category: 'Lifestyle',
        postCount: 18000,
      ),
      TrendingTopic(
        title: 'Home Workouts',
        category: 'Fitness',
        postCount: 15000,
      ),
    ]);

final explorePostsProvider = StateProvider<List<String>>((ref) => [
      for (int i = 1; i <= 30; i++)
        'https://picsum.photos/seed/explore$i/400/${(i % 3 == 0) ? 600 : 400}',
    ]);

// ─── Search Screen ────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  static const List<String> _tabLabels = ['Users', 'Hashtags', 'Trending'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedTab = ref.watch(selectedSearchTabProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header & Search Bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 22,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          'Search',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) =>
                        ref.read(searchQueryProvider.notifier).state = value,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search users, hashtags, topics...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
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
                              onPressed: () => ref
                                  .read(searchQueryProvider.notifier)
                                  .state = '',
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
                  )
                      .animate()
                      .fade(duration: 400.ms)
                      .slideY(begin: -0.1, end: 0),
                ],
              ),
            ),

            // ── Tabs ─────────────────────────────────────────────────────────
            if (searchQuery.isEmpty) ...[
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: List.generate(_tabLabels.length, (index) {
                    final isSelected = selectedTab == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => ref
                            .read(selectedSearchTabProvider.notifier)
                            .state = index,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Text(
                            _tabLabels[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],

            // ── Content ──────────────────────────────────────────────────────
            Expanded(
              child: IndexedStack(
                index: selectedTab,
                children: [
                  _UsersContent(),
                  _HashtagsContent(),
                  _TrendingContent(),
                ],
              ),
            ),

            // ── Explore Grid (shown when no search query) ────────────────────
            if (searchQuery.isEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Explore',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _ExploreGrid(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Users Content ────────────────────────────────────────────────────────────

class _UsersContent extends ConsumerWidget {
  const _UsersContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(suggestedUsersProvider);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: users.length,
      separatorBuilder: (_, __) => Divider(
        height: 0,
        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
      ),
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserTile(
          user: user,
          onTap: () => context.push('/profile/${user.username}'),
        )
            .animate(delay: Duration(milliseconds: 60 * index))
            .fade(duration: 300.ms)
            .slideX(begin: 0.1, end: 0);
      },
    );
  }
}

// ─── User Tile ────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  final SuggestedUser user;
  final VoidCallback onTap;

  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 28,
        child: ClipOval(
          child: Image.network(
            user.avatar,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.person,
                size: 28,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
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
      subtitle: Text(
        user.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: user.isFollowing
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          user.isFollowing ? 'Following' : 'Follow',
          style: TextStyle(
            color: user.isFollowing
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─── Hashtags Content ─────────────────────────────────────────────────────────

class _HashtagsContent extends ConsumerWidget {
  const _HashtagsContent();

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(0)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hashtags = ref.watch(hashtagsProvider);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: hashtags.length,
      itemBuilder: (context, index) {
        final hashtag = hashtags[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#${hashtag.tag}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatCount(hashtag.postCount)} posts',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: 60 * index))
            .fade(duration: 300.ms)
            .scale(duration: 300.ms);
      },
    );
  }
}

// ─── Trending Content ─────────────────────────────────────────────────────────

class _TrendingContent extends ConsumerWidget {
  const _TrendingContent();

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(0)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(trendingTopicsProvider);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: topics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final topic = topics[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      topic.category,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${_formatCount(topic.postCount)} posts',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                topic.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: 60 * index))
            .fade(duration: 300.ms)
            .slideX(begin: 0.1, end: 0);
      },
    );
  }
}

// ─── Explore Grid ─────────────────────────────────────────────────────────────

class _ExploreGrid extends ConsumerWidget {
  const _ExploreGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(explorePostsProvider);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Image.network(
            posts[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.image_not_supported_outlined,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
        )
            .animate(delay: Duration(milliseconds: 40 * (index % 12)))
            .fade(duration: 300.ms)
            .scale(duration: 300.ms);
      },
    );
  }
}
