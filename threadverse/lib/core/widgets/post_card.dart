import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:threadverse/core/repositories/post_repository.dart';
import 'package:threadverse/core/repositories/auth_repository.dart';
import 'package:threadverse/core/network/api_client.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Reusable post card widget for displaying posts
class PostCard extends StatelessWidget {
  final String postId;
  final String title;
  final String? content;
  final String? imageUrl;
  final String username;
  final String communityName;
  final DateTime timestamp;
  final int upvotes;
  final int downvotes;
  final int commentCount;
  final bool isUpvoted;
  final bool isDownvoted;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onComment;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdate;

  const PostCard({
    super.key,
    required this.postId,
    required this.title,
    this.content,
    this.imageUrl,
    required this.username,
    required this.communityName,
    required this.timestamp,
    this.upvotes = 0,
    this.downvotes = 0,
    this.commentCount = 0,
    this.isUpvoted = false,
    this.isDownvoted = false,
    this.onUpvote,
    this.onDownvote,
    this.onComment,
    this.onDelete,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netVotes = upvotes - downvotes;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => context.push('/post/$postId'),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: theme.primaryColor,
                    child: Text(
                      communityName.isNotEmpty
                          ? communityName[0].toUpperCase()
                          : '📢',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (communityName.isNotEmpty)
                    InkWell(
                      onTap: () => context.push('/community/$communityName'),
                      child: Text(
                        'r/$communityName',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Public',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  Text(
                    ' • Posted by ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                  InkWell(
                    onTap: () => context.push('/profile/$username'),
                    child: Text(
                      'u/$username',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    ' • ${timeago.format(timestamp)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  _buildPostMenu(context, theme),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Content preview
              if (content != null && content!.isNotEmpty) ...[
                const SizedBox(height: 8),
                MarkdownBody(
                  data: content!,
                  styleSheet: MarkdownStyleSheet(
                    p: theme.textTheme.bodyMedium,
                    a: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    code: theme.textTheme.bodySmall?.copyWith(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      fontFamily: 'monospace',
                    ),
                  ),
                  shrinkWrap: true,
                  onTapLink: (text, href, title) {
                    if (href != null) {
                      // Handle link navigation
                    }
                  },
                ),
              ],

              // Image preview
              if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Actions
              Row(
                children: [
                  // Votes
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
                        InkWell(
                          onTap: onUpvote,
                          child: Icon(
                            isUpvoted
                                ? Icons.arrow_upward
                                : Icons.arrow_upward_outlined,
                            size: 18,
                            color: isUpvoted ? Colors.orange : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          netVotes.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isUpvoted
                                ? Colors.orange
                                : isDownvoted
                                ? Colors.blue
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onDownvote,
                          child: Icon(
                            isDownvoted
                                ? Icons.arrow_downward
                                : Icons.arrow_downward_outlined,
                            size: 18,
                            color: isDownvoted ? Colors.blue : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Comments
                  InkWell(
                    onTap: onComment ?? () => context.push('/post/$postId'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.comment_outlined, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '$commentCount ${commentCount == 1 ? 'Comment' : 'Comments'}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 18),
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

  Widget _buildPostMenu(BuildContext context, ThemeData theme) {
    return FutureBuilder(
      future: _checkIsOwnPost(),
      builder: (context, snapshot) {
        final isOwnPost = snapshot.data ?? false;
        
        return PopupMenuButton<String>(
          icon: Icon(Icons.more_horiz, size: 20),
          onSelected: (value) async {
            if (value == 'edit') {
              _showEditDialog(context);
            } else if (value == 'delete') {
              _showDeleteConfirmation(context);
            } else if (value == 'share') {
              // Handle share
            }
          },
          itemBuilder: (context) => [
            if (isOwnPost) ...[
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 18),
                  SizedBox(width: 12),
                  Text('Share'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _checkIsOwnPost() async {
    try {
      final authRepo = AuthRepository(ApiClient.instance.client);
      final user = await authRepo.me();
      return user.username == username;
    } catch (_) {
      return false;
    }
  }

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: title);
    final bodyController = TextEditingController(text: content ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await postRepository.updatePost(
                  id: postId,
                  title: titleController.text.trim(),
                  body: bodyController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post updated successfully')),
                  );
                  if (onUpdate != null) onUpdate!();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update post: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await postRepository.deletePost(postId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted successfully')),
                  );
                  if (onDelete != null) onDelete!();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete post: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
    );
  }
}
