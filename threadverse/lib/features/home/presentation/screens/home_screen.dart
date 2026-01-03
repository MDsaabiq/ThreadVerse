import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadverse/core/models/post_model.dart';
import 'package:threadverse/core/repositories/post_repository.dart';
import 'package:threadverse/core/widgets/post_card.dart';
import 'package:threadverse/core/widgets/notification_bell.dart';
import 'package:threadverse/core/widgets/post_card_skeleton.dart';

/// Home screen showing main feed
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _sortBy = 'hot';
  bool _loading = true;
  List<PostModel> _posts = const [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      _posts = await postRepository.listPosts(sort: _sortBy);
      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _posts = const [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load posts'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadPosts,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ThreadVerse'),
        elevation: 0,
        actions: [
          // Notification Bell
          const NotificationBell(),
          // Sort menu
          PopupMenuButton<String>(
            initialValue: _sortBy,
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadPosts();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'hot', child: Text('🔥 Hot')),
              const PopupMenuItem(value: 'new', child: Text('🆕 New')),
              const PopupMenuItem(value: 'top', child: Text('⭐ Top')),
              const PopupMenuItem(
                value: 'controversial',
                child: Text('💬 Controversial'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile/currentuser'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: _loading
            ? ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: 6,
                itemBuilder: (_, __) => const PostCardSkeleton(),
              )
            : _errorMessage != null
                ? _ErrorState(onRetry: _loadPosts)
                : _posts.isEmpty
                    ? _EmptyState(onCreatePost: () => context.push('/create-post'))
                    : ListView.builder(
                        itemCount: _posts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  FilterChip(
                                    label: const Text('All'),
                                    selected: true,
                                    onSelected: (value) {},
                                  ),
                                ],
                              ),
                            );
                          }

                          final post = _posts[index - 1];
                          return PostCard(
                            postId: post.id,
                            title: post.title,
                            content: post.body,
                            imageUrl: post.imageUrl,
                            username: post.authorUsername,
                            authorId: post.authorId,
                            communityName: post.communityName ?? 'Public',
                            timestamp: post.createdAt,
                            upvotes: post.upvotes,
                            downvotes: post.downvotes,
                            commentCount: post.commentCount,
                            onUpvote: () async {
                              await postRepository.votePost(post.id, 1);
                              _loadPosts();
                            },
                            onDownvote: () async {
                              await postRepository.votePost(post.id, -1);
                              _loadPosts();
                            },
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-post'),
        icon: const Icon(Icons.edit),
        label: const Text('Create Post'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.push('/communities');
              break;
            case 2:
              context.push('/profile/currentuser');
              break;
            case 3:
              context.push('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Communities',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_tethering_off,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Can\'t load the feed',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again. We\'re holding your place.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreatePost});

  final VoidCallback onCreatePost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.disabledColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kick off the conversation with your first post.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreatePost,
              icon: const Icon(Icons.edit),
              label: const Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }
}
