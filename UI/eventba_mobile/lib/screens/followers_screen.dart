import 'package:flutter/material.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final followers = [
      {"name": "John Doe", "avatar": "assets/images/profile_placeholder.png"},
      {"name": "Jane Smith", "avatar": "assets/images/profile_placeholder.png"},
      {"name": "Mike Johnson", "avatar": "assets/images/profile_placeholder.png"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Followers")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: followers.length,
        itemBuilder: (context, index) {
          final follower = followers[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(follower["avatar"]!),
              ),
              title: Text(follower["name"]!),
              trailing: ElevatedButton(
                onPressed: () {
                  // Follow back logic
                },
                child: const Text("Follow Back"),
              ),
            ),
          );
        },
      ),
    );
  }
}