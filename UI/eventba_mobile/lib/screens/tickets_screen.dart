import 'package:eventba_mobile/screens/ticket_details_screen.dart';
import 'package:eventba_mobile/widgets/empty_tickets_state.dart';
import 'package:eventba_mobile/widgets/ticket_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventba_mobile/providers/ticket_provider.dart';
import 'package:eventba_mobile/models/ticket_purchase/ticket_purchase.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  int selectedIndex = 0; // 0 = Upcoming, 1 = Past
  List<TicketPurchase> _upcomingTickets = [];
  List<TicketPurchase> _pastTickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      final ticketProvider = Provider.of<TicketProvider>(
        context,
        listen: false,
      );

      final upcomingTickets = await ticketProvider.getUpcomingTickets();
      final pastTickets = await ticketProvider.getPastTickets();

      setState(() {
        _upcomingTickets = upcomingTickets;
        _pastTickets = pastTickets;
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
          // Custom toggle buttons instead of TabBar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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

          // Tab content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedIndex == 0
                ? (_upcomingTickets.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: _loadTickets,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [..._buildTicketCards(_upcomingTickets)],
                          ),
                        )
                      : const EmptyTicketsState())
                : (_pastTickets.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: _loadTickets,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [..._buildTicketCards(_pastTickets)],
                          ),
                        )
                      : const EmptyTicketsState()),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTicketCards(List<TicketPurchase> tickets) {
    return tickets.map((ticket) {
      return Column(
        children: [
          TicketCard(
            eventName: "Event ${ticket.eventId}", // TODO: Get actual event name
            date: _formatDate(ticket.createdAt),
            time: _formatTime(ticket.createdAt),
            ticketCount: 1,
            distance: "0KM", // TODO: Calculate distance
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const TicketDetailsScreen(),
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
