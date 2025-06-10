import 'package:eventba_admin/widgets/event_card.dart';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'my_event_details_screen.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> eventData = {
      'name': 'Concert Night',
      'category': 'Music',
      'venue': 'City Hall',
      'date': '2023-12-31',
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
      // Add other fields as necessary
    };

    final events = [
      {
        "title": "Music Festival",
        "date": "June 10, 2025",
        "location": "Main Hall, City Center",
        "status": "UPCOMING",
        "attendees": 150,
        "image": "assets/images/music_festival.jpg",
      },
      {
        "title": "Art Expo",
        "date": "July 5, 2025",
        "location": "Art Gallery Downtown",
        "status": "UPCOMING",
        "attendees": 75,
        "image": "assets/images/art_expo.jpg",
      },
      {
        "title": "Tech Conference",
        "date": "May 1, 2025",
        "location": "Convention Center",
        "status": "PAST",
        "attendees": 200,
        "image": "assets/images/tech_conference.jpg",
      },
    ];

    return MasterScreenWidget(
      initialIndex: 4, // set your bottom nav index accordingly
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "My Events",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: events.isEmpty
            ? Center(
          child: Text(
            "You haven't created any events yet.",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        )
            : ListView.separated(
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              imageUrl: 'assets/images/default_event_cover_image.png',
              eventName: event["title"]! as String,
              location: event["location"]! as String,
              date: event["date"]! as String,
              isPaid: false, // keep false, badge shows upcoming/past
              isFeatured: false,
              isFavoriteEvent: false,
              isMyEvent: true,
              height: 140,
              myEventStatus:event["status"]! as String,
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>
                        MyEventDetailsScreen(
                          eventTitle: event["title"]! as String,
                          eventData: eventData,
                        ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              // Override the badge colors and text based on status inside EventCard
              // So we pass isPaid false, but we modify EventCard to optionally take 'status' param instead of isPaid
            );
          },
        ),
      ),
    );
  }
}
