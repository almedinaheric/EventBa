import 'package:eventba_admin/models/user/user.dart';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/widgets/primary_button.dart';
import 'package:eventba_admin/widgets/user_card.dart';
import 'package:flutter/material.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  List<Map<String, String>> following = [
    {"name": "John Doe", "avatar": "assets/images/profile_placeholder.png"},
    {"name": "Jane Smith", "avatar": "assets/images/profile_placeholder.png"},
    {"name": "Mike Johnson", "avatar": "assets/images/profile_placeholder.png"},
    // ... more Following
  ];

  void _unfollowUser(int index) async {
    final removedUser = following[index];

    // 1. Optionally call API to unfollow
    // Example:
    // await api.unfollowUser(removedUserId);

    // 2. Remove user from the list and update UI
    setState(() {
      following.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      initialIndex: 4,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Following",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context); // Back button functionality
      },
      child: following.isEmpty
          ? Center(
        child: Text(
          "👀 No followings yet.",
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
        itemCount: following.length,
        itemBuilder: (context, index) {
          final follower = following[index];
          return FollowerCard(
            name: follower["name"]!,
            avatar: follower["avatar"]!,
            organizerId: index + 1, // dummy id for example
            bio: '',
            onUnfollow: () {
              _unfollowUser(index);
            },
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
  final VoidCallback onUnfollow;  // callback for unfollow action

  const FollowerCard({
    super.key,
    required this.name,
    required this.avatar,
    required this.organizerId,
    this.bio = '',
    required this.onUnfollow,
  });

  @override
  State<FollowerCard> createState() => _FollowerCardState();
}

class _FollowerCardState extends State<FollowerCard> {
  bool isFollowing = true; // start as following

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
                text: "Unfollow",
                outlined: true,
                small: true,
                onPressed: () {
                  setState(() {
                    isFollowing = false;
                  });
                  widget.onUnfollow();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

