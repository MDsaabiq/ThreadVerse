import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadverse/core/models/user_model.dart';
import 'package:threadverse/core/repositories/user_repository.dart';

/// User preview screen - shows other user's profile with follow button
class UserPreviewScreen extends StatefulWidget {
  final String username;

  const UserPreviewScreen({super.key, required this.username});

  @override
  State<UserPreviewScreen> createState() => _UserPreviewScreenState();
}

class _UserPreviewScreenState extends State<UserPreviewScreen> {
  UserModel? _user;
  bool _loading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    try {
      final user = await userRepository.getUser(widget.username);
      setState(() {
        _user = user;
        _isFollowing = false; // Start as not following
      });
    } catch (_) {
      setState(() => _user = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Not Found'),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.primaryColor,
              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                  ? Text(
                      user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Username
            Text(
              'u/${user.username}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Display name
            if (user.displayName.isNotEmpty)
              Text(
                user.displayName,
                style: theme.textTheme.bodyLarge,
              ),
            const SizedBox(height: 8),

            // Bio
            if (user.bio.isNotEmpty)
              Text(
                user.bio,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),

            // Stats
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
            const SizedBox(height: 24),

            // Follow/Unfollow button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isFollowing = !_isFollowing);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isFollowing
                            ? 'Following ${user.username}'
                            : 'Unfollowed ${user.username}',
                      ),
                    ),
                  );
                },
                icon: Icon(_isFollowing ? Icons.person_remove : Icons.person_add),
                label: Text(_isFollowing ? 'Unfollow' : 'Follow'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.primaryColor,
                  foregroundColor: _isFollowing
                      ? theme.textTheme.bodyMedium?.color
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // About section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(Icons.cake, color: theme.primaryColor),
                title: const Text('Joined'),
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
