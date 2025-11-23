import 'package:eventba_mobile/widgets/event_card.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/models/event/event.dart';
import 'my_event_details_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyEvents();
  }

  Future<void> _loadMyEvents() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final events = await eventProvider.getMyEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to load my events: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      initialIndex: 4, // set your bottom nav index accordingly
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "My Events",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () => Navigator.pop(context),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _events.isEmpty
                  ? Center(
                      child: Text(
                        "You haven't created any events yet.",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: _events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return EventCard(
                          imageData: event.coverImage?.data,
                          eventName: event.title,
                          location: event.location,
                          date: event.startDate,
                          isPaid: event.isPaid,
                          isFeatured: false,
                          isFavoriteEvent: false,
                          isMyEvent: true,
                          height: 140,
                          myEventStatus: event.status,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    MyEventDetailsScreen(
                                      eventTitle: event.title,
                                      eventData: {
                                        'id': event.id,
                                        'name': event.title,
                                        'category': event.category.name,
                                        'categoryId': event.category.id,
                                        'venue': event.location,
                                        'date': event.startDate,
                                        'startTime': event.startTime,
                                        'endTime': event.endTime,
                                        'description': event.description,
                                        'capacity': event.capacity,
                                        'currentAttendees':
                                            event.currentAttendees,
                                        'vipPrice': 150.0,
                                        'vipCount': 100,
                                        'ecoPrice': 50.0,
                                        'ecoCount': 900,
                                        'isPaid': event.isPaid,
                                        'status': event.status.toString(),
                                        'coverImage': event.coverImage?.data,
                                        'coverImageId': event.coverImage?.id,
                                        'galleryImages': event.galleryImages
                                            ?.map((img) => img.data)
                                            .toList(),
                                        'galleryImageIds': event.galleryImages
                                            ?.map((img) => img.id)
                                            .toList(),
                                      },
                                    ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
