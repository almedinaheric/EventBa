import 'package:eventba_mobile/screens/ticket_details_screen.dart';
import 'package:eventba_mobile/widgets/empty_tickets_state.dart';
import 'package:eventba_mobile/widgets/ticket_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventba_mobile/providers/ticket_purchase_provider.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/models/ticket_purchase/ticket_purchase.dart';
import 'package:eventba_mobile/models/event/event.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  int selectedIndex = 0; 
  Map<String, List<TicketPurchase>> _upcomingTicketsByEvent = {};
  Map<String, List<TicketPurchase>> _pastTicketsByEvent = {};
  Map<String, Event> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      final ticketPurchaseProvider = Provider.of<TicketPurchaseProvider>(
        context,
        listen: false,
      );
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      
      final allPurchases = await ticketPurchaseProvider.getMyPurchases();

      
      final eventIds = allPurchases.map((p) => p.eventId).toSet();

      
      final events = <String, Event>{};
      for (final eventId in eventIds) {
        try {
          final event = await eventProvider.getById(eventId);
          events[eventId] = event;
        } catch (e) {
          print("Failed to load event $eventId: $e");
        }
      }

      
      final now = DateTime.now();
      final upcomingTicketsByEvent = <String, List<TicketPurchase>>{};
      final pastTicketsByEvent = <String, List<TicketPurchase>>{};

      for (final purchase in allPurchases) {
        final event = events[purchase.eventId];
        if (event == null) continue;

        
        final eventStartDateTime = DateTime.parse(
          '${event.startDate} ${event.startTime}',
        );
        final isUpcoming = eventStartDateTime.isAfter(now);

        if (isUpcoming) {
          upcomingTicketsByEvent
              .putIfAbsent(purchase.eventId, () => [])
              .add(purchase);
        } else {
          pastTicketsByEvent
              .putIfAbsent(purchase.eventId, () => [])
              .add(purchase);
        }
      }

      setState(() {
        _upcomingTicketsByEvent = upcomingTicketsByEvent;
        _pastTicketsByEvent = pastTicketsByEvent;
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to load tickets: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                
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
                        border: Border.all(color: const Color(0xFF4776E6)),
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
                    },
                    child: Container(
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedIndex == 0
                ? (_upcomingTicketsByEvent.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: _loadTickets,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              ..._buildTicketCards(_upcomingTicketsByEvent),
                            ],
                          ),
                        )
                      : const EmptyTicketsState())
                : (_pastTicketsByEvent.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: _loadTickets,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              ..._buildTicketCards(_pastTicketsByEvent),
                            ],
                          ),
                        )
                      : const EmptyTicketsState()),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTicketCards(
    Map<String, List<TicketPurchase>> ticketsByEvent,
  ) {
    return ticketsByEvent.entries.map((entry) {
      final eventId = entry.key;
      final purchases = entry.value;
      final event = _events[eventId];

      if (event == null) {
        return const SizedBox.shrink();
      }

      
      final eventStartDateTime = DateTime.parse(
        '${event.startDate} ${event.startTime}',
      );
      final date = _formatDate(eventStartDateTime);
      final time = _formatTime(eventStartDateTime);

      
      double totalPrice = 0.0;
      for (final purchase in purchases) {
        totalPrice += purchase.pricePaid;
      }

      
      final formattedPrice = totalPrice > 0
          ? "\$${totalPrice.toStringAsFixed(2)}"
          : "Free";

      return Column(
        children: [
          TicketCard(
            eventName: event.title,
            date: date,
            time: time,
            ticketCount: purchases.length,
            totalPrice: formattedPrice,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => TicketDetailsScreen(
                    eventId: eventId,
                    purchases: purchases,
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
