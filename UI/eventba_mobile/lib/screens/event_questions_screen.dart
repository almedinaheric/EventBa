import 'package:flutter/material.dart';

class EventQuestionsScreen extends StatelessWidget {
  const EventQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Questions")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text("Is parking available?"),
            subtitle: Text("Asked by: user123"),
          ),
          ListTile(
            title: Text("Will there be food stalls?"),
            subtitle: Text("Asked by: foodie567"),
          ),
        ],
      ),
    );
  }
}
