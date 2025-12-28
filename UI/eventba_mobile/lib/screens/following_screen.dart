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
  final Map<String, String?> _profileImages = {};
  bool _isLoadingImages = false;
  int _loadingImagesCount = 0;

  @override
  void initState() {
    super.initState();
    following = List.from(widget.following);
    int imagesToLoad = 0;
    for (var user in following) {
      if (user.profileImage?.data != null) {
        _profileImages[user.id] = user.profileImage!.data;
      } else {
        imagesToLoad++;
      }
    }

    if (imagesToLoad > 0) {
      setState(() {
        _isLoadingImages = true;
        _loadingImagesCount = imagesToLoad;
      });

      for (var user in following) {
        if (user.profileImage?.data == null) {
          _loadUserProfileImage(user.id);
        }
      }
    }
  }

  Future<void> _loadUserProfileImage(String userId) async {
    try {
      final user = await userProvider.getById(userId);
      if (user.profileImage?.data != null) {
        setState(() {
          _profileImages[userId] = user.profileImage!.data;
          _loadingImagesCount--;
          if (_loadingImagesCount <= 0) {
            _isLoadingImages = false;
          }
        });
      } else {
        setState(() {
          _loadingImagesCount--;
          if (_loadingImagesCount <= 0) {
            _isLoadingImages = false;
          }
        });
      }
    } catch (e) {
      setState(() {
        _loadingImagesCount--;
        if (_loadingImagesCount <= 0) {
          _isLoadingImages = false;
        }
      });
    }
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
      child: _isLoadingImages
          ? const Center(child: CircularProgressIndicator())
          : following.isEmpty
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
                  avatar: _profileImages[user.id] ?? user.profileImage?.data,
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
  final String? avatar;
  final String organizerId;
  final String bio;
  final Future<void> Function() onUnfollow;

  const FollowerCard({
    super.key,
    required this.name,
    this.avatar,
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
