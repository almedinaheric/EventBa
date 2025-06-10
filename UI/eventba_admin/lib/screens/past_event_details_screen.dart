import 'package:eventba_admin/screens/event_reviews_screen.dart';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';

class PastEventDetailsScreen extends StatefulWidget {
  final String eventTitle;
  final Map<String, dynamic> eventData;

  const PastEventDetailsScreen({
    super.key,
    required this.eventTitle,
    required this.eventData,
  });

  @override
  State<PastEventDetailsScreen> createState() => _PastEventDetailsScreenState();
}

class _PastEventDetailsScreenState extends State<PastEventDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      initialIndex: -1,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: widget.eventTitle,
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
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
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/default_event_cover_image.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
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
                                    const SizedBox(height: 8),
                                    _buildDetailItem(Icons.category, "Category"),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              const Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Total attendees",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "10",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    _buildActionButton(
                      context,
                      "Reviews",
                      Icons.reviews,
                      Colors.redAccent,
                          () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => EventReviewsScreen(
                              eventTitle: widget.eventTitle,
                            ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
    );
  }
}
