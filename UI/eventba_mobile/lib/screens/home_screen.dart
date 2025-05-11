import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';

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
          _buildHorizontalEventList(1),
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
          return _buildEventCard(isPaid: true);
        },
      ),
    );
  }

  Widget _buildEventCard({bool isPaid = false}) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage(
              'assets/images/default_event_cover_image.png'), // Placeholder
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPaid ? Colors.blue : Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isPaid ? 'PAID' : 'FREE',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 8,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Location | Date',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
