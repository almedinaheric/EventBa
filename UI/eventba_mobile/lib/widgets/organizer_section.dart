import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/screens/organizer_profile_screen.dart';
import 'package:flutter/material.dart';

class OrganizerSection extends StatefulWidget {
  // You can optionally pass organizer data here if needed
  const OrganizerSection({
    super.key,
    this.imageUrl = 'assets/images/profile_placeholder.png',
    this.name = 'Dylan Malik',
    this.organizerId = 1,
    this.bio = '',
  });

  final String imageUrl;
  final String name;
  final int organizerId;
  final String bio;

  @override
  State<OrganizerSection> createState() => _OrganizerSectionState();
}

class _OrganizerSectionState extends State<OrganizerSection> {
  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Organized by",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Use OrganizerCard widget here for avatar + name + navigation
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrganizerProfileScreen(
                      organizerId: widget.organizerId,
                      name: widget.name,
                      avatarUrl: widget.imageUrl,
                      bio: widget.bio,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(widget.imageUrl),
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4776E6),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: 100, // Fixed width for the button
              child: PrimaryButton(
                text: isFollowing ? "Unfollow" : "Follow",
                outlined: isFollowing,
                small: true,
                onPressed: () {
                  setState(() {
                    isFollowing = !isFollowing;
                  });
                  // Call API to follow/unfollow here if needed
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
