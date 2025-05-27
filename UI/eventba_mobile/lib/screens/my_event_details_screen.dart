import 'package:eventba_mobile/screens/event_questions_screen.dart';
import 'package:eventba_mobile/screens/event_reviews_screen.dart';
import 'package:eventba_mobile/screens/event_statistics_screen.dart';
import 'package:eventba_mobile/screens/ticket_scanner_screen.dart';
import 'package:flutter/material.dart';

class MyEventDetailsScreen extends StatelessWidget {
  final String eventTitle;
  final Map<String, dynamic> eventData;

  const MyEventDetailsScreen({
    super.key,
    required this.eventTitle,
    required this.eventData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eventTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventTitle,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(eventData["date"] ?? ""),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 8),
                      Text(eventData["location"] ?? ""),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 8),
                      Text("${eventData["attendees"]} attendees"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildActionButton(
                context,
                "Scan Tickets",
                Icons.qr_code_scanner,
                Colors.blue,
                    () => Navigator.pushNamed(context, '/ticket-scanner'),
              ),
              _buildActionButton(
                context,
                "Edit Event",
                Icons.edit,
                Colors.orange,
                    () => Navigator.pushNamed(context, '/edit-event'),
              ),
              _buildActionButton(
                context,
                "Questions",
                Icons.question_answer,
                Colors.green,
                    () => Navigator.pushNamed(context, '/event-questions'),
              ),
              _buildActionButton(
                context,
                "Statistics",
                Icons.analytics,
                Colors.purple,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventStatisticsScreen(eventData: eventData),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reviews Section (if event is finished)
          if (eventData["status"] == "finished")
            Card(
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text("Reviews & Feedback"),
                subtitle: const Text("4.5 stars (23 reviews)"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventReviewsScreen(eventTitle: eventTitle),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
