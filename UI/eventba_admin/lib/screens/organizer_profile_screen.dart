import 'package:eventba_admin/screens/past_event_details_screen.dart';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventba_admin/widgets/event_card.dart';

class OrganizerProfileScreen extends StatefulWidget {
  final int userId;
  final String name;
  final String avatarUrl;
  final String bio;

  const OrganizerProfileScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.bio,
  });

  @override
  State<OrganizerProfileScreen> createState() => _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends State<OrganizerProfileScreen> {
  int selectedIndex = 0; // 0 = Upcoming, 1 = Past

  @override
  Widget build(BuildContext context) {
    final upcomingEvents = [
      const EventCard(
        imageUrl: 'assets/images/default_event_cover_image.png',
        eventName: 'Tech Meetup 2025',
        location: 'Downtown Hall',
        date: '2025-07-15',
        isPaid: false,
        height: 160,
      ),
    ];

    final pastEvents = [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PastEventDetailsScreen(
                eventTitle: 'Spring Fest 2024',
                eventData: {
                  'id': 1,
                  'imageUrl': 'assets/images/default_event_cover_image.png',
                  'location': 'Central Park',
                  'date': '2024-04-20',
                  'isPaid': true,
                  // Add other relevant fields if needed
                },
              ),
            ),
          );
        },
        child: const EventCard(
          imageUrl: 'assets/images/default_event_cover_image.png',
          eventName: 'Spring Fest 2024',
          location: 'Central Park',
          date: '2024-04-20',
          isPaid: true,
          height: 160,
        ),
      ),
    ];

    return MasterScreenWidget(
      title: widget.name,
      initialIndex: -1,
      appBarType: AppBarType.iconsSideTitleCenter,
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(widget.avatarUrl),
          ),
          // Name
          Text(
            widget.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.bio,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),

          const SizedBox(height: 24),

          // Section title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "User Events",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Toggle buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        border: Border.all(color: const Color(0xFF4776E6)),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Upcoming",
                        style: TextStyle(
                          color: selectedIndex == 0
                              ? Colors.white
                              : const Color(0xFF4776E6),
                          fontWeight: FontWeight.bold,
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
                        border: Border.all(color: const Color(0xFF4776E6)),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Past",
                        style: TextStyle(
                          color: selectedIndex == 1
                              ? Colors.white
                              : const Color(0xFF4776E6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Event list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (selectedIndex == 0 && upcomingEvents.isEmpty)
                  const Text("No upcoming events."),
                if (selectedIndex == 1 && pastEvents.isEmpty)
                  const Text("No past events."),
                if (selectedIndex == 0) ...upcomingEvents,
                if (selectedIndex == 1) ...pastEvents,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
