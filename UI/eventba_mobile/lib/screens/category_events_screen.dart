import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/event_card.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';

class CategoryEventsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryEventsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "$categoryName Events",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event cards list
          ..._buildEventCardsList(),
          const SizedBox(height: 24),

          // Primary Button (you can use it to navigate, load more, etc.)
          PrimaryButton(
            text: "Explore More",
            onPressed: () {
              // Implement action, like loading more events or navigating
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Load more events...')),
              );
            },
            width: double.infinity,
          ),

          const SizedBox(height: 60), // Extra space for bottom nav
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
      eventName: 'Sample Event',
      location: 'City Park',
      date: 'June 10, 2025',
      isPaid: isPaid,
      height: 160,
    );
  }
}
