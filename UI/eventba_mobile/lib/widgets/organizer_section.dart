import 'package:eventba_mobile/providers/user_provider.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/widgets/user_card.dart';
import 'package:flutter/material.dart';

class OrganizerSection extends StatefulWidget {
  const OrganizerSection({
    super.key,
    this.imageUrl = 'assets/images/profile_placeholder.png',
    this.name = 'Dylan Malik',
    this.organizerId = "123",
    this.bio = '',
    this.isFollowing = false,
  });

  final String imageUrl;
  final String name;
  final String organizerId;
  final String bio;
  final bool isFollowing;

  @override
  State<OrganizerSection> createState() => _OrganizerSectionState();
}

class _OrganizerSectionState extends State<OrganizerSection> {
  late bool isFollowing;
  final UserProvider _userProvider = UserProvider();

  @override
  void initState() {
    super.initState();
    isFollowing = widget.isFollowing;
  }

  Future<void> _handleFollowUnfollow() async {
    try {
      if (isFollowing) {
        await _userProvider.unfollowUser(widget.organizerId);
      } else {
        await _userProvider.followUser(widget.organizerId);
      }

      final wasFollowing = isFollowing;
      setState(() {
        isFollowing = !isFollowing;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            !wasFollowing
                ? "Following ${widget.name}"
                : "Unfollowed ${widget.name}",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Failed to ${isFollowing ? 'unfollow' : 'follow'} user.",
          ),
        ),
      );
    }
  }

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
                onPressed: _handleFollowUnfollow,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
