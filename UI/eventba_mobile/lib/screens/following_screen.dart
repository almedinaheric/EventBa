import 'package:eventba_mobile/models/basic_user/basic_user.dart';
import 'package:eventba_mobile/providers/user_provider.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/widgets/user_card.dart';
import 'package:flutter/material.dart';

class FollowingScreen extends StatefulWidget {
  final List<BasicUser> following;

  const FollowingScreen({super.key, required this.following});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  late List<BasicUser> following;
  final UserProvider userProvider = UserProvider();

  @override
  void initState() {
    super.initState();
    following = List.from(widget.following);
  }

  Future<void> _handleUnfollow(String userId) async {
    try {
      final success = await userProvider.unfollowUser(userId);
      if (success) {
        setState(() {
          following.removeWhere((user) => user.id == userId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unfollowed successfully')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to unfollow: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      initialIndex: 4,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Following",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () => Navigator.pop(context),
      child: following.isEmpty
          ? Center(
              child: Text(
                "👀 No followings yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: following.length,
              itemBuilder: (context, index) {
                final user = following[index];
                return FollowerCard(
                  name: user.fullName,
                  avatar: user.profileImage?.data ?? '',
                  organizerId: user.id,
                  onUnfollow: () async {
                    await _handleUnfollow(user.id);
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
  final String organizerId;
  final String bio;
  final Future<void> Function() onUnfollow;

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
  bool isFollowing = true;
  bool isLoading = false;

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
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : PrimaryButton(
                      text: "Unfollow",
                      outlined: true,
                      small: true,
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await widget.onUnfollow();
                        setState(() {
                          isLoading = false;
                          isFollowing = false;
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
