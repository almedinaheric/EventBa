import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/screens/notification_details_screen.dart';
import 'package:eventba_admin/models/notification/notification.dart' as model;
import 'package:eventba_admin/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<model.Notification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      final notifications = await provider.getSystemNotifications();

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Sent Notifications',
      showBackButton: true,
      body: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4776E6), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            : _notifications.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No notifications found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: ListView.separated(
                  padding: const EdgeInsets.all(0),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.withOpacity(0.3),
                    indent: 24,
                    endIndent: 24,
                  ),
                  itemBuilder: (context, index) {
                    var notification = _notifications[index];
                    return _buildNotificationCard(notification);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildNotificationCard(model.Notification notification) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: notification.isImportant
                  ? Colors.orange
                  : const Color(0xFF4776E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (notification.isImportant)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Important',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(notification.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationDetailsScreen(notification: notification),
                ),
              );
              _loadNotifications();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF4776E6)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'See more',
                style: TextStyle(
                  color: Color(0xFF4776E6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}min ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTimeString;
    }
  }
}
