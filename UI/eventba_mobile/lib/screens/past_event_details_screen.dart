import 'dart:convert';
import 'package:eventba_mobile/screens/event_reviews_screen.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/providers/event_review_provider.dart';
import 'package:eventba_mobile/models/event/event.dart';
import 'package:eventba_mobile/models/event_review/event_review.dart';
import 'package:eventba_mobile/utils/image_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PastEventDetailsScreen extends StatefulWidget {
  final String eventId;

  const PastEventDetailsScreen({super.key, required this.eventId});

  @override
  State<PastEventDetailsScreen> createState() => _PastEventDetailsScreenState();
}

class _PastEventDetailsScreenState extends State<PastEventDetailsScreen> {
  Event? _event;
  List<EventReview> _reviews = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final reviewProvider = Provider.of<EventReviewProvider>(
        context,
        listen: false,
      );

      final event = await eventProvider.getById(widget.eventId);

      Map<String, dynamic>? statistics;
      try {
        statistics = await eventProvider.getEventStatistics(widget.eventId);
      } catch (e) {}

      List<EventReview> reviews = [];
      try {
        reviews = await reviewProvider.getReviewsForEvent(widget.eventId);
      } catch (e) {}

      setState(() {
        _event = event;
        _statistics = statistics;
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MasterScreenWidget(
        initialIndex: -1,
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
        initialIndex: -1,
        appBarType: AppBarType.iconsSideTitleCenter,
        title: "Event Details",
        leftIcon: Icons.arrow_back,
        onLeftButtonPressed: () {
          Navigator.pop(context);
        },
        child: const Center(child: Text('Event not found')),
      );
    }
    final totalAttendees =
        _statistics?['attendees'] ?? _event!.currentAttendees;

    return MasterScreenWidget(
      initialIndex: -1,
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
                                    const SizedBox(height: 8),
                                    _buildDetailItem(
                                      Icons.category,
                                      _event!.category.name,
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
                    const Divider(),
                    const SizedBox(height: 16),

                    _buildActionButton(
                      context,
                      "Reviews (${_reviews.length})",
                      Icons.reviews,
                      Colors.redAccent,
                      () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => EventReviewsScreen(
                              eventTitle: _event!.title,
                              eventId: widget.eventId,
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(int initialIndex) {
    if (_event == null) return;

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
}
