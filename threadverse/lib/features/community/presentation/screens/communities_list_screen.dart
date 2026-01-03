import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadverse/core/models/community_model.dart';
import 'package:threadverse/core/repositories/community_repository.dart';

/// Communities list screen showing all available communities
class CommunitiesListScreen extends StatefulWidget {
  const CommunitiesListScreen({super.key});

  @override
  State<CommunitiesListScreen> createState() => _CommunitiesListScreenState();
}

class _CommunitiesListScreenState extends State<CommunitiesListScreen> {
  List<CommunityModel> _communities = const [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final communities = await communityRepository.listCommunities();
      setState(() {
        _communities = communities;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _communities = const [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load communities'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadCommunities,
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/create-community'),
            tooltip: 'Create Community',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCommunities,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Failed to load communities. Please check your connection.',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadCommunities,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : _communities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.groups_outlined,
                              size: 64,
                              color: theme.disabledColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No communities yet',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.disabledColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to create a community!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.disabledColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.push('/create-community'),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Community'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _communities.length,
                        itemBuilder: (context, index) {
                          final community = _communities[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                backgroundImage: community.iconUrl != null && community.iconUrl!.isNotEmpty
                                    ? NetworkImage(community.iconUrl!)
                                    : null,
                                child: (community.iconUrl == null || community.iconUrl!.isEmpty)
                                    ? Text(
                                    community.name.isNotEmpty
                                      ? community.name[0].toUpperCase()
                                      : '?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onPrimaryContainer,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                'r/${community.name}',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    community.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${community.memberCount} members',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.disabledColor,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: community.isPrivate
                                  ? Tooltip(
                                      message: 'Private Community',
                                      child: Icon(
                                        Icons.lock_outlined,
                                        color: theme.colorScheme.error,
                                        size: 20,
                                      ),
                                    )
                                  : null,
                              onTap: () => context.push(
                                '/community/${community.name}',
                              ),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-community'),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }
}
