import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/widgets/user_card.dart';
import 'package:flutter/material.dart';

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({super.key});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final List<Map<String, String>> followers = [
    {"name": "John Doe", "avatar": "assets/images/profile_placeholder.png"},
    {"name": "Jane Smith", "avatar": "assets/images/profile_placeholder.png"},
    {"name": "Mike Johnson", "avatar": "assets/images/profile_placeholder.png"},
    // ... more followers
  ];

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      initialIndex: 4,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Followers",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context); // Back button functionality
      },
      child: followers.isEmpty
          ? Center(
        child: Text(
          "👀 No followers yet.",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: followers.length,
        itemBuilder: (context, index) {
          final follower = followers[index];
          return FollowerCard(
            name: follower["name"]!,
            avatar: follower["avatar"]!,
            organizerId: index + 1,
            bio: '',
          );
        },
      ),
    );
  }
}

class FollowerCard extends StatefulWidget {
  final String name;
  final String avatar;
  final int organizerId;
  final String bio;

  const FollowerCard({
    super.key,
    required this.name,
    required this.avatar,
    required this.organizerId,
    this.bio = '',
  });

  @override
  State<FollowerCard> createState() => _FollowerCardState();
}

class _FollowerCardState extends State<FollowerCard> {
  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            UserCard(
              imageUrl: widget.avatar,
              name: widget.name,
              userId: widget.organizerId,
              bio: widget.bio,
            ),
            const Spacer(),
            SizedBox(
              width: 100,
              child: PrimaryButton(
                text: isFollowing ? "Unfollow" : "Follow Back",
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
      ),
    );
  }
}
