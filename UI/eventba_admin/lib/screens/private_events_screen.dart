import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/screens/event_details_screen.dart';
import 'package:flutter/material.dart';

class PrivateEventsScreen extends StatefulWidget {
  const PrivateEventsScreen({super.key});

  @override
  _PrivateEventsScreenState createState() => _PrivateEventsScreenState();
}

class _PrivateEventsScreenState extends State<PrivateEventsScreen> {
  int selectedIndex = 0; // 0 = Upcoming, 1 = Past

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Private Events',
      showBackButton: true,
      body: Column(
        children: [
          // Custom toggle buttons (Upcoming / Past)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // Upcoming button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = 0;
                      });
                    },
                    child: Container(
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
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

                // Past button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = 1;
                      });
                    },
                    child: Container(
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
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

          // Events List
          Expanded(
            child: _buildEventsList(isUpcoming: selectedIndex == 0),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList({required bool isUpcoming}) {
    // Sample list of events with their respective data
    List<Map<String, dynamic>> events = [
      {
        'name': 'Concert Night',
        'category': 'Music',
        'venue': 'City Hall',
        'date': '25-06-2025',
        'startTime': '19:00',
        'endTime': '23:00',
        'description': 'A night of live music and entertainment.',
        'capacity': 1000,
        'vipPrice': 150.0,
        'vipCount': 100,
        'ecoPrice': 50.0,
        'ecoCount': 900,
        'isPaid': true,
        'status': 'UPCOMING',
      },
      {
        'name': 'Art Exhibition',
        'category': 'Art',
        'venue': 'National Gallery',
        'date': '26-06-2025',
        'startTime': '10:00',
        'endTime': '17:00',
        'description': 'A showcase of contemporary art.',
        'capacity': 500,
        'vipPrice': 0.0,
        'vipCount': 0,
        'ecoPrice': 0.0,
        'ecoCount': 500,
        'isPaid': false,
        'status': 'UPCOMING',
      },
      // Add more events as necessary
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        final crossAxisCount = isDesktop ? 2 : 1;
        final childAspectRatio = isDesktop ? 2.5 : 2.8;
        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            var event = events[index];
            return _buildEventCard(
              eventName: event['name'],
              location: event['venue'],
              date: event['date'],
              isPaid: event['isPaid'],
              isUpcoming: isUpcoming,
              eventData: event, // Passing individual event data
            );
          },
        );
      },
    );
  }

  Widget _buildEventCard({
    required String eventName,
    required String location,
    required String date,
    required bool isPaid,
    required bool isUpcoming,
    required Map<String, dynamic> eventData, // Include eventData as a parameter
  }) {
    final badgeText = isPaid ? 'PAID' : 'FREE';
    final badgeColor = isPaid ? const Color(0xFF4776E6) : Colors.green;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              eventTitle: eventName,
              isPublic: false,
              isPastEvent: false,
              eventData: eventData,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/default_event_cover_image.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with date and badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Event details
                    Text(
                      eventName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
