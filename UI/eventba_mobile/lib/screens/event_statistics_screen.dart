import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';

class EventStatisticsScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventStatisticsScreen({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Event Statistics",
      initialIndex: 4,
      appBarType: AppBarType.iconsSideTitleCenter,
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStatCard("Total Attendees", "${eventData["attendees"] ?? '0'}", Icons.people),
          _buildStatCard("Tickets Sold", "${eventData["ticketsSold"] ?? '0'}", Icons.confirmation_number),
          _buildStatCard("Revenue", "\$${eventData["revenue"] ?? '0'}", Icons.attach_money),
          _buildStatCard("Check-ins", "${eventData["checkIns"] ?? '0'}", Icons.login),
          _buildStatCard("Average Rating", "${eventData["averageRating"] ?? 'N/A'}", Icons.star),
          _buildStatCard("Questions Asked", "${eventData["questionsAsked"] ?? '0'}", Icons.help),

          const SizedBox(height: 24),

        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.blue),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
