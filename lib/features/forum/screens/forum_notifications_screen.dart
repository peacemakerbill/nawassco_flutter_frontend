import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/forum_notification.dart';
import '../providers/forum_provider.dart';

class ForumNotificationsScreen extends ConsumerStatefulWidget {
  const ForumNotificationsScreen({super.key});

  @override
  ConsumerState<ForumNotificationsScreen> createState() => _ForumNotificationsScreenState();
}

class _ForumNotificationsScreenState extends ConsumerState<ForumNotificationsScreen> {
  final List<String> _selectedNotifications = [];
  bool _selectMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(forumProvider.notifier).fetchNotifications();
    });
  }

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) {
        _selectedNotifications.clear();
      }
    });
  }

  void _toggleNotificationSelection(String id) {
    setState(() {
      if (_selectedNotifications.contains(id)) {
        _selectedNotifications.remove(id);
      } else {
        _selectedNotifications.add(id);
      }
    });
  }

  Future<void> _markSelectedAsRead() async {
    if (_selectedNotifications.isEmpty) return;

    await ref.read(forumProvider.notifier).markNotificationsAsRead(_selectedNotifications);
    setState(() {
      _selectedNotifications.clear();
      _selectMode = false;
    });
  }

  Future<void> _markAllAsRead() async {
    final notifications = ref.read(forumProvider).notifications;
    final unreadIds = notifications.where((n) => n.isUnread).map((n) => n.id).toList();

    if (unreadIds.isNotEmpty) {
      await ref.read(forumProvider.notifier).markNotificationsAsRead(unreadIds);
    }
  }

  void _handleNotificationTap(ForumNotification notification) {
    if (_selectMode) {
      _toggleNotificationSelection(notification.id);
      return;
    }

    // Mark as read if unread
    if (notification.isUnread) {
      ref.read(forumProvider.notifier).markNotificationsAsRead([notification.id]);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case 'thread_reply':
      case 'mention':
        if (notification.data['threadId'] != null) {
          context.go('/forum/thread/${notification.data['threadId']}');
        }
        break;
      case 'thread_like':
      case 'thread_bookmark':
      // Navigate to thread
        break;
      default:
        if (notification.actionUrl != null) {
          context.go(notification.actionUrl!);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(forumProvider).notifications;
    final unreadCount = ref.watch(forumProvider).unreadNotificationsCount;

    final unreadNotifications = notifications.where((n) => n.isUnread).toList();
    final readNotifications = notifications.where((n) => !n.isUnread).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            title: const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              if (notifications.isNotEmpty)
                IconButton(
                  icon: Icon(
                    _selectMode ? Icons.deselect : Icons.select_all,
                    color: Colors.white,
                  ),
                  onPressed: _toggleSelectMode,
                ),
              if (unreadCount > 0 && !_selectMode)
                IconButton(
                  icon: const Icon(Icons.done_all, color: Colors.white),
                  onPressed: _markAllAsRead,
                  tooltip: 'Mark all as read',
                ),
              if (_selectMode && _selectedNotifications.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.mark_email_read, color: Colors.white),
                  onPressed: _markSelectedAsRead,
                  tooltip: 'Mark selected as read',
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0066FF).withValues(alpha: 0.2),
                            const Color(0xFF00CCFF).withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0066FF).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '$unreadCount unread',
                        style: const TextStyle(
                          color: Color(0xFF00CCFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${notifications.length} total',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Unread notifications section
          if (unreadNotifications.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Unread',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          if (unreadNotifications.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final notification = unreadNotifications[index];
                  return _buildNotificationItem(notification, index);
                },
                childCount: unreadNotifications.length,
              ),
            ),

          // Read notifications section
          if (readNotifications.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Earlier',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          if (readNotifications.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final notification = readNotifications[index];
                  return _buildNotificationItem(notification, index + unreadNotifications.length);
                },
                childCount: readNotifications.length,
              ),
            ),

          // Empty state
          if (notifications.isEmpty)
            SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your notifications will appear here',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(ForumNotification notification, int index) {
    final isSelected = _selectedNotifications.contains(notification.id);
    final isUnread = notification.isUnread;

    return AnimatedOpacity(
      opacity: isSelected ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleNotificationTap(notification),
            onLongPress: () {
              if (!_selectMode) {
                _toggleSelectMode();
                _toggleNotificationSelection(notification.id);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isUnread
                        ? const Color(0xFF0066FF).withValues(alpha: 0.1)
                        : const Color(0xFF1E293B).withValues(alpha: 0.6),
                    isUnread
                        ? const Color(0xFF00CCFF).withValues(alpha: 0.05)
                        : const Color(0xFF0F172A).withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnread
                      ? const Color(0xFF0066FF).withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selection checkbox
                  if (_selectMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12, top: 4),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleNotificationSelection(notification.id),
                        activeColor: const Color(0xFF0066FF),
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),

                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getNotificationColor(notification.type).withValues(alpha: 0.2),
                          _getNotificationColor(notification.type).withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: isUnread ? 0.8 : 0.6),
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTimeAgo(notification.createdAt),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Unread indicator
                  if (isUnread && !_selectMode)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0066FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'thread_reply':
        return Icons.chat_bubble_outline;
      case 'thread_like':
        return Icons.favorite_border;
      case 'thread_bookmark':
        return Icons.bookmark_border;
      case 'mention':
        return Icons.alternate_email;
      case 'thread_approval':
      case 'reply_approval':
        return Icons.check_circle_outline;
      case 'moderation_action':
        return Icons.gavel;
      case 'subscription_digest':
        return Icons.email;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'thread_reply':
        return Colors.blue;
      case 'thread_like':
        return Colors.red;
      case 'thread_bookmark':
        return Colors.purple;
      case 'mention':
        return Colors.green;
      case 'thread_approval':
      case 'reply_approval':
        return Colors.green;
      case 'moderation_action':
        return Colors.orange;
      case 'subscription_digest':
        return Colors.blueGrey;
      default:
        return const Color(0xFF00CCFF);
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }
}