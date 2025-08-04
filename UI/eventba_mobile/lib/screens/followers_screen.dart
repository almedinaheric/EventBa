import 'package:eventba_mobile/models/basic_user/basic_user.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:eventba_mobile/providers/user_provider.dart'; // Import your provider

class FollowersScreen extends StatefulWidget {
  final List<BasicUser> followers;

  const FollowersScreen({super.key, required this.followers});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  late List<BasicUser> followers;
  final UserProvider _userProvider = UserProvider();
  // To keep track of which user is followed/unfollowed
  final Map<String, bool> _isFollowingMap = {};

  @override
  void initState() {
    super.initState();
    followers = widget.followers;
    // TODO: handle this !!!
    // For now i will assume no followers are followed
    for (var user in followers) {
      _isFollowingMap[user.id] = false;
    }
  }

  void _toggleFollow(String userId) async {
    try {
      bool isCurrentlyFollowing = _isFollowingMap[userId] ?? false;

      if (isCurrentlyFollowing) {
        await _userProvider.unfollowUser(userId.toString());
      } else {
        await _userProvider.followUser(userId.toString());
      }

      setState(() {
        _isFollowingMap[userId] = !isCurrentlyFollowing;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating, content: Text("Failed to update follow status")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      initialIndex: 4,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Followers",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () => Navigator.pop(context),
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
          final isFollowing = _isFollowingMap[follower.id] ?? false;
          return FollowerCard(
            name: follower.fullName,
            avatar: follower.profileImage != null
                ? follower.profileImage!.data
                : 'assets/images/profile_placeholder.png',
            organizerId: follower.id.toString(),
            isFollowing: isFollowing,
            onFollowToggle: () => _toggleFollow(follower!.id),
          );
        },
      ),
    );
  }
}

class FollowerCard extends StatefulWidget {
  final String name;
  final String avatar;
  final String organizerId;
  final String bio;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  const FollowerCard({
    super.key,
    required this.name,
    required this.avatar,
    required this.organizerId,
    this.bio = '',
    required this.isFollowing,
    required this.onFollowToggle,
  });

  @override
  State<FollowerCard> createState() => _FollowerCardState();
}

class _FollowerCardState extends State<FollowerCard> {
  late bool isFollowing;

  @override
  void initState() {
    super.initState();
    isFollowing = widget.isFollowing;
  }

  @override
  void didUpdateWidget(covariant FollowerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFollowing != widget.isFollowing) {
      setState(() {
        isFollowing = widget.isFollowing;
      });
    }
  }

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
                  widget.onFollowToggle();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
