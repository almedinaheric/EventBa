import 'package:flutter/material.dart';
import 'event_details_screen.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      {"title": "Music Festival", "date": "June 10, 2025"},
      {"title": "Art Expo", "date": "July 5, 2025"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("My Events")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            child: ListTile(
              title: Text(event["title"]!),
              subtitle: Text(event["date"]!),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EventDetailsScreen(eventTitle: event["title"]!),
                    ));
              },
            ),
          );
        },
      ),
    );
  }
}
