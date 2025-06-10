import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventBa Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Handle admin profile action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard('Add Event', Icons.add, () {
              // Navigate to Add Event Screen
            }),
            _buildCard('Public Events', Icons.event, () {
              // Navigate to Public Events Screen
            }),
            _buildCard('Private Events', Icons.lock, () {
              // Navigate to Private Events Screen
            }),
            _buildCard('Users', Icons.people, () {
              // Navigate to Users Screen
            }),
            _buildCard('Notifications', Icons.notifications, () {
              // Navigate to Notifications Screen
            }),
            _buildCard('Manage Categories', Icons.category, () {
              // Navigate to Manage Categories and Tags Screen
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
