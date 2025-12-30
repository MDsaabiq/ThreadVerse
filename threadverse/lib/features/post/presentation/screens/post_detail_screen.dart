import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadverse/core/models/comment_model.dart';
import 'package:threadverse/core/models/post_model.dart';
import 'package:threadverse/core/repositories/comment_repository.dart';
import 'package:threadverse/core/repositories/post_repository.dart';
import 'package:threadverse/core/widgets/comment_card.dart';

/// Post detail screen with comments
class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late TextEditingController _commentController;
  PostModel? _post;
  List<CommentModel> _comments = const [];
  bool _loading = true;
  bool _isUpvoted = false;
  bool _isDownvoted = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final post = await postRepository.getPost(widget.postId);
      final comments = await commentRepository.listForPost(widget.postId);
      setState(() {
        _post = post;
        _comments = comments;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load post')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildComment(CommentModel comment, {int depth = 0}) {
    // For now, show flat list; nested replies would need grouping by parentId.
    return CommentCard(
      username: comment.authorUsername,
      content: comment.content,
      timestamp: comment.createdAt,
      upvotes: comment.upvotes,
      downvotes: comment.downvotes,
      depth: depth,
      onUpvote: () async {
        await commentRepository.vote(comment.id, 1);
        _load();
      },
      onDownvote: () async {
        await commentRepository.vote(comment.id, -1);
        _load();
      },
      onReply: () {
        _showReplyDialog(comment.id);
      },
    );
  }

  void _showReplyDialog(String parentCommentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply'),
        content: TextField(
          controller: _commentController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              () async {
                try {
                  await commentRepository.create(
                    postId: widget.postId,
                    parentId: parentCommentId,
                    content: _commentController.text.trim(),
                  );
                  _commentController.clear();
                  if (mounted) Navigator.pop(context);
                  _load();
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to reply')),
                  );
                }
              }();
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = _post;

    if (_loading || post == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Post content
          Expanded(
            child: ListView(
              children: [
                // Post header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Community and author
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: theme.primaryColor,
                            child: Text(
                              post.communityName.isNotEmpty
                                  ? post.communityName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => context.push(
                              '/community/${post.communityName}',
                            ),
                            child: Text(
                              'r/${post.communityName}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            ' • Posted by ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                          InkWell(
                            onTap: () =>
                                context.push('/profile/${post.authorUsername}'),
                            child: Text(
                              'u/${post.authorUsername}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        post.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content
                      if (post.body != null && post.body!.isNotEmpty)
                        Text(post.body!, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 16),

                      // Vote buttons
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isUpvoted
                                        ? Icons.arrow_upward
                                        : Icons.arrow_upward_outlined,
                                    size: 20,
                                  ),
                                  color: _isUpvoted ? Colors.orange : null,
                                  onPressed: () {
                                    () async {
                                      await postRepository.votePost(post.id, 1);
                                      _load();
                                    }();
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                                Text(
                                  post.voteScore.toString(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _isUpvoted
                                        ? Colors.orange
                                        : _isDownvoted
                                        ? Colors.blue
                                        : null,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isDownvoted
                                        ? Icons.arrow_downward
                                        : Icons.arrow_downward_outlined,
                                    size: 20,
                                  ),
                                  color: _isDownvoted ? Colors.blue : null,
                                  onPressed: () {
                                    () async {
                                      await postRepository.votePost(
                                        post.id,
                                        -1,
                                      );
                                      _load();
                                    }();
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                    ],
                  ),
                ),

                // Comments section header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${_comments.length} Comments',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.sort, size: 18),
                        label: const Text('Best'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Comments list
                ..._comments.map((comment) => _buildComment(comment)),

                const SizedBox(height: 80), // Space for comment input
              ],
            ),
          ),

          // Comment input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.primaryColor,
                    child: const Text(
                      'Y',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_commentController.text.isEmpty) return;
                      () async {
                        try {
                          await commentRepository.create(
                            postId: widget.postId,
                            content: _commentController.text.trim(),
                          );
                          _commentController.clear();
                          _load();
                        } catch (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to comment')),
                          );
                        }
                      }();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
