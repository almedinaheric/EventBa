import 'package:eventba_admin/screens/organizer_profile_screen.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final int userId;
  final String bio;

  const UserCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.userId,
    this.bio = '',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                OrganizerProfileScreen(
                  userId: userId,
                  name: name,
                  avatarUrl: imageUrl,
                  bio: bio,
                ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(imageUrl),
            radius: 24,
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4776E6),
            ),
          ),
        ],
      ),
    );
  }
}