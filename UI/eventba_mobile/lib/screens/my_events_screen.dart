import 'package:flutter/material.dart';
import 'my_event_details_screen.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      {
        "title": "Music Festival",
        "date": "June 10, 2025",
        "location": "Main Hall, City Center",
        "status": "upcoming",
        "attendees": 150,
      },
      {
        "title": "Art Expo",
        "date": "July 5, 2025",
        "location": "Art Gallery Downtown",
        "status": "upcoming",
        "attendees": 75,
      },
      {
        "title": "Tech Conference",
        "date": "May 1, 2025",
        "location": "Convention Center",
        "status": "finished",
        "attendees": 200,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("My Events")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(event["title"]! as String),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event["date"]! as String),
                  Text(event["location"]! as String),
                  Text("${event["attendees"]} attendees"),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: event["status"] == "upcoming" ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event["status"]! as String,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyEventDetailsScreen(
                      eventTitle: event["title"]! as String,
                      eventData: event,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

