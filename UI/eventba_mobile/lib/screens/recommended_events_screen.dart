import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/event_card.dart';

class RecommendedEventsScreen extends StatelessWidget {
  const RecommendedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Recommended events",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context); // Back button functionality
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // No search bar here based on your requirement (remove if you want)
          // Or uncomment _buildSearchBar() if needed
          // _buildSearchBar(),
          // const SizedBox(height: 20),
          // Section header is title already shown in app bar, so skip here
          // But if you want a header for the list as well, you can add it
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
      // Add more events or map a list of event data here
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
    );
  }
}
