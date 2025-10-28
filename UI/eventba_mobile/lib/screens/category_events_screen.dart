import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/event_card.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/models/event/basic_event.dart';
import 'package:eventba_mobile/screens/event_details_screen.dart';

class CategoryEventsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryEventsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryEventsScreen> createState() => _CategoryEventsScreenState();
}

class _CategoryEventsScreenState extends State<CategoryEventsScreen> {
  List<BasicEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final events = await eventProvider.getEventsByCategory(widget.categoryId);
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to load events: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "${widget.categoryName} Events",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isNotEmpty
          ? RefreshIndicator(
              onRefresh: _loadEvents,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ..._buildEventCardsList(),
                  const SizedBox(height: 48), // Extra space for bottom nav
                ],
              ),
            )
          : const Center(
              child: Text(
                'No events found for this category',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
    );
  }

  List<Widget> _buildEventCardsList() {
    return _events.map((event) {
      return Column(
        children: [
          EventCard(
            imageData: null,
            eventName: event.title,
            location: event.location,
            date: event.startDate,
            isPaid: event.isPaid,
            height: 160,
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
          ),
          const SizedBox(height: 12),
        ],
      );
    }).toList();
  }
}
