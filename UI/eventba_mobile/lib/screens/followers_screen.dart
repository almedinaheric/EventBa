import 'package:eventba_mobile/models/basic_user/basic_user.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:eventba_mobile/providers/user_provider.dart';

class FollowersScreen extends StatefulWidget {
  final List<BasicUser> followers;

  const FollowersScreen({super.key, required this.followers});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  late List<BasicUser> followers;
  final UserProvider _userProvider = UserProvider();
  final Map<String, bool> _isFollowingMap = {};
  final Map<String, String?> _profileImages = {};
  bool _isLoadingFollowingStatus = true;

  @override
  void initState() {
    super.initState();
    followers = widget.followers;
    _loadFollowingStatus();
    for (var user in followers) {
      if (user.profileImage?.data != null) {
        _profileImages[user.id] = user.profileImage!.data;
      } else {
        _loadUserProfileImage(user.id);
      }
    }
  }

  Future<void> _loadFollowingStatus() async {
    try {
      final currentUser = await _userProvider.getProfile();
      final followingIds = currentUser.following.map((user) => user.id).toSet();

      setState(() {
        for (var follower in followers) {
          _isFollowingMap[follower.id] = followingIds.contains(follower.id);
        }
        _isLoadingFollowingStatus = false;
      });
    } catch (e) {
      setState(() {
        for (var user in followers) {
          _isFollowingMap[user.id] = false;
        }
        _isLoadingFollowingStatus = false;
      });
    }
  }

  Future<void> _loadUserProfileImage(String userId) async {
    try {
      final user = await _userProvider.getById(userId);
      if (user.profileImage?.data != null) {
        setState(() {
          _profileImages[userId] = user.profileImage!.data;
        });
      }
    } catch (e) {}
  }

  void _toggleFollow(String userId) async {
    try {
      bool isCurrentlyFollowing = _isFollowingMap[userId] ?? false;

      if (isCurrentlyFollowing) {
        await _userProvider.unfollowUser(userId);
      } else {
        await _userProvider.followUser(userId);
      }

      setState(() {
        _isFollowingMap[userId] = !isCurrentlyFollowing;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Failed to update follow status"),
        ),
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
      child: _isLoadingFollowingStatus
          ? const Center(child: CircularProgressIndicator())
          : followers.isEmpty
          ? Center(
              child: Text(
                "👀 No followers yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
                  avatar:
                      _profileImages[follower.id] ??
                      follower.profileImage?.data,
                  organizerId: follower.id,
                  isFollowing: isFollowing,
                  onFollowToggle: () => _toggleFollow(follower.id),
                );
              },
            ),
    );
  }
}

class FollowerCard extends StatefulWidget {
  final String name;
  final String? avatar;
  final String organizerId;
  final String bio;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  const FollowerCard({
    super.key,
    required this.name,
    this.avatar,
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
