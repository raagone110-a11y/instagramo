import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_provider.dart';

// --- Auth Screens ---
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';

// --- Home Screens ---
import '../../presentation/screens/home/home_screen.dart';

// --- Profile Screens ---
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/followers_screen.dart';
import '../../presentation/screens/profile/following_screen.dart';

// --- Chat Screens ---
import '../../presentation/screens/chat/chat_list_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';

// --- Stories Screens ---
import '../../presentation/screens/stories/story_viewer_screen.dart';
import '../../presentation/screens/stories/create_story_screen.dart';

// --- Reels Screens ---
import '../../presentation/screens/reels/reels_screen.dart';

// --- Search Screens ---
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/search/search_results_screen.dart';

// --- Settings Screens ---
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings/privacy_settings_screen.dart';
import '../../presentation/screens/settings/notification_settings_screen.dart';
import '../../presentation/screens/settings/account_settings_screen.dart';
import '../../presentation/screens/settings/about_screen.dart';

// --- Nearby Friends ---
import '../../presentation/screens/nearby_friends/nearby_friends_screen.dart';

// --- Creator Dashboard ---
import '../../presentation/screens/creator_dashboard/creator_dashboard_screen.dart';
import '../../presentation/screens/creator_dashboard/insights_screen.dart';
import '../../presentation/screens/creator_dashboard/content_schedule_screen.dart';

// --- Admin ---
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/user_management_screen.dart';
import '../../presentation/screens/admin/content_moderation_screen.dart';
import '../../presentation/screens/admin/analytics_screen.dart';

// --- Onboarding ---
import '../../presentation/screens/auth/onboarding_screen.dart';

/// The app-level router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.watch(authStateProvider);
      final isAuthRoute = state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation == '/onboarding';

      // If not authenticated and trying to access a protected route
      if (!authState.isAuthenticated && !isAuthRoute) {
        return '/auth/login';
      }

      // If authenticated and trying to access auth routes, redirect to home
      if (authState.isAuthenticated && isAuthRoute) {
        return '/';
      }

      // If authenticated and onboarding is complete, redirect to home
      if (authState.isAuthenticated && state.matchedLocation == '/onboarding') {
        return '/';
      }

      return null;
    },
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth routes
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
        builder: (context, state) {
          final phoneNumber = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
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

      // Profile sub-routes (outside shell)
      GoRoute(
        path: '/profile/:userId',
        name: 'userProfile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/followers/:userId',
        name: 'followers',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return FollowersScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile/following/:userId',
        name: 'following',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return FollowingScreen(userId: userId);
        },
      ),

      // Chat sub-routes
      GoRoute(
        path: '/chat/:chatId',
        name: 'chat',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final peerName = state.uri.queryParameters['name'] ?? '';
          final peerAvatar = state.uri.queryParameters['avatar'] ?? '';
          return ChatScreen(
            chatId: chatId,
            peerName: peerName,
            peerAvatar: peerAvatar,
          );
        },
      ),

      // Stories sub-routes
      GoRoute(
        path: '/stories/view',
        name: 'storyViewer',
        builder: (context, state) {
          final userId = state.uri.queryParameters['userId'] ?? '';
          return StoryViewerScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/stories/create',
        name: 'createStory',
        builder: (context, state) => const CreateStoryScreen(),
      ),

      // Settings sub-routes
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        name: 'privacySettings',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        name: 'notificationSettings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/account',
        name: 'accountSettings',
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),

      // Nearby Friends
      GoRoute(
        path: '/nearby-friends',
        name: 'nearbyFriends',
        builder: (context, state) => const NearbyFriendsScreen(),
      ),

      // Creator Dashboard
      GoRoute(
        path: '/creator/dashboard',
        name: 'creatorDashboard',
        builder: (context, state) => const CreatorDashboardScreen(),
      ),
      GoRoute(
        path: '/creator/insights',
        name: 'creatorInsights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/creator/schedule',
        name: 'contentSchedule',
        builder: (context, state) => const ContentScheduleScreen(),
      ),

      // Admin routes
      GoRoute(
        path: '/admin',
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'userManagement',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/moderation',
        name: 'contentModeration',
        builder: (context, state) => const ContentModerationScreen(),
      ),
      GoRoute(
        path: '/admin/analytics',
        name: 'adminAnalytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
  );
});

/// Main shell widget with bottom navigation bar
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const List<({String path, IconData icon, String label})> _tabs = [
    (path: '/', icon: Icons.home_outlined, label: 'Home'),
    (path: '/search', icon: Icons.search, label: 'Search'),
    (path: '/reels', icon: Icons.movie_outlined, label: 'Reels'),
    (path: '/chat', icon: Icons.chat_bubble_outlined, label: 'Chat'),
    (path: '/profile', icon: Icons.person_outline, label: 'Profile'),
  ];

  int _currentIndex(BuildContext context, String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(context, location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          context.go(_tabs[index].path);
        },
        items: _tabs.map((tab) {
          return BottomNavigationBarItem(
            icon: Icon(tab.icon),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}
