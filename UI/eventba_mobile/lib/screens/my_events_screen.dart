import 'package:eventba_mobile/widgets/event_card.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/providers/user_provider.dart';
import 'package:eventba_mobile/models/event/event.dart';
import 'package:eventba_mobile/models/enums/event_status.dart';
import 'my_event_details_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<Event> _events = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _loadMyEvents();
  }

  Future<void> _checkUserRole() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = await userProvider.getProfile();
      setState(() {
        _isAdmin = user.role.name.toLowerCase() == 'admin';
      });
    } catch (e) {
      print("Failed to check user role: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    _loadMyEvents();
  }

  Future<void> _loadMyEvents() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final events = await eventProvider.getMyEvents();
      if (mounted) {
        setState(() {
          
          if (_isAdmin) {
            _events = events
                .where((event) => event.status == EventStatus.Upcoming)
                .toList();
          } else {
            _events = events;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Failed to load my events: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      initialIndex: 4, 
      showBottomNavBar: !_isAdmin, 
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
                          onTap: () async {
                            await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    MyEventDetailsScreen(eventId: event.id),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                            
                            if (mounted) {
                              _loadMyEvents();
                            }
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
