import 'package:eventba_mobile/screens/event_questions_screen.dart';
import 'package:eventba_mobile/screens/ticket_scanner_screen.dart';
import 'package:flutter/material.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventTitle;

  const EventDetailsScreen({super.key, required this.eventTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eventTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Event Details:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Date: June 10, 2025"),
          const Text("Location: Main Hall, City Center"),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text("Scan Tickets"),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TicketScannerScreen()));
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.question_answer),
            label: const Text("View Questions"),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EventQuestionsScreen()));
            },
          ),
        ],
      ),
    );
  }
}
