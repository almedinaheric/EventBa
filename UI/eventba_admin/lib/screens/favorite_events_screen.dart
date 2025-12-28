import 'package:flutter/material.dart';
import 'package:eventba_admin/widgets/event_card.dart';

class FavoriteEventsScreen extends StatefulWidget {
  const FavoriteEventsScreen({super.key});

  @override
  State<FavoriteEventsScreen> createState() => _FavoriteEventsScreenState();
}

class _FavoriteEventsScreenState extends State<FavoriteEventsScreen> {
  List<bool> isFavoriteList = List.generate(4, (index) => true);
  List<int> favoriteEventIndices = List.generate(4, (index) => index);

  @override
  Widget build(BuildContext context) {
    final favoriteEvents = favoriteEventIndices
        .where((index) => isFavoriteList[index])
        .toList();

    return Material(
      child: favoriteEvents.isNotEmpty
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [..._buildEventCardsList(), const SizedBox(height: 60)],
            )
          : const Center(
              child: Text(
                'No favorite events yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
    );
  }

  List<Widget> _buildEventCardsList() {
    return favoriteEventIndices.where((index) => isFavoriteList[index]).map((
      index,
    ) {
      return Column(
        children: [
          EventCard(
            imageUrl: 'assets/images/default_event_cover_image.png',
            eventName: 'Event Name $index',
            location: 'Location $index',
            date: 'Date $index',
            isPaid: index % 2 == 0,
            height: 160,
            isFavoriteEvent: isFavoriteList[index],
            onFavoriteToggle: () {
              _toggleFavorite(index);
            },
          ),
          const SizedBox(height: 12),
        ],
      );
    }).toList();
  }

  void _toggleFavorite(int index) {
    setState(() {
      isFavoriteList[index] = !isFavoriteList[index];
      if (!isFavoriteList[index]) {
        favoriteEventIndices.remove(index);
      }
    });

    _updateFavoriteStatus(index, isFavoriteList[index]);
  }

  void _updateFavoriteStatus(int eventId, bool isFavorite) {}
}
