import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/screens/notification_details_screen.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int selectedIndex = 0; // 0 = Received, 1 = Sent

  final List<Map<String, String>> receivedNotifications = [
    {
      'title': 'Notification 1',
      'content': 'Lorem ipsum lorem...',
      'time': '1h ago',
    },
    {
      'title': 'Notification 1',
      'content': 'Lorem ipsum lorem...',
      'time': '1h ago',
    },
    {
      'title': 'Notification 1',
      'content': 'Lorem ipsum lorem...',
      'time': '1h ago',
    },
    {
      'title': 'Notification 1',
      'content': 'Lorem ipsum lorem...',
      'time': '1h ago',
    },
    {
      'title': 'Notification 1',
      'content': 'Lorem ipsum lorem...',
      'time': '1h ago',
    },
  ];

  final List<Map<String, String>> sentNotifications = [
    {
      'title': 'Notification 1',
      'content': 'Lorem ipsum lorem...',
      'time': '1h ago',
    },
    {
      'title': 'Notification 1',
      'content': 'Lorem ipsum lorem...',
      'time': '1h ago',
    },
    {
      'title': 'Notification 1',
      'content': 'Lorem ipsum lorem...',
      'time': '1h ago',
    },
    {
      'title': 'Notification 1',
      'content': 'Lorem ipsum lorem...',
      'time': '1h ago',
    },
    {
      'title': 'Notification 1',
      'content': 'Lorem ipsum lorem...',
      'time': '1h ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Notifications',
      showBackButton: true,
      body: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4776E6), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Custom toggle buttons (Received / Sent)
            Container(
              margin: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Received button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = 0;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedIndex == 0
                              ? const Color(0xFF4776E6)
                              : Colors.transparent,
                          border: Border.all(color: const Color(0xFF4776E6)),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          "Received",
                          style: TextStyle(
                            color: selectedIndex == 0
                                ? Colors.white
                                : const Color(0xFF4776E6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Sent button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = 1;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedIndex == 1
                              ? const Color(0xFF4776E6)
                              : Colors.transparent,
                          border: Border.all(color: const Color(0xFF4776E6)),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          "Sent",
                          style: TextStyle(
                            color: selectedIndex == 1
                                ? Colors.white
                                : const Color(0xFF4776E6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Notifications List
            Expanded(
              child: _buildNotificationsList(
                notifications: selectedIndex == 0 ? receivedNotifications : sentNotifications,
                isReceived: selectedIndex == 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList({
    required List<Map<String, String>> notifications,
    required bool isReceived,
  }) {
    return ListView.separated(
      padding: const EdgeInsets.all(0),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey.withOpacity(0.3),
        indent: 24,
        endIndent: 24,
      ),
      itemBuilder: (context, index) {
        var notification = notifications[index];
        return _buildNotificationCard(
          title: notification['title']!,
          content: notification['content']!,
          time: notification['time']!,
          isReceived: isReceived,
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String content,
    required String time,
    required bool isReceived,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Notification icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isReceived
                  ? const Color(0xFFE91E63).withOpacity(0.8)
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

          // Notification info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // See more button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationDetailsScreen(
                    title: title,
                    content: content,
                    time: time,
                    isReceived: isReceived,
                  ),
                ),
              );
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
}