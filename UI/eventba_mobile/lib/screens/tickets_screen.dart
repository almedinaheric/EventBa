import 'package:eventba_mobile/screens/ticket_details_screen.dart';
import 'package:eventba_mobile/widgets/empty_tickets_state.dart';
import 'package:eventba_mobile/widgets/ticket_card.dart';
import 'package:flutter/material.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  int selectedIndex = 0; // 0 = Upcoming, 1 = Past
  bool hasTickets = true; // Toggle this to show empty state

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
            child: selectedIndex == 0
                ? (hasTickets
                    ? ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          TicketCard(
                            eventName: "Event name",
                            date: "20-06-2025",
                            time: "22:00",
                            ticketCount: 1,
                            distance: "50KM",
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
                          TicketCard(
                            eventName: "Event name",
                            date: "20.6.2023",
                            time: "22:00",
                            ticketCount: 2,
                            distance: "40KM",
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
                          TicketCard(
                            eventName: "Event name",
                            date: "20.6.2023",
                            time: "22:00",
                            ticketCount: 3,
                            distance: "150KM",
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
                        ],
                      )
                    : const EmptyTicketsState())
                : const EmptyTicketsState(),
          ),
        ],
      ),
    );
  }
}
