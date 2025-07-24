import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/screens/event_details_screen.dart'; // Add this import
import 'package:flutter/material.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;
  final String avatar;

  const UserDetailsScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.avatar,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  int selectedIndex = 0; // 0 = Upcoming, 1 = Past

  // Sample user phone - in real app this would come from API
  final String userPhone = "+387 61 123 456";

  // Sample events data - in real app this would come from API
  final List<Map<String, dynamic>> upcomingEvents = [
    {
      'id': '1',
      'name': 'Tech Meetup 2025',
      'location': 'Downtown Hall',
      'date': '2025-07-30',
      'category': 'Technology',
      'isPaid': false,
      'price': 'Free',
      'image': 'assets/images/default_event_cover_image.png',
    },
    {
      'id': '2',
      'name': 'Summer Music Festival',
      'location': 'City Park',
      'date': '2025-08-15',
      'category': 'Music',
      'isPaid': true,
      'price': '25KM',
      'image': 'assets/images/default_event_cover_image.png',
    },
  ];

  final List<Map<String, dynamic>> pastEvents = [
    {
      'id': '3',
      'name': 'Spring Fest 2024',
      'location': 'Central Park',
      'date': '2024-04-20',
      'category': 'Festival',
      'isPaid': true,
      'price': '15KM',
      'image': 'assets/images/default_event_cover_image.png',
    },
    {
      'id': '4',
      'name': 'Art Exhibition',
      'location': 'Gallery Center',
      'date': '2024-03-10',
      'category': 'Art',
      'isPaid': false,
      'price': 'Free',
      'image': 'assets/images/default_event_cover_image.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'User Details',
      showBackButton: true,
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          children: [
            // User Profile Section
            _buildUserProfile(),

            const SizedBox(height: 32),

            // User Events Section
            _buildEventsSection(),

            const SizedBox(height: 16),

            // Toggle buttons
            _buildToggleButtons(),

            const SizedBox(height: 16),

            // Events List
            Expanded(
              child: _buildEventsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4776E6), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                widget.avatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.withOpacity(0.3),
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // User Name
          Text(
            widget.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 24),

          // User Details
          Row(
            children: [
              Expanded(
                child: _buildUserDetailItem(
                  icon: Icons.email,
                  label: 'Email',
                  value: widget.email,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserDetailItem(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: userPhone,
                ),
              ),
            ],
          ),


        ],
      ),
    );
  }

  Widget _buildUserDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteUserButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _showDeleteUserDialog,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Delete User',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showDeleteUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text('Are you sure you want to delete ${widget.name}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User ${widget.name} deleted successfully')),
                );
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  Widget _buildEventsSection() {
    return Row(
      children: [
        const Text(
          "User Events",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        Text(
          "Total: ${upcomingEvents.length + pastEvents.length}",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF4776E6)),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedIndex = 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectedIndex == 0
                    ? const Color(0xFF4776E6)
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
              ),
              child: Text(
                "Upcoming (${upcomingEvents.length})",
                style: TextStyle(
                  color: selectedIndex == 0
                      ? Colors.white
                      : const Color(0xFF4776E6),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedIndex = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectedIndex == 1
                    ? const Color(0xFF4776E6)
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Text(
                "Past (${pastEvents.length})",
                style: TextStyle(
                  color: selectedIndex == 1
                      ? Colors.white
                      : const Color(0xFF4776E6),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildEventsList() {
  final currentEvents = selectedIndex == 0 ? upcomingEvents : pastEvents;

  if (currentEvents.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            selectedIndex == 0
                ? "No upcoming events"
                : "No past events",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  return ListView.separated(
    itemCount: currentEvents.length,
    separatorBuilder: (context, index) => const SizedBox(height: 16),
    itemBuilder: (context, index) {
      final event = currentEvents[index];
      return _buildEventCard(event);
    },
  );
}

Widget _buildEventCard(Map<String, dynamic> event) {
  return GestureDetector(
    onTap: () {
      // Navigate to event details screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(
            eventTitle: event['name'],
            eventData: event,
            isPublic: true, // Adjust based on your logic
            isPastEvent: selectedIndex == 1, // Past events if selectedIndex is 1
          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              image: DecorationImage(
                image: AssetImage(event['image']),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Price tag
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: event['isPaid'] ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event['price'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event['location'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      event['date'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4776E6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event['category'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4776E6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}