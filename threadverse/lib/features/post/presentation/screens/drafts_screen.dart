import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadverse/core/models/draft_model.dart';
import 'package:threadverse/core/repositories/post_repository.dart';
import 'package:threadverse/core/utils/error_handler.dart';

class DraftsScreen extends StatefulWidget {
  const DraftsScreen({super.key});

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  List<DraftModel> _drafts = [];
  bool _loading = true;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() => _loading = true);
    try {
      final drafts = await draftRepository.listUserDrafts(
        type: _filterType == 'all' ? null : _filterType,
      );
      setState(() {
        _drafts = drafts;
      });
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteDraft(String id) async {
    try {
      await draftRepository.deleteDraft(id);
      setState(() {
        _drafts.removeWhere((d) => d.id == id);
      });
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Draft deleted');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e);
      }
    }
  }

  Future<void> _deleteOldDrafts() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete old drafts'),
        content: const Text(
          'Delete all drafts older than 30 days? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final count = await draftRepository.deleteOldDrafts(daysOld: 30);
        _loadDrafts();
        if (mounted) {
          ErrorHandler.showSuccess(context, 'Deleted $count old drafts');
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.handleError(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Drafts'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'cleanup') {
                _deleteOldDrafts();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'cleanup',
                child: Text('Delete old drafts'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('All')),
                ButtonSegment(value: 'post', label: Text('Posts')),
                ButtonSegment(value: 'comment', label: Text('Comments')),
              ],
              selected: {_filterType},
              onSelectionChanged: (s) {
                setState(() => _filterType = s.first);
                _loadDrafts();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _drafts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.drafts_outlined,
                                size: 64, color: theme.hintColor),
                            const SizedBox(height: 16),
                            Text(
                              'No drafts yet',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start writing a post and it will auto-save',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDrafts,
                        child: ListView.builder(
                          itemCount: _drafts.length,
                          itemBuilder: (context, index) {
                            final draft = _drafts[index];
                            return _DraftCard(
                              draft: draft,
                              onTap: () {
                                if (draft.type == 'post') {
                                  context.push('/create-post?draftId=${draft.id}');
                                } else {
                                  // Navigate to comment draft
                                  context.push('/post/${draft.postId}?draftId=${draft.id}');
                                }
                              },
                              onDelete: () => _deleteDraft(draft.id),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final DraftModel draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DraftCard({
    required this.draft,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _formatTimeAgo(draft.lastSavedAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    draft.type == 'post' ? Icons.article : Icons.comment,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      draft.type == 'post'
                          ? draft.title ?? '(Untitled post)'
                          : 'Comment draft',
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
              if (draft.type == 'post') ...[
                if (draft.communityName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'r/${draft.communityName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                if (draft.body != null && draft.body!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      draft.body!,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              if (draft.type == 'comment' && draft.content != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    draft.content!,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Saved $timeAgo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}
