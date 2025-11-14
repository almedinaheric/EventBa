import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/providers/event_provider.dart';
import 'package:eventba_admin/models/event/event.dart';
import 'package:eventba_admin/models/enums/event_status.dart';
import 'package:eventba_admin/screens/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PublicEventsScreen extends StatefulWidget {
  const PublicEventsScreen({super.key});

  @override
  _PublicEventsScreenState createState() => _PublicEventsScreenState();
}

class _PublicEventsScreenState extends State<PublicEventsScreen> {
  int selectedIndex = 0; // 0 = Upcoming, 1 = Past
  List<Event> _allEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final events = await eventProvider.getPublicEvents();

      // Filter only published events
      final publishedEvents = events
          .where((event) => event.isPublished)
          .toList();

      setState(() {
        _allEvents = publishedEvents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load events: $e";
        _isLoading = false;
      });
      print("Error loading events: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Public Events',
      showBackButton: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadEvents,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Custom toggle buttons (Upcoming / Past)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      // Upcoming button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = 0;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedIndex == 0
                                  ? const Color(0xFF4776E6)
                                  : Colors.transparent,
                              border: Border.all(
                                color: const Color(0xFF4776E6),
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                bottomLeft: Radius.circular(30),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Text(
                              "Upcoming",
                              style: TextStyle(
                                color: selectedIndex == 0
                                    ? Colors.white
                                    : const Color(0xFF4776E6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Past button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = 1;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedIndex == 1
                                  ? const Color(0xFF4776E6)
                                  : Colors.transparent,
                              border: Border.all(
                                color: const Color(0xFF4776E6),
                              ),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Text(
                              "Past",
                              style: TextStyle(
                                color: selectedIndex == 1
                                    ? Colors.white
                                    : const Color(0xFF4776E6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Events List
                Expanded(
                  child: _buildEventsList(isUpcoming: selectedIndex == 0),
                ),
              ],
            ),
    );
  }

  Widget _buildEventsList({required bool isUpcoming}) {
    // Filter events by status
    final filteredEvents = _allEvents.where((event) {
      if (isUpcoming) {
        return event.status == EventStatus.Upcoming;
      } else {
        return event.status == EventStatus.Past;
      }
    }).toList();

    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming events' : 'No past events',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        final crossAxisCount = isDesktop ? 2 : 1;
        final childAspectRatio = isDesktop ? 2.5 : 2.8;
        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            final event = filteredEvents[index];
            return _buildEventCard(event: event, isUpcoming: isUpcoming);
          },
        );
      },
    );
  }

  Map<String, dynamic> _eventToMap(Event event) {
    return {
      'id': event.id,
      'name': event.title,
      'category': event.category.name,
      'venue': event.location,
      'date': event.startDate,
      'startTime': event.startDate,
      'endTime': event.endDate,
      'description': event.description,
      'isPaid': event.isPaid,
      'status': event.status.name,
      'coverImage': event.coverImage,
    };
  }

  Widget _buildEventCard({required Event event, required bool isUpcoming}) {
    final badgeText = event.isPaid ? 'PAID' : 'FREE';
    final badgeColor = event.isPaid ? const Color(0xFF4776E6) : Colors.green;

    // Format date
    final formattedDate = event.startDate;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              eventTitle: event.title,
              isPublic: true,
              isPastEvent: event.status == EventStatus.Past,
              eventData: _eventToMap(event),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/default_event_cover_image.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with date and badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Event details
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.location,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
