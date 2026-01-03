import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:threadverse/features/trust/widgets/profile_trust_widget.dart';
import 'package:threadverse/core/network/api_client.dart';
import 'package:threadverse/core/repositories/user_repository.dart';

/// Reusable comment card widget for displaying comments
class CommentCard extends StatelessWidget {
  final String username;
  final String? authorId;
  final String? avatarUrl;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final int upvotes;
  final int downvotes;
  final bool isUpvoted;
  final bool isDownvoted;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onReply;
  final int replyCount;
  final int depth;
  final List<Widget>? replies;

  const CommentCard({
    super.key,
    required this.username,
    this.authorId,
    this.avatarUrl,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.upvotes = 0,
    this.downvotes = 0,
    this.isUpvoted = false,
    this.isDownvoted = false,
    this.onUpvote,
    this.onDownvote,
    this.onReply,
    this.replyCount = 0,
    this.depth = 0,
    this.replies,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netVotes = upvotes - downvotes;

    return Container(
      margin: EdgeInsets.only(left: depth * 16.0, bottom: 8.0),
      decoration: BoxDecoration(
        border: depth > 0
            ? Border(
                left: BorderSide(
                  color: theme.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              )
            : null,
      ),
      child: Card(
        margin: EdgeInsets.only(left: depth > 0 ? 8.0 : 0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CommentAvatar(
                    username: username,
                    authorId: authorId,
                    avatarUrl: avatarUrl,
                    onTap: () => context.push('/user-preview/$username'),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/user-preview/$username'),
                    child: Text(
                      'u/$username',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  if (authorId != null && authorId!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    MiniTrustIndicator(userId: authorId!),
                  ],
                  const SizedBox(width: 8),
                  Text(
                    '• ${timeago.format(timestamp)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Content
              Text(content, style: theme.textTheme.bodyMedium),
              
              // Image preview if exists
              if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),

              // Actions
              Row(
                children: [
                  // Upvote
                  IconButton(
                    icon: Icon(
                      isUpvoted
                          ? Icons.arrow_upward
                          : Icons.arrow_upward_outlined,
                      size: 18,
                    ),
                    color: isUpvoted ? Colors.orange : null,
                    onPressed: onUpvote,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
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
                  const SizedBox(width: 4),
                  // Downvote
                  IconButton(
                    icon: Icon(
                      isDownvoted
                          ? Icons.arrow_downward
                          : Icons.arrow_downward_outlined,
                      size: 18,
                    ),
                    color: isDownvoted ? Colors.blue : null,
                    onPressed: onDownvote,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),

                  // Reply button
                  TextButton.icon(
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('Reply'),
                    onPressed: onReply,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),

                  if (replyCount > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '$replyCount ${replyCount == 1 ? 'reply' : 'replies'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),

              // Nested replies
              if (replies != null && replies!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...replies!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CommentAvatar extends StatefulWidget {
  final String username;
  final String? authorId;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const CommentAvatar({
    super.key,
    required this.username,
    this.authorId,
    this.avatarUrl,
    this.onTap,
  });

  @override
  State<CommentAvatar> createState() => _CommentAvatarState();
}

class _CommentAvatarState extends State<CommentAvatar> {
  static final Map<String, String?> _cache = {};
  String? _resolvedUrl;
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    _resolvedUrl = widget.avatarUrl;
    _maybeFetch();
  }

  @override
  void didUpdateWidget(covariant CommentAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authorId != widget.authorId || oldWidget.avatarUrl != widget.avatarUrl) {
      _resolvedUrl = widget.avatarUrl;
      _maybeFetch();
    }
  }

  void _maybeFetch() {
    if ((_resolvedUrl != null && _resolvedUrl!.isNotEmpty)) return;
    final cacheKey = widget.authorId ?? widget.username;
    final cached = _cache[cacheKey];
    if (cached != null) {
      setState(() => _resolvedUrl = cached);
      return;
    }
    _fetchAvatar(cacheKey);
  }

  Future<void> _fetchAvatar(String cacheKey) async {
    if (_fetching) return;
    _fetching = true;
    try {
      final repo = UserRepository(ApiClient.instance.client);
      final user = await repo.getUser(widget.username);
      final url = user.avatarUrl;
      _cache[cacheKey] = url;
      if (mounted) {
        setState(() => _resolvedUrl = url);
      }
    } catch (_) {
      // Fail silently; keep fallback initial
    } finally {
      _fetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = widget.username.isNotEmpty ? widget.username[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: widget.onTap,
      child: CircleAvatar(
        radius: 12,
        backgroundColor: theme.primaryColor,
        backgroundImage: _resolvedUrl != null && _resolvedUrl!.isNotEmpty
            ? NetworkImage(_resolvedUrl!)
            : null,
        child: (_resolvedUrl == null || _resolvedUrl!.isEmpty)
            ? Text(
                initial,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}
