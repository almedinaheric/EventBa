import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/event_card.dart';
import 'package:provider/provider.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/models/event/basic_event.dart';
import 'package:eventba_mobile/screens/event_details_screen.dart';

class FavoriteEventsScreen extends StatefulWidget {
  const FavoriteEventsScreen({super.key});

  @override
  State<FavoriteEventsScreen> createState() => _FavoriteEventsScreenState();
}

class _FavoriteEventsScreenState extends State<FavoriteEventsScreen> {
  List<BasicEvent> _favoriteEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteEvents();
  }

  Future<void> _loadFavoriteEvents() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final favoriteEvents = await eventProvider.getUserFavoriteEvents();
      setState(() {
        _favoriteEvents = favoriteEvents;
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to load favorite events: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteEvents.isNotEmpty
          ? RefreshIndicator(
              onRefresh: _loadFavoriteEvents,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ..._buildEventCardsList(),
                  const SizedBox(height: 60),
                ],
              ),
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
    return _favoriteEvents.map((event) {
      return Column(
        children: [
          EventCard(
            imageData: event.coverImage?.data,
            eventName: event.title,
            location: event.location,
            date: event.startDate,
            isPaid: event.isPaid,
            height: 160,
            isFavoriteEvent: true,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      EventDetailsScreen(eventId: event.id),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            onFavoriteToggle: () {
              _removeFromFavorites(event.id);
            },
          ),
          const SizedBox(height: 12),
        ],
      );
    }).toList();
  }

  void _removeFromFavorites(String eventId) async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.toggleFavoriteEvent(eventId);
      setState(() {
        _favoriteEvents.removeWhere((event) => event.id == eventId);
      });
    } catch (e) {
      print("Failed to remove from favorites: $e");
    }
  }
}
