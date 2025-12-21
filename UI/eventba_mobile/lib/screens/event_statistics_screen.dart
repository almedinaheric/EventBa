import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/models/event/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventStatisticsScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EventStatisticsScreen({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  @override
  State<EventStatisticsScreen> createState() => _EventStatisticsScreenState();
}

class _EventStatisticsScreenState extends State<EventStatisticsScreen> {
  Map<String, dynamic>? _statistics;
  Event? _event;
  bool _isLoading = true;
  bool _isPast = false;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      // Load event to check if it's past
      final event = await eventProvider.getById(widget.eventId);
      final eventStartDateTime = DateTime.parse(
        '${event.startDate} ${event.startTime}',
      );
      final isPast = eventStartDateTime.isBefore(DateTime.now());

      // Load event statistics
      Map<String, dynamic>? statistics;
      try {
        statistics = await eventProvider.getEventStatistics(widget.eventId);
      } catch (e) {
        print("Failed to load statistics: $e");
      }

      setState(() {
        _event = event;
        _statistics = statistics;
        _isPast = isPast;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading statistics: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MasterScreenWidget(
        title: "Event Statistics",
        initialIndex: 4,
        appBarType: AppBarType.iconsSideTitleCenter,
        leftIcon: Icons.arrow_back,
        onLeftButtonPressed: () {
          Navigator.pop(context);
        },
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalAttendees =
        _statistics?['attendees'] ?? _event?.currentAttendees ?? 0;
    final ticketsSold = _statistics?['ticketsSold'] ?? 0;
    final revenue = _statistics?['revenue'] ?? 0.0;
    final averageRating = _isPast && _statistics?['averageRating'] != null
        ? _statistics!['averageRating'].toStringAsFixed(1)
        : 'N/A';

    return MasterScreenWidget(
      title: "Event Statistics",
      initialIndex: 4,
      appBarType: AppBarType.iconsSideTitleCenter,
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStatCard(
            "Total Attendees",
            totalAttendees.toString(),
            Icons.people,
          ),
          _buildStatCard(
            "Tickets Sold",
            ticketsSold.toString(),
            Icons.confirmation_number,
          ),
          _buildStatCard(
            "Revenue",
            "\$${revenue.toStringAsFixed(2)}",
            Icons.attach_money,
          ),
          _buildStatCard("Average Rating", averageRating, Icons.star),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.blue),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
