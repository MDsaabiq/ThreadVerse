import 'package:flutter/material.dart';

/// Settings screen with key preferences and account actions (mock)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _amoled = false;
  bool _pushMentions = true;
  bool _pushReplies = true;
  bool _emailDigests = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                subtitle: const Text('Match system or toggle manually'),
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              SwitchListTile(
                title: const Text('AMOLED mode'),
                subtitle: const Text('Pure black backgrounds'),
                value: _amoled,
                onChanged: (v) => setState(() => _amoled = v),
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
