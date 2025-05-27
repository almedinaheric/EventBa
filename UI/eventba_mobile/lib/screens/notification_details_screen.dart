import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final String title;
  final String content;
  final String time;

  const NotificationDetailsScreen({
    super.key,
    required this.title,
    required this.content,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      initialIndex: -1,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Notification Details",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Card Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFBDBDBD)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.blue,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title and Time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateTime(time),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  Container(
                    height: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),

                  const SizedBox(height: 16),

                  // Content Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Message",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          content,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons (Optional)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Delete notification functionality
                      _showDeleteConfirmation(context);
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String time) {
    // Convert relative time to a more detailed format
    // In a real app, you'd probably have actual DateTime objects
    final now = DateTime.now();

    if (time.contains('h ago')) {
      final hours = int.tryParse(time.replaceAll('h ago', '').trim()) ?? 0;
      final sentTime = now.subtract(Duration(hours: hours));
      return 'Sent on ${_formatDate(sentTime)} at ${_formatTime(sentTime)}';
    } else if (time.contains('d ago')) {
      final days = int.tryParse(time.replaceAll('d ago', '').trim()) ?? 0;
      final sentTime = now.subtract(Duration(days: days));
      return 'Sent on ${_formatDate(sentTime)} at ${_formatTime(sentTime)}';
    } else if (time.contains('min ago')) {
      final minutes = int.tryParse(time.replaceAll('min ago', '').trim()) ?? 0;
      final sentTime = now.subtract(Duration(minutes: minutes));
      return 'Sent on ${_formatDate(sentTime)} at ${_formatTime(sentTime)}';
    }

    return 'Sent $time';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content: const Text('Are you sure you want to delete this notification?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to notifications list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification deleted'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}