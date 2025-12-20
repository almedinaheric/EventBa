import 'package:eventba_mobile/screens/past_event_details_screen.dart';
import 'package:eventba_mobile/screens/event_details_screen.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/utils/image_helpers.dart';
import 'package:eventba_mobile/widgets/event_card.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/models/event/basic_event.dart';
import 'package:eventba_mobile/models/enums/event_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrganizerProfileScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String avatarUrl;
  final String bio;

  const OrganizerProfileScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.bio,
  });

  @override
  State<OrganizerProfileScreen> createState() => _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends State<OrganizerProfileScreen> {
  int selectedIndex = 0; // 0 = Upcoming, 1 = Past
  List<BasicEvent> _upcomingEvents = [];
  List<BasicEvent> _pastEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final events = await eventProvider.getEventsByOrganizer(widget.userId);

      final upcoming = events
          .where((e) => e.status == EventStatus.Upcoming)
          .toList();
      final past = events.where((e) => e.status == EventStatus.Past).toList();

      setState(() {
        _upcomingEvents = upcoming;
        _pastEvents = past;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading events: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.name,
      initialIndex: -1,
      appBarType: AppBarType.iconsSideTitleCenter,
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: widget.avatarUrl.startsWith('assets/')
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(widget.avatarUrl),
                  )
                : ClipOval(
                    child: ImageHelpers.getProfileImage(
                      widget.avatarUrl,
                      height: 100,
                      width: 100,
                    ),
                  ),
          ),
          // Name
          Text(
            widget.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.bio,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),

          const SizedBox(height: 24),

          // Section title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "User Events",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Toggle buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        border: Border.all(color: const Color(0xFF4776E6)),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                        ),
                      ),
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
                    onTap: () => setState(() => selectedIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedIndex == 1
                            ? const Color(0xFF4776E6)
                            : Colors.transparent,
                        border: Border.all(color: const Color(0xFF4776E6)),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
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

          const SizedBox(height: 12),

          // Event list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (selectedIndex == 0 && _upcomingEvents.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text("No upcoming events."),
                          ),
                        ),
                      if (selectedIndex == 1 && _pastEvents.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text("No past events."),
                          ),
                        ),
                      if (selectedIndex == 0)
                        ..._upcomingEvents.map(
                          (event) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: EventCard(
                              imageData: event.coverImage?.data,
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
                          ),
                        ),
                      if (selectedIndex == 1)
                        ..._pastEvents.map(
                          (event) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildPastEventCard(event),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastEventCard(BasicEvent event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                PastEventDetailsScreen(eventId: event.id),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: EventCard(
        imageData: event.coverImage?.data,
        eventName: event.title,
        location: event.location ?? 'Location TBA',
        date: event.startDate,
        isPaid: event.isPaid,
        height: 160,
      ),
    );
  }
}
