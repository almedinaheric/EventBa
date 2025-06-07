import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/organizer_section.dart';
import 'package:eventba_mobile/widgets/ticket_qr_code.dart';
import 'package:eventba_mobile/widgets/ticket_info_field.dart';
import 'package:eventba_mobile/widgets/ticket_type_badge.dart';
import 'package:flutter/material.dart';

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({super.key});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  bool showQR = false;
  bool isFollowing = false; // Track follow state

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return MasterScreenWidget(
      initialIndex: 3,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Ticket details",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context); // Back button functionality
      },
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Center(
                child: Container(
                  width: screenWidth * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/default_event_cover_image.png',
                          height: 160,
                          width: double.infinity, // takes full container width
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Event details
                      const Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TicketInfoField(
                                  label: "Name",
                                  value: "Event name",
                                ),
                              ),
                              Spacer(flex: 1),
                              Expanded(
                                child: TicketInfoField(
                                  label: "Location",
                                  value: "Address",
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TicketInfoField(
                                  label: "Date",
                                  value: "20.6.2023",
                                ),
                              ),
                              Spacer(flex: 1),
                              Expanded(
                                child: TicketInfoField(
                                  label: "Time",
                                  value: "22:00",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const OrganizerSection(
                                  organizerId: 1,
                                  bio: "hey",
                                  imageUrl: 'assets/images/profile_placeholder.png',
                                  name: "Dylan Malik",
                                ),



                      SizedBox(height: 16),

                      const Text(
                        "You have purchased 2 tickets for this event. To view the QR code for each ticket, simply click on the blue button below.",
                        style: TextStyle(fontSize: 14, height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 24),

                      TicketTypeBadge(
                        type: "VIP",
                        price: "50KM",
                        onShowQR: () {
                          setState(() {
                            showQR = true;
                          });
                        },
                      ),
                      TicketTypeBadge(
                        type: "ECONOMY",
                        price: "25KM",
                        onShowQR: () {
                          setState(() {
                            showQR = true;
                          });
                        },
                      ),

                      const SizedBox(height: 60), // bottom spacing
                    ],
                  ),
                ),
              ),
            ],
          ),

          // QR Code overlay
          if (showQR)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: TicketQRCode(
                  ticketCode: "ASD839HLK",
                  onClose: () {
                    setState(() {
                      showQR = false;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}