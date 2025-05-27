import 'package:eventba_mobile/screens/followers_screen.dart';
import 'package:eventba_mobile/screens/following_screen.dart';
import 'package:eventba_mobile/screens/my_events_screen.dart';
import 'package:eventba_mobile/screens/support_screen.dart';
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
            // Profile Picture and Name
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
            ),
            const SizedBox(height: 16),
            const Text(
              "Dylan Malik",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(context, "20", "Followers", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FollowersScreen()));
                }),
                _buildStatColumn(context, "10", "Following", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FollowingScreen()));
                }),
                _buildStatColumn(context, "10", "Events", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MyEventsScreen()));
                }),
              ],
            ),
            const SizedBox(height: 32),

            // About Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s...",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Show full bio
                    },
                    child: const Text("Read more..."),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            _buildTile(context, "Edit Profile Details", Icons.person, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileDetailsScreen()));
            }),
            _buildTile(context, "My Events", Icons.event, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyEventsScreen()));
            }),
            _buildTile(context, "Support / Ask Question", Icons.support_agent, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SupportScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String number, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
