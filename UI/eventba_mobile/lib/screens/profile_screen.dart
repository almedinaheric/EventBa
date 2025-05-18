import 'package:eventba_mobile/screens/my_events_screen.dart';
import 'package:flutter/material.dart';
import 'profile_details_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage:
                  AssetImage('assets/images/profile_placeholder.png'),
            ),
            const SizedBox(height: 12),
            const Text(
              "Dylan Malik",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTile(context, "Edit Profile Details", Icons.person, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProfileDetailsScreen()));
            }),
            _buildTile(context, "My Events", Icons.event, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyEventsScreen()));
            }),
            _buildTile(context, "Support / Ask Question", Icons.support_agent,
                () {
              // Placeholder - add support screen later
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
