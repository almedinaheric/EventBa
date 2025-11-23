import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/event_card.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import '../providers/event_provider.dart';
import '../models/event/basic_event.dart';
import 'event_details_screen.dart';

class PrivateEventsScreen extends StatefulWidget {
  const PrivateEventsScreen({super.key});

  @override
  _PrivateEventsScreenState createState() => _PrivateEventsScreenState();
}

class _PrivateEventsScreenState extends State<PrivateEventsScreen> {
  final List<BasicEvent> _events = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    _loadMoreEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreEvents() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final newEvents = await eventProvider.getPrivateEvents(
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        if (newEvents.isEmpty || newEvents.length < _pageSize) {
          _hasMore = false;
        }
        _events.addAll(newEvents);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading events: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Private events",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () => Navigator.pop(context),
      child: _events.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? const Center(child: Text('No private events found.'))
          : ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _events.length + (_hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == _events.length) {
                  // Load More button
                  final screenWidth = MediaQuery.of(context).size.width;
                  final buttonWidth =
                      screenWidth - 32; // Account for ListView padding (16 * 2)

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: PrimaryButton(
                        text: _isLoading ? "Loading..." : "Load More",
                        onPressed: _isLoading ? () {} : _loadMoreEvents,
                        width: buttonWidth,
                      ),
                    ),
                  );
                }

                final event = _events[index];
                return EventCard(
                  imageData: event.coverImage?.data,
                  eventName: event.title,
                  location: event.location ?? 'Location TBA',
                  date: event.startDate,
                  height: 160,
                  isPaid: event.isPaid,
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
                );
              },
            ),
    );
  }
}
