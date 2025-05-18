import 'package:eventba_mobile/screens/private_events_screen.dart';
import 'package:eventba_mobile/screens/public_events_screen.dart';
import 'package:eventba_mobile/screens/recommended_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/text_link_button.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 20),
        _buildSectionHeader(
          'Recommended',
          onViewAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const RecommendedEventsScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildRecommendedEventGrid(),
        const SizedBox(height: 20),
        _buildSectionHeader(
          'Search by category',
          showViewAll: false,
        ),
        const SizedBox(height: 12),
        _buildCategoryChips(),
        const SizedBox(height: 20),
        _buildSectionHeader(
          'Public events',
          onViewAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PublicEventsScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildPublicEventGrid(),
        const SizedBox(height: 20),
        _buildSectionHeader(
          'Private events',
          onViewAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivateEventsScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildPrivateEventGrid(),
        const SizedBox(height: 20), // Space for bottom navbar
      ],
    ));
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search events...',
          prefixIcon: Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    bool showViewAll = true,
    VoidCallback? onViewAllTap,
  }) {
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
        if (showViewAll)
          TextLinkButton(
            linkText: "View All",
            onTap: onViewAllTap ?? () {},
          ),
      ],
    );
  }

  Widget _buildRecommendedEventGrid() {
    return const SizedBox(
      height: 160,
      child: Row(
        children: [
          Expanded(
            child: EventCard(
              imageUrl: 'assets/images/default_event_cover_image.png',
              eventName: 'Koncert Mirze Selimovica',
              location: 'Ulica 5. korpusa h5 10/38',
              date: '27-06-2025',
              height: 160,
              isPaid: false,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: EventCard(
              imageUrl: 'assets/images/default_event_cover_image.png',
              eventName: 'Event Name',
              location: 'Location',
              date: 'Date',
              height: 160,
              isPaid: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicEventGrid() {
    return const Column(
      children: [
        SizedBox(
          height: 160,
          child: EventCard(
            imageUrl: 'assets/images/default_event_cover_image.png',
            eventName: 'Event Name',
            location: 'Ulica 5. korpusa h5 10/38',
            date: 'Date',
            height: 160,
            isPaid: false,
          ),
        ),
        SizedBox(height: 10), // Space between the two cards
        SizedBox(
          height: 160,
          child: EventCard(
            imageUrl: 'assets/images/default_event_cover_image.png',
            eventName: 'Koncert Mirze Selimovica',
            location: 'Trg Mostar',
            date: '27-06-2025',
            height: 160,
            isPaid: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivateEventGrid() {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 160,
                child: EventCard(
                  imageUrl: 'assets/images/default_event_cover_image.png',
                  eventName: 'Private Event 1',
                  location: 'Private Location 1',
                  date: '2025-06-10',
                  height: 160,
                  isPaid: false,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 160,
                child: EventCard(
                  imageUrl: 'assets/images/default_event_cover_image.png',
                  eventName: 'Koncert Mirze Selimovica',
                  location: 'Trg Mostar',
                  date: '27-06-2025',
                  height: 160,
                  isPaid: true,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 160,
                child: EventCard(
                  imageUrl: 'assets/images/default_event_cover_image.png',
                  eventName: 'Private Event 3',
                  location: 'Private Location 3',
                  date: '2025-06-20',
                  height: 160,
                  isPaid: false,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 160,
                child: EventCard(
                  imageUrl: 'assets/images/default_event_cover_image.png',
                  eventName: 'Private Event 4',
                  location: 'Private Location 4',
                  date: '2025-06-25',
                  height: 160,
                  isPaid: true,
                ),
              ),
            ),
          ],
        ),
      ],
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

    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categories
            .map(
              (cat) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF5B7CF6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    cat,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
