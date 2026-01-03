import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadverse/core/models/comment_model.dart';
import 'package:threadverse/core/models/post_model.dart';
import 'package:threadverse/core/models/user_model.dart';
import 'package:threadverse/core/repositories/comment_repository.dart';
import 'package:threadverse/core/repositories/post_repository.dart';
import 'package:threadverse/core/repositories/auth_repository.dart';
import 'package:threadverse/core/network/api_client.dart';
import 'package:threadverse/core/widgets/comment_card.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Post detail screen with comments
class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late TextEditingController _commentController;
  PostModel? _post;
  UserModel? _me;
  List<CommentModel> _comments = [];
  Map<String, List<CommentModel>> _repliesByParent = {};
  bool _loading = false;
  bool _isUpvoted = false;
  bool _isDownvoted = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _loadMe();
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
      final replies = <String, List<CommentModel>>{};

      for (final comment in comments) {
        final parentId = comment.parentCommentId;
        if (parentId != null) {
          replies.putIfAbsent(parentId, () => []).add(comment);
        }
      }

      setState(() {
        _post = post;
        _comments = comments;
        _repliesByParent = replies;
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

  Future<void> _loadMe() async {
    try {
      final user = await AuthRepository(ApiClient.instance.client).me();
      if (mounted) setState(() => _me = user);
    } catch (_) {
      // Best-effort; keep _me null if unauthenticated or failed
    }
  }

  List<CommentModel> get _rootComments =>
      _comments.where((c) => c.parentCommentId == null).toList();

  Widget _buildCommentThread(CommentModel comment, {int depth = 0}) {
    final children = _repliesByParent[comment.id] ?? [];
    final isOwnComment = _me != null &&
        ((comment.authorId?.isNotEmpty == true && comment.authorId == _me!.id) ||
            comment.authorUsername == _me!.username);

    return CommentCard(
      username: comment.authorUsername,
      authorId: comment.authorId,
      avatarUrl: comment.avatarUrl,
      content: comment.content,
      timestamp: comment.createdAt,
      upvotes: comment.upvotes,
      downvotes: comment.downvotes,
      depth: depth,
      replyCount: children.length,
      replies: children
          .map((child) => _buildCommentThread(child, depth: depth + 1))
          .toList(),
      onUpvote: () async {
        await commentRepository.vote(comment.id, 1);
        _load();
      },
      onDownvote: () async {
        await commentRepository.vote(comment.id, -1);
        _load();
      },
      onReply: isOwnComment
          ? null
          : () {
              _showReplyDialog(comment.id);
            },
    );
  }

  void _showReplyDialog(String parentCommentId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply'),
        content: TextField(
          controller: controller,
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
            onPressed: () async {
              try {
                await commentRepository.create(
                  postId: widget.postId,
                  parentId: parentCommentId,
                  content: controller.text.trim(),
                );
                controller.clear();
                if (mounted) Navigator.pop(context);
                _load();
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to reply')),
                );
              }
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
                      if (post.body != null && post.body!.isNotEmpty) ...[
                        MarkdownBody(
                          data: post.body!,
                          styleSheet: MarkdownStyleSheet(
                            p: theme.textTheme.bodyMedium,
                            h1: theme.textTheme.headlineMedium,
                            h2: theme.textTheme.headlineSmall,
                            h3: theme.textTheme.titleLarge,
                            a: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                            code: theme.textTheme.bodySmall?.copyWith(
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              fontFamily: 'monospace',
                            ),
                            blockquote: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          shrinkWrap: true,
                          onTapLink: (text, href, title) {
                            if (href != null) {
                              // Handle link navigation
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Image display
                      if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 250,
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                ..._rootComments.map(
                  (comment) => _buildCommentThread(comment),
                ),

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
