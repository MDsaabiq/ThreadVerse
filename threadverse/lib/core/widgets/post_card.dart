import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:threadverse/core/repositories/post_repository.dart';
import 'package:threadverse/core/repositories/auth_repository.dart';
import 'package:threadverse/core/network/api_client.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:threadverse/features/trust/widgets/profile_trust_widget.dart';

/// Reusable post card widget for displaying posts
class PostCard extends StatelessWidget {
  final String postId;
  final String title;
  final String? content;
  final String? imageUrl;
  final String username;
  final String? authorId;
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
    this.authorId,
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
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
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
                    '• Posted by',
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
                  if (authorId != null && authorId!.isNotEmpty)
                    MiniTrustIndicator(userId: authorId!),
                  Text(
                    '• ${timeago.format(timestamp)}',
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
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

                      ConstrainedBox(
                        constraints: BoxConstraints(
                          // Allow wrap while preventing negative widths
                          maxWidth: availableWidth,
                        ),
                        child: InkWell(
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
                                Flexible(
                                  child: Text(
                                    '$commentCount ${commentCount == 1 ? 'Comment' : 'Comments'}',
                                    style: theme.textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 18),
                        onPressed: () {},
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
