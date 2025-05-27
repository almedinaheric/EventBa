import 'package:flutter/material.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final following = [
      {"name": "Alice Brown", "avatar": "assets/images/profile_placeholder.png"},
      {"name": "Bob Wilson", "avatar": "assets/images/profile_placeholder.png"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Following")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: following.length,
        itemBuilder: (context, index) {
          final person = following[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(person["avatar"]!),
              ),
              title: Text(person["name"]!),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  // Unfollow logic
                },
                child: const Text("Unfollow"),
              ),
            ),
          );
        },
      ),
    );
  }
}