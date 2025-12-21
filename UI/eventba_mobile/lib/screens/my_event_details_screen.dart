import 'dart:convert';
import 'package:eventba_mobile/screens/edit_event_screen.dart';
import 'package:eventba_mobile/screens/event_questions_screen.dart';
import 'package:eventba_mobile/screens/event_reviews_screen.dart';
import 'package:eventba_mobile/screens/event_statistics_screen.dart';
import 'package:eventba_mobile/screens/ticket_scanner_screen.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/providers/event_review_provider.dart';
import 'package:eventba_mobile/providers/user_provider.dart';
import 'package:eventba_mobile/models/event/event.dart';
import 'package:eventba_mobile/models/event_review/event_review.dart';
import 'package:eventba_mobile/utils/image_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyEventDetailsScreen extends StatefulWidget {
  final String eventId;

  const MyEventDetailsScreen({super.key, required this.eventId});

  @override
  State<MyEventDetailsScreen> createState() => _MyEventDetailsScreenState();
}

class _MyEventDetailsScreenState extends State<MyEventDetailsScreen> {
  Event? _event;
  Map<String, dynamic>? _statistics;
  List<EventReview> _reviews = [];
  bool _isLoading = true;
  bool _isPast = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _loadEventData();
  }

  Future<void> _checkUserRole() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = await userProvider.getProfile();
      setState(() {
        _isAdmin = user.role.name.toLowerCase() == 'admin';
      });
    } catch (e) {
      print("Failed to check user role: $e");
    }
  }

  Future<void> _loadEventData() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final reviewProvider = Provider.of<EventReviewProvider>(
        context,
        listen: false,
      );

      // Load event details
      final event = await eventProvider.getById(widget.eventId);

      // Check if event is past (using end date/time)
      final eventEndDateTime = DateTime.parse(
        '${event.endDate} ${event.endTime}',
      );
      final isPast = eventEndDateTime.isBefore(DateTime.now());

      // Load event statistics (for upcoming events, this returns revenue and tickets sold from ticket purchases)
      Map<String, dynamic>? statistics;
      try {
        statistics = await eventProvider.getEventStatistics(widget.eventId);
        print("Loaded statistics for event ${widget.eventId}: $statistics");
      } catch (e) {
        print("Failed to load statistics: $e");
      }

      // Load event reviews only if event is past
      List<EventReview> reviews = [];
      if (isPast) {
        try {
          reviews = await reviewProvider.getReviewsForEvent(widget.eventId);
        } catch (e) {
          print("Failed to load reviews: $e");
        }
      }

      setState(() {
        _event = event;
        _statistics = statistics;
        _reviews = reviews;
        _isPast = isPast;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading event data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  void _showImageDialog(int initialIndex) {
    if (_event == null) return;

    // Build list of images: cover image first, then gallery images
    List<String> allImages = [];

    if (_event!.coverImage?.data != null) {
      allImages.add(_event!.coverImage!.data!);
    }
    if (_event!.galleryImages != null) {
      for (var galleryImage in _event!.galleryImages!) {
        if (galleryImage.data != null) {
          allImages.add(galleryImage.data!);
        }
      }
    }

    if (allImages.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext dialogContext) {
        final pageController = PageController(initialPage: initialIndex);
        int currentIndex = initialIndex;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(0),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: allImages.length,
                    physics: const PageScrollPhysics(),
                    onPageChanged: (index) {
                      setDialogState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imageData = allImages[index];
                      try {
                        String base64String = imageData;
                        if (imageData.startsWith('data:image')) {
                          base64String = imageData.split(',').last;
                        }
                        return InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          panEnabled: false,
                          scaleEnabled: true,
                          child: Center(
                            child: Image.memory(
                              base64Decode(base64String),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/default_event_cover_image.png',
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ),
                        );
                      } catch (e) {
                        return Center(
                          child: Image.asset(
                            'assets/images/default_event_cover_image.png',
                            fit: BoxFit.contain,
                          ),
                        );
                      }
                    },
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        pageController.dispose();
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ),
                  if (allImages.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${currentIndex + 1} / ${allImages.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> _buildEventData() {
    if (_event == null) return {};
    return {
      'id': _event!.id,
      'name': _event!.title,
      'category': _event!.category.name,
      'categoryId': _event!.category.id,
      'venue': _event!.location,
      'date': _event!.startDate,
      'startDate': _event!.startDate,
      'endDate': _event!.endDate,
      'startTime': _event!.startTime,
      'endTime': _event!.endTime,
      'description': _event!.description,
      'capacity': _event!.capacity,
      'currentAttendees': _event!.currentAttendees,
      'isPaid': _event!.isPaid,
      'status': _event!.status.toString(),
      'type': _event!.type.toString(),
      'isFeatured': _event!.isFeatured,
      'coverImage': _event!.coverImage?.data,
      'coverImageId': _event!.coverImage?.id,
      'galleryImages': _event!.galleryImages?.map((img) => img.data).toList(),
      'galleryImageIds': _event!.galleryImages?.map((img) => img.id).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MasterScreenWidget(
        initialIndex: 4,
        appBarType: AppBarType.iconsSideTitleCenter,
        title: "Event Details",
        leftIcon: Icons.arrow_back,
        onLeftButtonPressed: () {
          Navigator.pop(context);
        },
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return MasterScreenWidget(
        initialIndex: 4,
        appBarType: AppBarType.iconsSideTitleCenter,
        title: "Event Details",
        leftIcon: Icons.arrow_back,
        onLeftButtonPressed: () {
          Navigator.pop(context);
        },
        child: const Center(child: Text('Event not found')),
      );
    }

    // Admin view - only Scan QR Code button
    if (_isAdmin) {
      return MasterScreenWidget(
        initialIndex: 4,
        showBottomNavBar: false, // Hide bottom nav for admin
        appBarType: AppBarType.iconsSideTitleCenter,
        title: _event!.title,
        leftIcon: Icons.arrow_back,
        onLeftButtonPressed: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: _buildActionButton(
                context,
                "Scan QR Code",
                Icons.qr_code_scanner,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => TicketScannerScreen(
                        eventId: widget.eventId,
                        eventData: _buildEventData(),
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    // Customer view - full details
    final totalAttendees =
        _statistics?['attendees'] ?? _event!.currentAttendees;

    return MasterScreenWidget(
      initialIndex: 4,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: _event!.title,
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
                    // Event cover image
                    GestureDetector(
                      onTap: () => _showImageDialog(0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _event!.coverImage?.data != null
                            ? ImageHelpers.getImage(
                                _event!.coverImage!.data,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/default_event_cover_image.png',
                                height: 200,
                                width: double.infinity,
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
                                    _buildDetailItem(
                                      Icons.location_on,
                                      _event!.location,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetailItem(
                                      Icons.calendar_today,
                                      _formatDate(_event!.startDate),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetailItem(
                                      Icons.access_time,
                                      _formatTime(_event!.startTime),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Total attendees",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      totalAttendees.toString(),
                                      style: const TextStyle(
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
                    // Show short stats for upcoming events
                    if (!_isPast) ...[
                      _buildShortStats(),
                      const SizedBox(height: 16),
                    ],
                    const Divider(),
                    const SizedBox(height: 16),
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        if (!_isPast)
                          _buildActionButton(
                            context,
                            "Scan Tickets",
                            Icons.qr_code_scanner,
                            Colors.green,
                            () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      TicketScannerScreen(
                                        eventId: widget.eventId,
                                        eventData: _buildEventData(),
                                      ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                          ),
                        if (!_isPast)
                          _buildActionButton(
                            context,
                            "Edit Event Details",
                            Icons.edit,
                            Colors.blue,
                            () async {
                              final result = await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      EditEventScreen(event: _buildEventData()),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                              if (result == true && mounted) {
                                await _loadEventData();
                              }
                            },
                          ),
                        _buildActionButton(
                          context,
                          "Questions",
                          Icons.question_answer,
                          Colors.orange,
                          () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    EventQuestionsScreen(
                                      eventId: widget.eventId,
                                      eventData: _buildEventData(),
                                    ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        ),
                        // Only show Statistics button for past events
                        if (_isPast)
                          _buildActionButton(
                            context,
                            "Statistics",
                            Icons.bar_chart,
                            Colors.purple,
                            () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      EventStatisticsScreen(
                                        eventId: widget.eventId,
                                        eventData: _buildEventData(),
                                      ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                          ),
                        if (_isPast)
                          _buildActionButton(
                            context,
                            "Reviews (${_reviews.length})",
                            Icons.reviews,
                            Colors.redAccent,
                            () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      EventReviewsScreen(
                                        eventTitle: _event!.title,
                                        eventId: widget.eventId,
                                      ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                          ),
                      ],
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
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortStats() {
    // Revenue: sum of all PricePaid from ticket purchases for this event
    // Tickets Sold: count of all ticket purchases for this event
    // Both are calculated in backend GetEventStatistics for upcoming events
    // Backend returns: TotalRevenue (camelCase: totalRevenue) and TotalTicketsSold (camelCase: totalTicketsSold)
    final revenue =
        (_statistics?['totalRevenue'] ??
                _statistics?['TotalRevenue'] ??
                _statistics?['revenue'] ??
                0.0)
            .toDouble();
    final ticketsSold =
        (_statistics?['totalTicketsSold'] ??
                _statistics?['TotalTicketsSold'] ??
                _statistics?['ticketsSold'] ??
                0)
            as int;
    final ticketsLeft = _event!.availableTicketsCount;

    print("Quick Stats Debug - Statistics map: $_statistics");
    print(
      "Quick Stats - Revenue: $revenue, Tickets Sold: $ticketsSold, Tickets Left: $ticketsLeft",
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Stats",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Revenue",
                  "\$${revenue.toStringAsFixed(2)}",
                  Icons.attach_money,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.blue.shade200),
              Expanded(
                child: _buildStatItem(
                  "Tickets Sold",
                  ticketsSold.toString(),
                  Icons.confirmation_number,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.blue.shade200),
              Expanded(
                child: _buildStatItem(
                  "Tickets Left",
                  ticketsLeft.toString(),
                  Icons.event_available,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
