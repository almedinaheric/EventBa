import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/screens/user_details_screen.dart'; // Add this import
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  // All users (original list)
  final List<Map<String, dynamic>> allUsers = [
    {
      'name': 'Dylan Malik',
      'email': 'dylan.malik@email.com',
      'avatar': 'assets/images/profile_placeholder.png',
      'id': '1',
    },
    {
      'name': 'Sarah Johnson',
      'email': 'sarah.johnson@email.com',
      'avatar': 'assets/images/profile_placeholder.png',
      'id': '2',
    },
    {
      'name': 'Mike Wilson',
      'email': 'mike.wilson@email.com',
      'avatar': 'assets/images/profile_placeholder.png',
      'id': '3',
    },
    {
      'name': 'Emily Davis',
      'email': 'emily.davis@email.com',
      'avatar': 'assets/images/profile_placeholder.png',
      'id': '4',
    },
  ];

  // This will be updated when user searches
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = List.from(allUsers);
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = allUsers.where((user) {
        final name = user['name'].toLowerCase();
        final email = user['email'].toLowerCase();
        return name.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
      }).toList();
    });
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
                onChanged: _filterUsers,
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
              child: filteredUsers.isEmpty
                  ? const Center(child: Text('No users found'))
                  : ListView.separated(
                padding: const EdgeInsets.all(0),
                itemCount: filteredUsers.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.withOpacity(0.3),
                  indent: 24,
                  endIndent: 24,
                ),
                itemBuilder: (context, index) {
                  var user = filteredUsers[index];
                  return _buildUserCard(
                    name: user['name'],
                    email: user['email'],
                    avatar: user['avatar'],
                    userId: user['id'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String email,
    required String avatar,
    required String userId,
  }) {
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
              child: Image.asset(
                avatar,
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
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
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
                  builder: (context) => UserDetailsScreen(
                    userId: userId,
                    name: name,
                    email: email,
                    avatar: avatar,
                  ),
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