import 'package:flutter/material.dart';

class EventStatisticsScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventStatisticsScreen({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Statistics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Download statistics logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Statistics downloaded!")),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard("Total Attendees", "${eventData["attendees"]}", Icons.people),
          _buildStatCard("Tickets Sold", "180", Icons.confirmation_number),
          _buildStatCard("Revenue", "\$4,500", Icons.attach_money),
          _buildStatCard("Check-ins", "142", Icons.login),
          _buildStatCard("Average Rating", "4.5/5", Icons.star),
          _buildStatCard("Questions Asked", "8", Icons.help),

          const SizedBox(height: 16),
          const Text(
            "Attendance by Hour",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text("Chart placeholder - integrate with charts_flutter"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}