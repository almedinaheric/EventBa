import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/screens/organizer_profile_screen.dart';
import 'package:eventba_mobile/widgets/user_card.dart';
import 'package:flutter/material.dart';

class OrganizerSection extends StatefulWidget {
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
            UserCard(
              imageUrl: widget.imageUrl,
              name: widget.name,
              userId: widget.organizerId,
              bio: widget.bio,
            ),

            const Spacer(),

            SizedBox(
              width: 100,
              child: PrimaryButton(
                text: isFollowing ? "Unfollow" : "Follow",
                outlined: isFollowing,
                small: true,
                onPressed: () {
                  setState(() {
                    isFollowing = !isFollowing;
                  });
                  // Add API call for follow/unfollow here
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
