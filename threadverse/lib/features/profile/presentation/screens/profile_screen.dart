import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadverse/core/models/user_model.dart';
import 'package:threadverse/core/network/api_client.dart';
import 'package:threadverse/core/repositories/auth_repository.dart';
import 'package:threadverse/core/repositories/user_repository.dart';
import 'package:threadverse/core/widgets/post_card.dart';

/// User profile screen
class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _user;
  bool _loading = true;
  bool _isSelf = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('u/${widget.username}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('User not found')),
      );
    }

    final user = _user!;

    return Scaffold(
      appBar: AppBar(
        title: Text('u/${user.username}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Profile header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: theme.primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.primaryColor,
                  child: Text(
                    user.username.isNotEmpty
                        ? user.username[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.bio.isEmpty ? 'No bio yet' : user.bio,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (_isSelf)
                  TextButton.icon(
                    onPressed: _showEditDialog,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit profile'),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      '${user.karmaPost + user.karmaComment}',
                      'Karma',
                      theme,
                    ),
                    _buildStatItem(
                      '${user.followersCount}',
                      'Followers',
                      theme,
                    ),
                    _buildStatItem(
                      '${user.followingCount}',
                      'Following',
                      theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Posts'),
              Tab(text: 'About'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Posts
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('User posts feed not implemented yet'),
                  ),
                ),
                // About
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.cake, color: theme.primaryColor),
                        title: const Text('Cake Day'),
                        subtitle: Text(
                          user.createdAt
                              .toLocal()
                              .toIso8601String()
                              .split('T')
                              .first,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      UserModel user;
      if (widget.username == 'currentuser') {
        final me = await AuthRepository(ApiClient.instance.client).me();
        user = me;
        _isSelf = true;
      } else {
        user = await userRepository.getUser(widget.username);
      }
      setState(() => _user = user);
    } catch (_) {
      setState(() => _user = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showEditDialog() {
    final displayController = TextEditingController(
      text: _user?.displayName ?? '',
    );
    final bioController = TextEditingController(text: _user?.bio ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: displayController,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final updated = await userRepository.updateMe(
                  displayName: displayController.text.trim().isEmpty
                      ? null
                      : displayController.text.trim(),
                  bio: bioController.text.trim(),
                );
                setState(() => _user = updated);
                if (mounted) Navigator.pop(context);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update profile')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
