import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threadverse/core/theme/theme_controller.dart';

/// Settings screen with key preferences and account actions (mock)
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushMentions = true;
  bool _pushReplies = true;
  bool _emailDigests = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);
    final isDark = themeState.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _section(
            title: 'Appearance',
            children: [
              SwitchListTile(
                title: const Text('Dark mode'),
                subtitle: const Text('Overrides system preference'),
                value: isDark,
                onChanged: (v) async {
                  await themeController.setThemeMode(
                    v ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
              SwitchListTile(
                title: const Text('AMOLED mode'),
                subtitle: const Text('Pure black backgrounds'),
                value: themeState.useAmoled,
                onChanged: isDark
                    ? (v) async => themeController.setAmoled(v)
                    : null,
              ),
            ],
          ),

          _section(
            title: 'Notifications',
            children: [
              SwitchListTile(
                title: const Text('Mentions'),
                subtitle: const Text('Push notifications for @mentions'),
                value: _pushMentions,
                onChanged: (v) => setState(() => _pushMentions = v),
              ),
              SwitchListTile(
                title: const Text('Replies'),
                subtitle: const Text('Replies to your posts and comments'),
                value: _pushReplies,
                onChanged: (v) => setState(() => _pushReplies = v),
              ),
              SwitchListTile(
                title: const Text('Email digests'),
                subtitle: const Text('Weekly highlights and recommendations'),
                value: _emailDigests,
                onChanged: (v) => setState(() => _emailDigests = v),
              ),
            ],
          ),

          _section(
            title: 'Account',
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                subtitle: const Text('View and edit your profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: navigate to profile edit
                },
              ),
              ListTile(
                leading: const Icon(Icons.leaderboard_outlined),
                title: const Text('Trust Leaderboard'),
                subtitle: const Text('View top trusted users'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/trust/leaderboard'),
              ),
              ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Analytics Dashboard'),
                subtitle: const Text('View community metrics'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/analytics/dashboard'),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy'),
                subtitle: const Text('Blocked users, data controls'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed out (mock).')),
                  );
                },
              ),
            ],
          ),

          _section(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('Terms & Privacy'),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.feedback_outlined),
            label: const Text('Send feedback'),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
