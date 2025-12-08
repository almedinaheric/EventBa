import 'package:eventba_mobile/models/enums/notification_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/notification_card.dart';
import 'package:eventba_mobile/providers/notification_provider.dart';
import 'package:eventba_mobile/models/notification/notification.dart'
    as notification_model;
import 'package:eventba_mobile/screens/notification_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<notification_model.Notification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      final notifications = await notificationProvider.getMyNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to load notifications: $e");
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar("Failed to load notifications");
    }
  }

  Future<void> _markAsRead(notification_model.Notification notification) async {
    if (notification.isRead) return;
    try {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      await notificationProvider.markAsRead(notification.id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification_model.Notification(
            id: notification.id,
            createdAt: notification.createdAt,
            updatedAt: DateTime.now(),
            eventId: notification.eventId,
            isSystemNotification: notification.isSystemNotification,
            title: notification.title,
            content: notification.content,
            isImportant: notification.isImportant,
            status: NotificationStatus.Read,
          );
        }
      });
    } catch (e) {
      print("Failed to mark notification as read: $e");
      _showErrorSnackBar("Failed to mark notification as read");
    }
  }

  Future<void> _deleteNotification(
    notification_model.Notification notification,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text(
          'Are you sure you want to delete this notification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).delete(notification.id);
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });
      } catch (e) {
        print("Failed to delete notification: $e");
        _showErrorSnackBar("Failed to delete notification");
      }
    }
  }

  Future<void> _navigateToNotificationDetails(
    notification_model.Notification notification,
  ) async {
    _markAsRead(notification);
    final bool? didChange = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            NotificationDetailsScreen(notification: notification),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    if (didChange == true) {
      _loadNotifications();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return MasterScreenWidget(
      appBarType: AppBarType.iconsSideTitleCenter,
      title: unreadCount > 0 ? "Notifications ($unreadCount)" : "Notifications",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context, true);
      },
      rightIcon: _notifications.isNotEmpty ? Icons.mark_email_read : null,
      onRightButtonPressed: _notifications.isNotEmpty ? _markAllAsRead : null,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isNotEmpty
          ? RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'You have $unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ..._buildNotificationsCardsList(_notifications),
                  const SizedBox(height: 60),
                ],
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _markAllAsRead() async {
    try {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      await notificationProvider.markAllAsRead();
      setState(() {
        _notifications = _notifications.map((notification) {
          return notification_model.Notification(
            id: notification.id,
            createdAt: notification.createdAt,
            updatedAt: DateTime.now(),
            eventId: notification.eventId,
            isSystemNotification: notification.isSystemNotification,
            title: notification.title,
            content: notification.content,
            isImportant: notification.isImportant,
            status: NotificationStatus.Read,
          );
        }).toList();
      });
    } catch (e) {
      print("Failed to mark all as read: $e");
      _showErrorSnackBar("Failed to mark all notifications as read");
    }
  }

  List<Widget> _buildNotificationsCardsList(
    List<notification_model.Notification> notifications,
  ) {
    final sortedNotifications = List<notification_model.Notification>.from(
      notifications,
    );
    sortedNotifications.sort((a, b) {
      if (a.isRead != b.isRead) {
        return a.isRead ? 1 : -1;
      }
      if (a.isImportant != b.isImportant) {
        return a.isImportant ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return sortedNotifications
        .map(
          (notification) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NotificationCard(
              notification: notification,
              time: _formatTime(notification.createdAt),
              onTap: () => _navigateToNotificationDetails(notification),
              onDelete: () => _deleteNotification(notification),
            ),
          ),
        )
        .toList();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
