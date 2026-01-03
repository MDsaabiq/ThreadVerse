import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:threadverse/core/models/user_model.dart';
import 'package:threadverse/core/network/api_client.dart';
import 'package:threadverse/core/repositories/auth_repository.dart';
import 'package:threadverse/core/repositories/upload_repository.dart';
import 'package:threadverse/core/repositories/user_repository.dart';
import 'package:threadverse/core/widgets/post_card.dart';
import 'package:threadverse/core/repositories/post_repository.dart';
import 'package:threadverse/features/trust/widgets/profile_trust_widget.dart';

import 'dart:async';

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
  bool _uploadingAvatar = false;
  List<dynamic> _userPosts = [];
  bool _loadingPosts = false;
  bool _postsError = false;
  late PostRepository postRepository;
  late UserRepository userRepository;
  late UploadRepository uploadRepository;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    postRepository = PostRepository(ApiClient.instance.client);
    userRepository = UserRepository(ApiClient.instance.client);
    uploadRepository = UploadRepository(ApiClient.instance.client);
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

    final header = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: theme.primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.primaryColor,
                backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                    ? Text(
                        user.username.isNotEmpty
                            ? user.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              if (_isSelf)
                GestureDetector(
                  onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: _uploadingAvatar
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.scaffoldBackgroundColor,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: theme.scaffoldBackgroundColor,
                          ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              user.bio.isEmpty ? 'No bio yet' : user.bio,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
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
                'Total Karma',
                theme,
                icon: Icons.star,
                color: Colors.orange,
              ),
              _buildStatItem(
                '${user.followersCount}',
                'Followers',
                theme,
                icon: Icons.people,
                color: theme.primaryColor,
              ),
              _buildStatItem(
                '${user.followingCount}',
                'Following',
                theme,
                icon: Icons.person_add,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Karma breakdown
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.article, size: 20, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Post Karma',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${user.karmaPost}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.comment, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Comment Karma',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${user.karmaComment}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ProfileTrustLevelSection(
            userId: user.id,
            onViewBreakdown: () => context.push('/trust/${user.id}/breakdown'),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('u/${user.username}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(child: header),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarSliverDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'Comments'),
                  Tab(text: 'About'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          physics: const ClampingScrollPhysics(),
          children: [
            _buildPostsTab(),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('User comments not implemented yet'),
              ),
            ),
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
      await _loadUserPosts();
    } catch (e) {
      setState(() => _user = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadUserPosts() async {
    if (_user == null) return;
    setState(() {
      _loadingPosts = true;
      _postsError = false;
    });
    try {
      final posts = await postRepository
          .listUserPosts(
            username: _user!.username,
          )
          .timeout(const Duration(seconds: 8));
      if (mounted) {
        setState(() {
          _userPosts = posts;
          _postsError = false;
        });
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _userPosts = [];
          _postsError = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userPosts = [];
          _postsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _loadingPosts = false);
    }
  }

  Widget _buildPostsTab() {
    final theme = Theme.of(context);
    
    if (_loadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_postsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load posts',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check your connection and try again',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadUserPosts,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_userPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 64,
                color: theme.disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No posts yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserPosts,
      child: ListView.builder(
        itemCount: _userPosts.length,
        itemBuilder: (context, index) {
          final post = _userPosts[index];
          return PostCard(
            postId: post.id,
            title: post.title,
            content: post.body,
            imageUrl: post.imageUrl,
            username: post.authorUsername,
            authorId: post.authorId,
            communityName: post.communityName,
            timestamp: post.createdAt,
            upvotes: post.upvotes,
            downvotes: post.downvotes,
            commentCount: post.commentCount,
            onDelete: _loadUserPosts,
            onUpdate: _loadUserPosts,
          );
        },
      ),
    );
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

  Widget _buildStatItem(
    String value,
    String label,
    ThemeData theme, {
    IconData? icon,
    Color? color,
  }) {
    return Column(
      children: [
        if (icon != null) ...[
          Icon(icon, color: color ?? theme.primaryColor, size: 24),
          const SizedBox(height: 4),
        ],
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _uploadingAvatar = true);
        try {
          final avatarUrl = await uploadRepository.uploadAvatar(pickedFile);
          final updated = await userRepository.updateMe(
            avatarUrl: avatarUrl,
          );
          setState(() => _user = updated);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avatar updated successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error uploading avatar: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _uploadingAvatar = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }
}

class _TabBarSliverDelegate extends SliverPersistentHeaderDelegate {
  _TabBarSliverDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
