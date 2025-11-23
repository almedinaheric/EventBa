import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/screens/event_details_screen.dart';
import 'package:eventba_admin/providers/event_provider.dart';
import 'package:eventba_admin/providers/user_provider.dart';
import 'package:eventba_admin/models/event/event.dart';
import 'package:eventba_admin/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class UserDetailsScreen extends StatefulWidget {
  final String userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  int selectedIndex = 0; // 0 = Upcoming, 1 = Past
  bool _isLoading = false;
  bool _isLoadingUser = false;
  List<Event> _upcomingEvents = [];
  List<Event> _pastEvents = [];
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadEvents();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUser = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = await userProvider.getUserById(widget.userId);

      setState(() {
        _user = user;
        _isLoadingUser = false;
      });
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _isLoadingUser = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading user data: $e')));
      }
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate that userId is a valid GUID format
      final guidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      );

      if (!guidRegex.hasMatch(widget.userId)) {
        print("Invalid userId format: ${widget.userId}. Expected GUID format.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final events = await eventProvider.getEventsByOrganizer(widget.userId);

      setState(() {
        // Filter by status: Upcoming vs Past
        _upcomingEvents = events
            .where(
              (event) => event.status.name == 'Upcoming' && event.isPublished,
            )
            .toList();
        _pastEvents = events
            .where((event) => event.status.name == 'Past' && event.isPublished)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading events: $e");
      setState(() {
        _isLoading = false;
      });
      // Don't show error to user if it's just about events not loading
      // The user profile will still be shown
    }
  }

  Map<String, dynamic> _eventToMap(Event event) {
    return {
      'id': event.id,
      'name': event.title,
      'description': event.description,
      'venue': event.location,
      'date': event.startDate,
      'startTime': event.startTime,
      'endTime': event.endTime,
      'startDate': event.startDate,
      'endDate': event.endDate,
      'category': event.category?.name ?? 'Uncategorized',
      'categoryId': event.category?.id ?? '',
      'isPaid': event.isPaid,
      'coverImage': event.coverImage,
      'galleryImages': event.galleryImages,
      'status': event.status.name,
      'type': event.type.name,
      'organizerId': event.organizerId,
      'capacity': event.capacity,
      'currentAttendees': event.currentAttendees,
      'availableTicketsCount': event.availableTicketsCount,
      'averageRating': event.averageRating,
      'reviewCount': event.reviewCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return MasterScreen(
        title: 'User Details',
        showBackButton: true,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return MasterScreen(
        title: 'User Details',
        showBackButton: true,
        body: const Center(child: Text('User not found')),
      );
    }

    return MasterScreen(
      title: 'User Details',
      showBackButton: true,
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          children: [
            // User Profile Section
            _buildUserProfile(),

            const SizedBox(height: 32),

            // User Events Section
            _buildEventsSection(),

            const SizedBox(height: 16),

            // Toggle buttons
            _buildToggleButtons(),

            const SizedBox(height: 16),

            // Events List
            Expanded(child: _buildEventsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    // Get profile image data
    String? profileImageData;
    if (_user!.profileImage != null && _user!.profileImage!.data != null) {
      profileImageData = _user!.profileImage!.data;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4776E6), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: profileImageData != null
                  ? Image.memory(
                      base64Decode(profileImageData.split(',').last),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.withOpacity(0.3),
                          child: const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.withOpacity(0.3),
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // User Name
          Text(
            _user!.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 24),

          // User Details
          Row(
            children: [
              Expanded(
                child: _buildUserDetailItem(
                  icon: Icons.email,
                  label: 'Email',
                  value: _user!.email,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserDetailItem(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: _user!.phoneNumber ?? 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    return Row(
      children: [
        const Text(
          "User Events",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        Text(
          "Total: ${_upcomingEvents.length + _pastEvents.length}",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4776E6)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? const Color(0xFF4776E6)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: Text(
                  "Upcoming (${_upcomingEvents.length})",
                  style: TextStyle(
                    color: selectedIndex == 0
                        ? Colors.white
                        : const Color(0xFF4776E6),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? const Color(0xFF4776E6)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Text(
                  "Past (${_pastEvents.length})",
                  style: TextStyle(
                    color: selectedIndex == 1
                        ? Colors.white
                        : const Color(0xFF4776E6),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentEvents = selectedIndex == 0 ? _upcomingEvents : _pastEvents;

    if (currentEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              selectedIndex == 0 ? "No upcoming events" : "No past events",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: currentEvents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = currentEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    final eventData = _eventToMap(event);
    final isPastEvent = event.status.name == 'Past';
    final isPublicEvent = event.type.name == 'Public';

    return GestureDetector(
      onTap: () async {
        // Navigate to event details screen
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              eventTitle: event.title,
              eventData: eventData,
              isPublic: isPublicEvent,
              isPastEvent: isPastEvent,
            ),
          ),
        );

        // Reload events if something changed
        if (result == true) {
          _loadEvents();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover image
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
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.event,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                    // Paid/Free tag
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: event.isPaid ? Colors.green : Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.isPaid ? 'Paid' : 'Free',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.startDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4776E6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.category?.name ?? 'Uncategorized',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4776E6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
