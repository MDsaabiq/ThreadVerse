import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadverse/core/models/community_model.dart';
import 'package:threadverse/core/models/post_model.dart';
import 'package:threadverse/core/repositories/community_repository.dart';
import 'package:threadverse/core/repositories/post_repository.dart';
import 'package:threadverse/core/widgets/community_header.dart';
import 'package:threadverse/core/widgets/post_card.dart';

/// Community screen
class CommunityScreen extends StatefulWidget {
  final String communityId;

  const CommunityScreen({super.key, required this.communityId});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isJoined = false;
  String _sortBy = 'hot';
  CommunityModel? _community;
  List<PostModel> _posts = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final community = await communityRepository.getCommunity(
        widget.communityId,
      );
      final posts = await postRepository.listPosts(
        community: widget.communityId,
        sort: _sortBy,
      );
      setState(() {
        _community = community;
        _posts = posts;
      });
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load community')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posts = _posts;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _loading || _community == null
                    ? const Center(child: CircularProgressIndicator())
                    : CommunityHeader(
                        name: _community!.name,
                        description: _community!.description,
                        memberCount: _community!.memberCount,
                        isJoined: _isJoined,
                        onJoinToggle: () async {
                          setState(() => _isJoined = !_isJoined);
                          try {
                            if (_isJoined) {
                              await communityRepository.join(_community!.name);
                            } else {
                              await communityRepository.leave(_community!.name);
                            }
                          } catch (_) {
                            setState(() => _isJoined = !_isJoined);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to update membership'),
                              ),
                            );
                          }
                        },
                      ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'About'),
                  Tab(text: 'Rules'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Posts Tab
            _loading
                ? const Center(child: CircularProgressIndicator())
                : posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
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
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to post!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.push(
                            '/create-post?communityId=${widget.communityId}',
                          ),
                          child: const Text('Create Post'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      itemCount: posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SegmentedButton<String>(
                                    segments: const [
                                      ButtonSegment(
                                        value: 'hot',
                                        label: Text('Hot'),
                                      ),
                                      ButtonSegment(
                                        value: 'new',
                                        label: Text('New'),
                                      ),
                                      ButtonSegment(
                                        value: 'top',
                                        label: Text('Top'),
                                      ),
                                    ],
                                    selected: {_sortBy},
                                    onSelectionChanged:
                                        (Set<String> selection) {
                                          setState(
                                            () => _sortBy = selection.first,
                                          );
                                        },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final post = posts[index - 1];
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
                        );
                      },
                    ),
                  ),

            // About Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Community',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _community?.description ?? '',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(
                    theme,
                    'Members',
                    '${_community?.memberCount ?? 0}',
                    Icons.people,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(theme, 'Created', 'Jan 1, 2024', Icons.cake),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    theme,
                    'Active',
                    '2.5k online',
                    Icons.circle,
                    iconColor: Colors.green,
                  ),
                ],
              ),
            ),

            // Rules Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildRuleCard(
                  theme,
                  1,
                  'Be Respectful',
                  'Treat others with respect. No harassment or hate speech.',
                ),
                _buildRuleCard(
                  theme,
                  2,
                  'Stay On Topic',
                  'Keep discussions relevant to the community theme.',
                ),
                _buildRuleCard(
                  theme,
                  3,
                  'No Spam',
                  'Don\'t spam or post irrelevant content.',
                ),
                _buildRuleCard(
                  theme,
                  4,
                  'Quality Content',
                  'Post high-quality, meaningful content.',
                ),
                _buildRuleCard(
                  theme,
                  5,
                  'Follow Guidelines',
                  'Adhere to ThreadVerse community guidelines.',
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => context.push(
                '/create-post?communityId=${widget.communityId}',
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    Color? iconColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? theme.primaryColor),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(
    ThemeData theme,
    int number,
    String title,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.primaryColor,
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
