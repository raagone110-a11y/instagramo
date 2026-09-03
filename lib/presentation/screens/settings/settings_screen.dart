import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─── Settings Providers ───────────────────────────────────────────────────────

final isDarkModeProvider = StateProvider<bool>((ref) => true);
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final privateAccountProvider = StateProvider<bool>((ref) => false);
final showActivityStatusProvider = StateProvider<bool>((ref) => true);
final allowMessagesFromProvider = StateProvider<String>((ref) => 'Everyone');

// ─── Settings Screen ──────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

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
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Profile Summary Card ───────────────────────────────────────────
          _ProfileCard()
              .animate()
              .fade(duration: 400.ms)
              .slideY(begin: -0.1, end: 0),

          const SizedBox(height: 20),

          // ── Account Section ────────────────────────────────────────────────
          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                subtitle: 'Username, name, bio',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.phone_android_rounded,
                title: 'Phone & Email',
                subtitle: 'Manage contact info',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: 'Password',
                subtitle: 'Change password',
                onTap: () {},
              ),
            ],
          ),

          // ── Privacy Section ────────────────────────────────────────────────
          _SettingsSection(
            title: 'Privacy',
            children: [
              _SettingsSwitchTile(
                icon: Icons.lock_person_rounded,
                title: 'Private Account',
                subtitle: 'Only followers can see your posts',
                value: ref.watch(privateAccountProvider),
                onChanged: (value) =>
                    ref.read(privateAccountProvider.notifier).state = value,
              ),
              _SettingsSwitchTile(
                icon: Icons.visibility_rounded,
                title: 'Show Activity Status',
                subtitle: 'Let others see when you\'re online',
                value: ref.watch(showActivityStatusProvider),
                onChanged: (value) =>
                    ref.read(showActivityStatusProvider.notifier).state = value,
              ),
              _SettingsTile(
                icon: Icons.block_rounded,
                title: 'Blocked Accounts',
                subtitle: 'Manage blocked users',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.location_on_rounded,
                title: 'Location Services',
                subtitle: 'Nearby friends & location tags',
                onTap: () {},
              ),
            ],
          ),

          // ── Security Section ───────────────────────────────────────────────
          _SettingsSection(
            title: 'Security',
            children: [
              _SettingsTile(
                icon: Icons.verified_user_rounded,
                title: 'Two-Factor Authentication',
                subtitle: 'Add extra security layer',
                trailingBadge: 'Recommended',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.devices_rounded,
                title: 'Login Activity',
                subtitle: 'View active sessions',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.email_outlined,
                title: 'Login Alerts',
                subtitle: 'Get notified of new logins',
                onTap: () {},
              ),
            ],
          ),

          // ── Notifications Section ──────────────────────────────────────────
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsSwitchTile(
                icon: Icons.notifications_rounded,
                title: 'Push Notifications',
                subtitle: 'Likes, comments, follows',
                value: ref.watch(notificationsEnabledProvider),
                onChanged: (value) => ref
                    .read(notificationsEnabledProvider.notifier)
                    .state = value,
              ),
              _SettingsTile(
                icon: Icons.message_rounded,
                title: 'Message Requests',
                subtitle: 'Who can message you',
                trailingBadge: 'Everyone',
                onTap: () {},
              ),
            ],
          ),

          // ── Theme Section ──────────────────────────────────────────────────
          _SettingsSection(
            title: 'Appearance',
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dark Mode',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isDarkMode
                                ? 'Current: Dark theme active'
                                : 'Current: Light theme active',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.5),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isDarkMode,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        ref.read(isDarkModeProvider.notifier).state = value;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Language Section ───────────────────────────────────────────────
          _SettingsSection(
            title: 'General',
            children: [
              _SettingsTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'English (US)',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.storage_rounded,
                title: 'Data Usage',
                subtitle: 'Media quality & cache',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'FAQ, report a problem',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About Instagramo',
                subtitle: 'Version 2.4.1',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Logout Button ──────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: Icon(
                Icons.logout_rounded,
                color: const Color(0xFFE53935),
                size: 20,
              ),
              label: Text(
                'Log Out',
                style: TextStyle(
                  color: const Color(0xFFE53935),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ).animate().fade(delay: 300.ms, duration: 500.ms),

          const SizedBox(height: 12),

          Center(
            child: Text(
              '© 2024 Instagramo. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: Color(0xFFE53935),
            size: 28,
          ),
        ),
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              context.pop();
              context.go('/login');
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Card ─────────────────────────────────────────────────────────────

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE1306C), Color(0xFF833AB4)],
                  ),
                  borderRadius: BorderRadius.circular(34),
                ),
                child: CircleAvatar(
                  radius: 30,
                  child: ClipOval(
                    child: Image.network(
                      'https://i.pravatar.cc/150?img=12',
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: Icon(
                          Icons.person,
                          size: 30,
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
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@current_user',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'current.user@email.com',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Member since Jan 2024',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Section ─────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 68),
                      child: Divider(
                        height: 0.5,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.15),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingBadge;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingBadge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            if (trailingBadge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trailingBadge!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Settings Switch Tile ─────────────────────────────────────────────────────

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            Switch.adaptive(
              value: value,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
