import 'dart:async';
import 'dart:convert';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/providers/event_provider.dart';
import 'package:eventba_admin/models/event/event.dart';
import 'package:eventba_admin/models/enums/event_status.dart';
import 'package:eventba_admin/screens/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrivateEventsScreen extends StatefulWidget {
  const PrivateEventsScreen({super.key});

  @override
  _PrivateEventsScreenState createState() => _PrivateEventsScreenState();
}

class _PrivateEventsScreenState extends State<PrivateEventsScreen> {
  int selectedIndex = 0;
  List<Event> _allEvents = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchTerm = '';
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final isUpcoming = selectedIndex == 0;
      final events = await eventProvider.getPrivateEvents(
        searchTerm: _searchTerm.isNotEmpty ? _searchTerm : null,
        isUpcoming: isUpcoming,
      );

      if (!mounted) return;

      final publishedEvents = events
          .where((event) => event.isPublished)
          .toList();

      setState(() {
        _allEvents = publishedEvents;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to load events: $e";
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _searchTimer?.cancel();

    setState(() {
      _searchTerm = query;
    });

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Private Events',
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search events by name or description...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _searchTerm.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = 0;
                            });
                            _loadEvents();
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

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = 1;
                            });
                            _loadEvents();
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

                Expanded(
                  child: _buildEventsList(isUpcoming: selectedIndex == 0),
                ),
              ],
            ),
    );
  }

  Widget _buildEventsList({required bool isUpcoming}) {
    // Events are already filtered by date on backend, so just use _allEvents
    final filteredEvents = _allEvents;

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
      'category': event.category?.name ?? 'Uncategorized',
      'categoryId': event.category?.id ?? '',
      'venue': event.location,
      'date': event.startDate,
      'startTime': event.startTime,
      'endTime': event.endTime,
      'startDate': event.startDate,
      'endDate': event.endDate,
      'description': event.description,
      'isPaid': event.isPaid,
      'status': event.status.name,
      'type': event.type.name,
      'coverImage': event.coverImage,
      'galleryImages': event.galleryImages,
      'organizerId': event.organizerId,
      'capacity': event.capacity,
      'currentAttendees': event.currentAttendees,
      'availableTicketsCount': event.availableTicketsCount,
      'isFeatured': false,
      'averageRating': event.averageRating ?? 0.0,
      'reviewCount': event.reviewCount ?? 0,
    };
  }

  Widget _buildEventCard({required Event event, required bool isUpcoming}) {
    final badgeText = event.isPaid ? 'PAID' : 'FREE';
    final badgeColor = event.isPaid ? const Color(0xFF4776E6) : Colors.green;

    final formattedDate = event.startDate;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              // Determine if event is past based on date
              final today = DateTime.now();
              final todayDateOnly = DateTime(
                today.year,
                today.month,
                today.day,
              );
              final eventStartDateParts = event.startDate.split('-');
              final isPastEvent = eventStartDateParts.length == 3
                  ? DateTime(
                      int.parse(eventStartDateParts[0]),
                      int.parse(eventStartDateParts[1]),
                      int.parse(eventStartDateParts[2]),
                    ).isBefore(todayDateOnly)
                  : false;

              return EventDetailsScreen(
                eventTitle: event.title,
                isPublic: false,
                isPastEvent: isPastEvent,
                eventData: _eventToMap(event),
              );
            },
          ),
        );

        if (result == true) {
          _loadEvents();
        }
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
          child: SizedBox(
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                event.coverImage != null && event.coverImage!.isNotEmpty
                    ? Image.memory(
                        base64Decode(event.coverImage!.split(',').last),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/default_event_cover_image.png',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/default_event_cover_image.png',
                        fit: BoxFit.cover,
                      ),
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
      ),
    );
  }
}
