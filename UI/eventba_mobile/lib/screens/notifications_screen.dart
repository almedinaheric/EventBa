import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/notification_card.dart'; // Make sure this file is correct

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      initialIndex: -1,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Notifications",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._buildNotificationsCardsList(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  List<Widget> _buildNotificationsCardsList() {
    // Sample/mock data
    final notifications = [
      {
        'title': 'Event Update',
        'content':
            'The concert location has changed to the main hall due to weather.',
        'time': '2h ago',
      },
      {
        'title': 'Reminder',
        'content': 'Don’t forget your event starts tomorrow at 6 PM.',
        'time': '1d ago',
      },
      {
        'title': 'New Event Nearby',
        'content':
            'Check out this music event happening just around the corner!',
        'time': '3d ago',
      },
      {
        'title': 'Event Update',
        'content':
            'The concert location has changed to the main hall due to weather.',
        'time': '2h ago',
      },
      {
        'title': 'Reminder',
        'content': 'Don’t forget your event starts tomorrow at 6 PM.',
        'time': '1d ago',
      },
      {
        'title': 'New Event Nearby',
        'content':
            'Check out this music event happening just around the corner!',
        'time': '3d ago',
      },
      {
        'title': 'Event Update',
        'content':
            'The concert location has changed to the main hall due to weather.',
        'time': '2h ago',
      },
      {
        'title': 'Reminder',
        'content': 'Don’t forget your event starts tomorrow at 6 PM.',
        'time': '1d ago',
      },
      {
        'title': 'New Event Nearby',
        'content':
            'Check out this music event happening just around the corner!',
        'time': '3d ago',
      },
      {
        'title': 'Event Update',
        'content':
            'The concert location has changed to the main hall due to weather.',
        'time': '2h ago',
      },
      {
        'title': 'Reminder',
        'content': 'Don’t forget your event starts tomorrow at 6 PM.',
        'time': '1d ago',
      },
      {
        'title': 'New Event Nearby',
        'content':
            'Check out this music event happening just around the corner!',
        'time': '3d ago',
      },
    ];

    return notifications
        .map((notification) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NotificationCard(
                title: notification['title']!,
                content: notification['content']!,
                time: notification['time']!,
              ),
            ))
        .toList();
  }
}
