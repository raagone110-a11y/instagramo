import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_provider.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/otp_verification_screen.dart';

import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/chat/chat_list_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/stories/story_viewer_screen.dart';
import '../../presentation/screens/reels/reels_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/nearby/nearby_friends_screen.dart';
import '../../presentation/screens/creator/creator_dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth/login',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.watch(authStateProvider);
      final location = state.matchedLocation;

      final isAuthRoute = location == '/auth/login' ||
          location == '/auth/register' ||
          location == '/auth/otp';

      if (!authState.isAuthenticated && !isAuthRoute) {
        return '/auth/login';
      }

      if (authState.isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // AUTH
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/auth/otp',
        name: 'otp',
        builder: (context, state) => const OtpVerificationScreen(),
      ),

      // MAIN APP
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/reels',
            name: 'reels',
            builder: (context, state) => const ReelsScreen(),
          ),
          GoRoute(
            path: '/chat',
            name: 'chatList',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // PROFILE
      GoRoute(
        path: '/profile/:username',
        name: 'userProfile',
        builder: (context, state) {
          final username = state.pathParameters['username']!;

          return ProfileScreen(
            username: username,
          );
        },
      ),

      // CHAT
      GoRoute(
        path: '/chat/:chatId',
        name: 'chat',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;

          return ChatScreen(
            chatId: chatId,
          );
        },
      ),

      // STORIES
      GoRoute(
        path: '/stories/view',
        name: 'storyViewer',
        builder: (context, state) {
          final storyId = state.uri.queryParameters['storyId'] ?? '';

          return StoryViewerScreen(
            storyId: storyId,
          );
        },
      ),

      // SETTINGS
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // NEARBY
      GoRoute(
        path: '/nearby-friends',
        name: 'nearbyFriends',
        builder: (context, state) => const NearbyFriendsScreen(),
      ),

      // CREATOR
      GoRoute(
        path: '/creator/dashboard',
        name: 'creatorDashboard',
        builder: (context, state) => const CreatorDashboardScreen(),
      ),
    ],
  );
});

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  static const List<
      ({
        String path,
        IconData icon,
        String label,
      })> _tabs = [
    (
      path: '/',
      icon: Icons.home_outlined,
      label: 'Home',
    ),
    (
      path: '/search',
      icon: Icons.search,
      label: 'Search',
    ),
    (
      path: '/reels',
      icon: Icons.movie_outlined,
      label: 'Reels',
    ),
    (
      path: '/chat',
      icon: Icons.chat_bubble_outlined,
      label: 'Chat',
    ),
    (
      path: '/profile',
      icon: Icons.person_outline,
      label: 'Profile',
    ),
  ];

  int _currentIndex(
    String location,
  ) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path) {
        return i;
      }
    }

    return 0;
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final location = GoRouterState.of(context).matchedLocation;

    final currentIndex = _currentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          context.go(_tabs[index].path);
        },
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
