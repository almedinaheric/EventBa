import 'package:eventba_mobile/screens/buy_ticket_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/organizer_section.dart';
import 'package:eventba_mobile/widgets/ticket_option.dart';
import 'package:eventba_mobile/widgets/primary_button.dart'; // Ensure this is your custom button widget

class EventDetailsScreen extends StatefulWidget {
  final String eventTitle;

  const EventDetailsScreen({super.key, required this.eventTitle});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool isFollowing = false;
  bool isFavorited = false;
  final List<String> imageUrls = [
    'assets/images/default_event_cover_image.png',
    'assets/images/default_event_cover_image.png',
    'assets/images/default_event_cover_image.png',
  ];

  void _showImageDialog(int initialIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: PageView.builder(
                  controller: PageController(initialPage: initialIndex),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      imageUrls[index],
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showQuestionDialog() async {
    final TextEditingController questionController = TextEditingController();
    final size = MediaQuery.of(context).size;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Ask a question",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: size.width * 0.9,
            child: TextField(
              controller: questionController,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Enter your question here",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    text: "Cancel",
                    width: size.width * 0.3,
                    outlined: true,
                    small: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    text: "Send",
                    width: size.width * 0.3,
                    small: true,
                    onPressed: () {
                      if (questionController.text.trim().isNotEmpty) {
                        // TODO: send question to backend or add to local list
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Question sent successfully.")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      appBarType: AppBarType.iconsSideTitleCenter,
      title: widget.eventTitle,
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () => Navigator.pop(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: screenWidth * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Event Image Carousel
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showImageDialog(index),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: AssetImage(imageUrls[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Details Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                        const SizedBox(height: 12),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailItem(Icons.location_on, "Location"),
                                    const SizedBox(height: 8),
                                    _buildDetailItem(Icons.calendar_today, "Date"),
                                    const SizedBox(height: 8),
                                    _buildDetailItem(Icons.access_time, "Time"),
                                  ],
                                ),
                              ),
                              Container(width: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: Colors.grey.withOpacity(0.3)),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5B7CF6),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text("Music", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                                  ),
                                ),
                              ),
                              Container(width: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: Colors.grey.withOpacity(0.3)),
                              const Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Tickets left", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    SizedBox(height: 4),
                                    Text("10", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const OrganizerSection(),

                    const SizedBox(height: 24),

                    const Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(height: 8),
                    const Text(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                      style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                    ),
                    const SizedBox(height: 4),
                    const Text("Read more...", style: TextStyle(fontSize: 14, color: Color(0xFF5B7CF6), fontWeight: FontWeight.w500)),

                    const SizedBox(height: 24),

                    const Text("Tickets", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(height: 12),
                    const TicketOption(type: "VIP", price: "50KM"),
                    const SizedBox(height: 8),
                    const TicketOption(type: "ECONOMY", price: "20KM"),

                    const SizedBox(height: 16),

                    // "Have a Question?" Button
                    InkWell(
                      onTap: _showQuestionDialog,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF5B7CF6)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Have a question?",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF5B7CF6), fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Buy Ticket Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const BuyTicketScreen(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B7CF6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Buy Ticket",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 56),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
