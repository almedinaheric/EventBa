import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/event_card.dart';
import '../providers/event_provider.dart';
import '../models/event/basic_event.dart';
import 'event_details_screen.dart';

class PublicEventsScreen extends StatefulWidget {
  const PublicEventsScreen({super.key});

  @override
  _PublicEventsScreenState createState() => _PublicEventsScreenState();
}

class _PublicEventsScreenState extends State<PublicEventsScreen> {
  late Future<List<BasicEvent>> _publicEventsFuture;

  @override
  void initState() {
    super.initState();
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    _publicEventsFuture = eventProvider.getPublicEvents();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Public events",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () => Navigator.pop(context),
      child: FutureBuilder<List<BasicEvent>>(
        future: _publicEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading public events.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No public events found.'));
          }

          final events = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length + 1,  // Add 1 for extra space at the end
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == events.length) {
                // Last item - add extra space
                return const SizedBox(height: 48);
              }

              final event = events[index];
              Uint8List? imageBytes;
              if (event.coverImage?.data != null) {
                try {
                  imageBytes = base64Decode(event.coverImage!.data);
                } catch (_) {}
              }
              return EventCard(
                imageData: imageBytes,
                eventName: event.title,
                location: event.location ?? 'Location TBA',
                date: event.startDate,
                height: 160,
                //isPaid: event.isPaid ?? false, // Uncomment if available
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => EventDetailsScreen(eventId: event.id),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
