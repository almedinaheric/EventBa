import 'dart:io' show File, Platform;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:eventba_mobile/providers/user_provider.dart';
import 'package:eventba_mobile/providers/event_image_provider.dart';
import 'package:eventba_mobile/models/user/user.dart';
import 'package:eventba_mobile/utils/authorization.dart';
import 'package:eventba_mobile/utils/image_helpers.dart';
import 'package:eventba_mobile/screens/profile_details_screen.dart';
import 'package:eventba_mobile/screens/my_events_screen.dart';
import 'package:eventba_mobile/screens/followers_screen.dart';
import 'package:eventba_mobile/screens/following_screen.dart';
import 'package:eventba_mobile/screens/support_screen.dart';
import 'package:eventba_mobile/screens/welcome_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  User? _user;
  bool _isLoading = true;
  int _eventsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<Map<String, dynamic>> _fetchEventsCount() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final url = "${userProvider.baseUrl}Event/my-events-count";
    final uri = Uri.parse(url);
    final headers = userProvider.createHeaders();

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch events count");
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = await userProvider.getProfile();

      // Debug: Check profile image
      print("=== PROFILE IMAGE DEBUG ===");
      print("Profile image: ${user.profileImage != null ? 'exists' : 'null'}");
      if (user.profileImage != null) {
        print("Profile image ID: ${user.profileImage!.id}");
        print(
          "Profile image data: ${user.profileImage!.data != null ? 'exists (${user.profileImage!.data!.length} chars)' : 'null'}",
        );
        print("Profile image contentType: ${user.profileImage!.contentType}");
      }
      print("=== END DEBUG ===");

      // Fetch events count
      int eventsCount = 0;
      try {
        final response = await _fetchEventsCount();
        if (response['count'] != null) {
          eventsCount = response['count'];
        }
      } catch (e) {
        print("Failed to load events count: $e");
      }

      setState(() {
        _user = user;
        _eventsCount = eventsCount;
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to load user profile: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    if (!mounted) return;

    try {
      // Use a small delay to ensure the UI is ready, especially on iOS
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      // iOS-specific optimizations
      final bool isIOS = !kIsWeb && Platform.isIOS;

      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: isIOS
            ? 60
            : 70, // Lower quality for iOS to prevent crashes
        maxWidth: isIOS ? 1000 : 1200, // Smaller size for iOS
        maxHeight: isIOS ? 1000 : 1200,
        requestFullMetadata:
            false, // Disable metadata to improve performance on iOS
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _image = File(pickedFile.path);
        });

        // Upload the image
        await _uploadProfileImage(_image!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Failed to pick image: $e'),
          ),
        );
      }
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      final imageProvider = Provider.of<EventImageProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Convert image to base64
      final base64Image = await ImageHelpers.fileToBase64(imageFile);
      final contentType = ImageHelpers.getContentType(imageFile.path);

      // Upload image
      final imageRequest = {
        'Data': base64Image,
        'ContentType': contentType,
        'ImageType': 'ProfileImage',
      };

      final imageResponse = await imageProvider.insert(imageRequest);

      // Check if imageResponse and id are valid
      if (imageResponse.id == null || imageResponse.id!.isEmpty) {
        print("Image response: ${imageResponse.toString()}");
        print("Image response ID: ${imageResponse.id}");
        throw Exception(
          'Image upload failed: No image ID returned from server',
        );
      }

      final imageId = imageResponse.id!;
      print("Image uploaded successfully with ID: $imageId");

      // Update user profile with new image ID
      final updateUrl = "${userProvider.baseUrl}User/${_user!.id}";
      final updateUri = Uri.parse(updateUrl);
      final headers = userProvider.createHeaders();

      final updateRequest = {
        'id': _user!.id,
        'firstName': _user!.firstName,
        'lastName': _user!.lastName,
        'email': _user!.email,
        'phoneNumber': _user!.phoneNumber ?? '',
        'bio': _user!.bio ?? '',
        'profileImageId': imageId,
      };

      final updateResponse = await http.put(
        updateUri,
        headers: headers,
        body: jsonEncode(updateRequest),
      );

      if (updateResponse.statusCode >= 200 && updateResponse.statusCode < 300) {
        // Reload user profile to get updated image
        await _loadUserProfile();

        // Clear local image so database image is displayed
        if (mounted) {
          setState(() {
            _image = null;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Profile image updated successfully!'),
            ),
          );
        }
      } else {
        throw Exception('Failed to update profile image');
      }
    } catch (e) {
      print("Error uploading profile image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Failed to upload profile image: $e'),
          ),
        );
      }
      // Reset image on error
      setState(() {
        _image = null;
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return AlertDialog(
          title: const Text(
            "Log Out",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    text: "Cancel",
                    width: size.width * 0.3,
                    outlined: false,
                    small: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    text: "Log Out",
                    width: size.width * 0.3,
                    outlined: true,
                    small: true,
                    onPressed: () {
                      // Close dialog first
                      Navigator.pop(context);

                      // Clear authentication credentials
                      Authorization.email = null;
                      Authorization.password = null;

                      // Clear user data from provider
                      try {
                        Provider.of<UserProvider>(
                          context,
                          listen: false,
                        ).clearUser();
                      } catch (e) {
                        print('Error clearing user provider: $e');
                      }

                      // Navigate to welcome screen and clear navigation stack
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userName =
        _user?.fullName ?? "${_user!.firstName} ${_user!.lastName}".trim();
    final followersCount = _user?.followers.length ?? 0;
    final followingCount = _user?.following.length ?? 0;
    final eventsCount = _eventsCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar and name
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    child: _image != null
                        ? ClipOval(
                            child: Image.file(
                              _image!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipOval(
                            child: ImageHelpers.getProfileImage(
                              _user?.profileImage?.data,
                              height: 120,
                              width: 120,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4776E6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF363B3E),
              ),
            ),
            const SizedBox(height: 24),

            // Followers / Following / Events
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  context,
                  followersCount.toString(),
                  "Followers",
                  () async {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            FollowersScreen(followers: _user?.followers ?? []),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    // Reload profile when returning from followers screen
                    if (mounted) {
                      await _loadUserProfile();
                    }
                  },
                ),
                _buildStatColumn(
                  context,
                  followingCount.toString(),
                  "Following",
                  () async {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            FollowingScreen(following: _user?.following ?? []),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    // Reload profile when returning from following screen
                    if (mounted) {
                      await _loadUserProfile();
                    }
                  },
                ),
                _buildStatColumn(context, eventsCount.toString(), "Events", () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const MyEventsScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 32),

            // Profile actions
            _buildSectionCard(context, "Account", [
              _buildListTile(
                context,
                "Edit Profile Details",
                Icons.person,
                () async {
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const ProfileDetailsScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                  // Reload profile when returning from edit profile screen
                  if (mounted) {
                    await _loadUserProfile();
                  }
                },
              ),
              _buildListTile(context, "My Events", Icons.event, () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const MyEventsScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }),
            ]),
            const SizedBox(height: 16),

            _buildSectionCard(context, "Help", [
              _buildListTile(context, "Support", Icons.support_agent, () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const SupportScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }),
            ]),
            const SizedBox(height: 16),

            // Logout section
            _buildSectionCard(context, "Logout", [
              _buildListTile(context, "Log Out", Icons.logout, _logout),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String number,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4776E6),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4776E6)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
