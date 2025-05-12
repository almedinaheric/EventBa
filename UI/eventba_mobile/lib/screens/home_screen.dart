import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/event_card.dart'; // Ensure this is imported

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      appBarType: AppBarType.titleLeftIconRight,
      rightIcon: Icons.notifications,
      onRightButtonPressed: () {
        print("Notifications tapped");
      },
      child: ListView(
        // Change SingleChildScrollView to ListView for better scrolling
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildSectionHeader('Recommended'),
          const SizedBox(height: 8),
          _buildHorizontalEventList(2),
          const SizedBox(height: 24),
          _buildSectionHeader('Search by category'),
          const SizedBox(height: 8),
          _buildCategoryChips(),
          const SizedBox(height: 24),
          _buildSectionHeader('Public events'),
          const SizedBox(height: 8),
          _buildHorizontalEventList(3), // Modify the number here for testing
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search events...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "View All",
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalEventList(int count) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _buildEventCard(
              isPaid: index.isEven); // Example for alternating paid/free
        },
      ),
    );
  }

  Widget _buildEventCard({bool isPaid = false}) {
    return EventCard(
      imageUrl: 'assets/images/default_event_cover_image.png',
      eventName: 'Event Name ${isPaid ? "Paid" : "Free"}',
      location: 'Location ${isPaid ? "NY" : "LA"}',
      date: 'Date ${isPaid ? "2025-06-15" : "2025-06-20"}',
      isPaid: isPaid, // Set based on event type
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      'Business',
      'Health',
      'Technology',
      'Food',
      'Art',
      'Tourism',
      'Music',
      'Recreation',
      'Education',
      'Sports',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories
          .map(
            (cat) => Chip(
              label: Text(cat),
              backgroundColor: Colors.blue.shade200,
            ),
          )
          .toList(),
    );
  }
}
