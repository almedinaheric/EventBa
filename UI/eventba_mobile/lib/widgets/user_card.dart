import 'package:eventba_mobile/screens/organizer_profile_screen.dart';
import 'package:eventba_mobile/utils/image_helpers.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String userId;
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
            pageBuilder: (_, __, ___) => OrganizerProfileScreen(
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
            radius: 24,
            backgroundColor: Colors.grey[300],
            child: ClipOval(
              child: imageUrl.startsWith('assets/')
                  ? Image.asset(
                      imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return ImageHelpers.getProfileImage(
                          null,
                          height: 48,
                          width: 48,
                        );
                      },
                    )
                  : ImageHelpers.getProfileImage(
                      imageUrl.startsWith('data:image')
                          ? imageUrl.split(',').last
                          : imageUrl,
                      height: 48,
                      width: 48,
                    ),
            ),
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
