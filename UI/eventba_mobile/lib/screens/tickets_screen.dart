import 'package:flutter/material.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  var isUpcomingSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          isUpcomingSelected
                              ? const Color(0xFF4776E6)
                              : Colors.white,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          isUpcomingSelected
                              ? Colors.white
                              : const Color(0xFF4776E6),
                        ),
                        side: WidgetStateProperty.all(BorderSide(
                          color: !isUpcomingSelected
                              ? const Color(0xFF4776E6)
                              : Colors.white,
                        ))),
                    onPressed: () {
                      setState(() {
                        isUpcomingSelected = true; // Set Upcoming as selected
                      });
                    },
                    child: const Text(
                      'Upcoming',
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          !isUpcomingSelected
                              ? const Color(0xFF4776E6)
                              : Colors.white,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          !isUpcomingSelected
                              ? Colors.white
                              : const Color(0xFF4776E6),
                        ),
                        side: WidgetStateProperty.all(BorderSide(
                          color: isUpcomingSelected
                              ? const Color(0xFF4776E6)
                              : Colors.white,
                        ))),
                    onPressed: () {
                      setState(() {
                        isUpcomingSelected = false; // Set Past as selected
                      });
                    },
                    child: const Text('Past'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: [
                  if (isUpcomingSelected) ...[
                    // Show ticket cards if Upcoming is selected
                    const _TicketCard(
                      eventName: 'Event Name',
                      date: '20.6.2023, 22:00 - 3:00',
                      tickets: 1,
                      distance: 50,
                    ),
                    const _TicketCard(
                      eventName: 'Another Event',
                      date: '21.6.2023, 18:00 - 21:00',
                      tickets: 2,
                      distance: 30,
                    ),
                    const _TicketCard(
                      eventName: 'Yet Another Event',
                      date: '22.6.2023, 20:00 - 23:00',
                      tickets: 3,
                      distance: 10,
                    ),
                  ] else ...[
                    // Center the placeholder text
                    const Center(
                      child: Text(
                        'Looks like you haven\'t attended any events yet!\nKeep an eye out for upcoming events that interest you and purchase your tickets here. Your past tickets will be saved in this section for future reference.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final String eventName;
  final String date;
  final int tickets;
  final int distance;

  const _TicketCard({
    required this.eventName,
    required this.date,
    required this.tickets,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(date),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tickets: $tickets'),
                Text('$distance KM'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
