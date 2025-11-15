import 'dart:convert';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/screens/user_details_screen.dart';
import 'package:eventba_admin/providers/user_provider.dart';
import 'package:eventba_admin/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _users = [];
  bool _isLoading = false;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final filter = {
        'page': 1,
        'pageSize': 10,
        'excludeAdmins': true, // Exclude admin users from the list
        if (_searchTerm.isNotEmpty) 'searchTerm': _searchTerm,
      };

      final result = await userProvider.get(filter: filter);

      setState(() {
        _users = result.result;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading users: $e");
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading users: $e')));
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchTerm = query;
    });
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Users',
      showBackButton: true,
      body: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4776E6), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search by name or email',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // 📄 User List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                  ? const Center(child: Text('No users found'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(0),
                      itemCount: _users.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.3),
                        indent: 24,
                        endIndent: 24,
                      ),
                      itemBuilder: (context, index) {
                        var user = _users[index];
                        return _buildUserCard(user);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    // Get profile image data
    String? profileImageData;
    if (user.profileImage != null && user.profileImage!.data != null) {
      profileImageData = user.profileImage!.data;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: ClipOval(
              child: profileImageData != null
                  ? Image.memory(
                      base64Decode(profileImageData.split(',').last),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.withOpacity(0.3),
                          child: const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 30,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.withOpacity(0.3),
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // See more button
          GestureDetector(
            onTap: () {
              // Navigate to UserDetailsScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailsScreen(userId: user.id),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF4776E6)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'See more',
                style: TextStyle(
                  color: Color(0xFF4776E6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
