import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/event_card.dart';

class FavoriteEventsScreen extends StatelessWidget {
  const FavoriteEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._buildEventCardsList(),
          const SizedBox(height: 60), // Bottom padding for nav bar
        ],
      ),
    );
  }

  List<Widget> _buildEventCardsList() {
    return [
      _buildEventCard(isPaid: true),
      const SizedBox(height: 12),
      _buildEventCard(isPaid: false),
      const SizedBox(height: 12),
      _buildEventCard(isPaid: true),
      const SizedBox(height: 12),
      _buildEventCard(isPaid: false),
    ];
  }

  Widget _buildEventCard({required bool isPaid}) {
    return EventCard(
      imageUrl: 'assets/images/default_event_cover_image.png',
      eventName: 'Event Name',
      location: 'Location',
      date: 'Date',
      isPaid: isPaid,
      height: 160,
      isFavoriteEvent: true,
    );
  }
}
