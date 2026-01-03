import 'package:flutter/material.dart';
import 'package:threadverse/core/models/notification_model.dart';
import 'package:threadverse/core/repositories/notification_repository.dart';

import 'dart:async';

/// Modern notification bell widget with dropdown
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<NotificationModel> _notifications = const [];
  int _unreadCount = 0;
  bool _loading = false;
  bool _isOpen = false;
  bool _hasError = false;
  late OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadNotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (_loading) return;
    
    if (!mounted) return;
    setState(() => _loading = true);
    
    try {
      final notifications = await notificationRepository
          .listNotifications()
          .timeout(const Duration(seconds: 5));
      final unreadCount =
          await notificationRepository.getUnreadCount().timeout(
                const Duration(seconds: 5),
              );
      
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _unreadCount = unreadCount;
        _loading = false;
        _hasError = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _notifications = [];
        _loading = false;
        _hasError = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _notifications = [];
        _loading = false;
        _hasError = true;
      });
    }
  }

  void _togglePanel() {
    if (_isOpen) {
      _animationController.reverse();
      _overlayEntry.remove();
      setState(() => _isOpen = false);
    } else {
      _loadNotifications();
      _animationController.forward();
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry);
      setState(() => _isOpen = true);
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);
        final screenWidth = MediaQuery.of(context).size.width;
        // Keep panel within viewport on narrow screens to avoid overflow
        final panelWidth = screenWidth - 16 <= 360
            ? (screenWidth - 16).clamp(240.0, 360.0)
            : 360.0;
        return Positioned(
          top: 60,
          right: 8,
          width: panelWidth,
          child: ScaleTransition(
            scale: _animationController,
            alignment: Alignment.topRight,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            'Notifications',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_unreadCount > 0)
                            InkWell(
                              onTap: () async {
                                await notificationRepository.markAllAsRead();
                                _loadNotifications();
                              },
                              child: Text(
                                'Mark all as read',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _loading
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : _hasError
                            ? Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Failed to load notifications',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadNotifications,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : _notifications.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.notifications_none,
                                          size: 48,
                                          color: theme.disabledColor,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No notifications yet',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme.disabledColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: 400,
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: _notifications.length,
                                      separatorBuilder: (_, __) => Divider(
                                        height: 1,
                                        color: theme.dividerColor,
                                      ),
                                      itemBuilder: (context, index) {
                                        final notification =
                                            _notifications[index];
                                        return _buildNotificationItem(
                                          context,
                                          theme,
                                          notification,
                                        );
                                      },
                                    ),
                                  ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    ThemeData theme,
    NotificationModel notification,
  ) {
    return Container(
      color: notification.isRead
          ? theme.scaffoldBackgroundColor
          : theme.primaryColor.withOpacity(0.08),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (!notification.isRead) {
              await notificationRepository.markAsRead(notification.id);
              _loadNotifications();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      notification.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: notification.isRead
                                    ? theme.textTheme.bodyMedium?.color
                                    : theme.primaryColor,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.timeAgo,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        IconButton(
          icon: Badge(
            label: _unreadCount > 0
                ? Text(
                    _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
            backgroundColor: theme.colorScheme.error,
            isLabelVisible: _unreadCount > 0,
            child: const Icon(Icons.notifications),
          ),
          onPressed: _togglePanel,
        ),
      ],
    );
  }
}
