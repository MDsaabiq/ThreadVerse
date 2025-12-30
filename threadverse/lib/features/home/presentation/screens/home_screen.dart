import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadverse/core/models/post_model.dart';
import 'package:threadverse/core/repositories/post_repository.dart';
import 'package:threadverse/core/widgets/post_card.dart';

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

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    try {
      _posts = await postRepository.listPosts(sort: _sortBy);
    } catch (_) {
      _posts = const [];
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load posts')));
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
          // Sort menu
          PopupMenuButton<String>(
            initialValue: _sortBy,
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
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
            ? const Center(child: CircularProgressIndicator())
            : _posts.isEmpty
            ? const Center(child: Text('No posts yet'))
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
                    username: post.authorUsername,
                    communityName: post.communityName,
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
              context.push('/community/flutter');
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
