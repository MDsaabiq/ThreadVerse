import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Reusable post card widget for displaying posts
class PostCard extends StatelessWidget {
  final String postId;
  final String title;
  final String? content;
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

  const PostCard({
    super.key,
    required this.postId,
    required this.title,
    this.content,
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
                      communityName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => context.push('/community/$communityName'),
                    child: Text(
                      'r/$communityName',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                Text(
                  content!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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
    );
  }
}
