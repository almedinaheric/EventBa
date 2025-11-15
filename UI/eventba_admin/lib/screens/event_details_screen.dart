import 'dart:convert';
import 'package:eventba_admin/screens/edit_event_screen.dart';
import 'package:eventba_admin/screens/user_details_screen.dart';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/providers/event_provider.dart';
import 'package:eventba_admin/providers/event_review_provider.dart';
import 'package:eventba_admin/providers/ticket_provider.dart';
import 'package:eventba_admin/providers/user_provider.dart';
import 'package:eventba_admin/models/event/event.dart';
import 'package:eventba_admin/models/event_review/event_review.dart';
import 'package:eventba_admin/models/event_statistics/event_statistics.dart';
import 'package:eventba_admin/models/ticket/ticket.dart';
import 'package:eventba_admin/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String eventTitle;
  final bool isPublic;
  final bool isPastEvent;

  const EventDetailsScreen({
    super.key,
    required this.eventTitle,
    this.isPublic = true,
    this.isPastEvent = false,
    required this.eventData,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isLoading = false;
  late Map<String, dynamic> _currentEventData;
  List<EventReview> _reviews = [];
  EventStatistics? _statistics;
  List<Ticket> _tickets = [];
  User? _organizer;
  bool _reviewsLoading = false;
  bool _statisticsLoading = false;
  bool _ticketsLoading = false;
  bool _organizerLoading = false;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentEventData = widget.eventData;

    // Load organizer details
    _loadOrganizer();

    // Load tickets if event is paid
    if (_currentEventData['isPaid'] == true) {
      _loadTickets();
    }

    if (widget.isPublic && widget.isPastEvent) {
      _loadReviews();
      _loadStatistics();
    }
  }

  Future<void> _loadOrganizer() async {
    if (_currentEventData['organizerId'] == null) return;

    setState(() {
      _organizerLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final organizer = await userProvider.getUserById(
        _currentEventData['organizerId'],
      );
      setState(() {
        _organizer = organizer;
        _organizerLoading = false;
      });
    } catch (e) {
      print("Error loading organizer: $e");
      setState(() {
        _organizerLoading = false;
      });
    }
  }

  Future<void> _loadTickets() async {
    if (_currentEventData['id'] == null) return;

    setState(() {
      _ticketsLoading = true;
    });

    try {
      final ticketProvider = Provider.of<TicketProvider>(
        context,
        listen: false,
      );
      final tickets = await ticketProvider.getTicketsForEvent(
        _currentEventData['id'],
      );
      setState(() {
        _tickets = tickets;
        _ticketsLoading = false;
      });
    } catch (e) {
      print("Error loading tickets: $e");
      setState(() {
        _ticketsLoading = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    if (_currentEventData['id'] == null) return;

    setState(() {
      _reviewsLoading = true;
    });

    try {
      final reviewProvider = Provider.of<EventReviewProvider>(
        context,
        listen: false,
      );
      final reviews = await reviewProvider.getReviewsForEvent(
        _currentEventData['id'],
      );
      setState(() {
        _reviews = reviews;
        _reviewsLoading = false;
      });
    } catch (e) {
      print("Error loading reviews: $e");
      setState(() {
        _reviewsLoading = false;
      });
    }
  }

  Future<void> _loadStatistics() async {
    if (_currentEventData['id'] == null) return;

    setState(() {
      _statisticsLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final stats = await eventProvider.getEventStatistics(
        _currentEventData['id'],
      );
      setState(() {
        _statistics = EventStatistics.fromJson(stats);
        _statisticsLoading = false;
      });
    } catch (e) {
      print("Error loading statistics: $e");
      setState(() {
        _statisticsLoading = false;
      });
    }
  }

  Future<void> _reloadEventData() async {
    if (_currentEventData['id'] == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final Event updatedEvent = await eventProvider.getEventById(
        _currentEventData['id'],
      );

      setState(() {
        _currentEventData = {
          'id': updatedEvent.id,
          'name': updatedEvent.title,
          'category': updatedEvent.category?.name ?? 'Uncategorized',
          'categoryId': updatedEvent.category?.id ?? '',
          'venue': updatedEvent.location,
          'date': updatedEvent.startDate,
          'startTime': updatedEvent.startTime,
          'endTime': updatedEvent.endTime,
          'startDate': updatedEvent.startDate,
          'endDate': updatedEvent.endDate,
          'description': updatedEvent.description,
          'isPaid': updatedEvent.isPaid,
          'status': updatedEvent.status.name,
          'type': updatedEvent.type.name,
          'coverImage': updatedEvent.coverImage,
          'organizerId': updatedEvent.organizerId,
          'capacity': updatedEvent.capacity,
          'currentAttendees': updatedEvent.currentAttendees,
          'availableTicketsCount': updatedEvent.availableTicketsCount,
        };

        // Load real images
        _imageUrls = [];
        if (updatedEvent.coverImage != null) {
          _imageUrls.add(updatedEvent.coverImage!);
        }
        // Add gallery images (they are already base64 strings)
        _imageUrls.addAll(updatedEvent.galleryImages);
        // Fallback to default image if no images
        if (_imageUrls.isEmpty) {
          _imageUrls.add('assets/images/default_event_cover_image.png');
        }

        _isLoading = false;
      });

      // Reload organizer
      _loadOrganizer();

      // Reload tickets if event is paid
      if (_currentEventData['isPaid'] == true) {
        _loadTickets();
      }

      // Reload reviews and statistics if applicable
      if (widget.isPublic && widget.isPastEvent) {
        _loadReviews();
        _loadStatistics();
      }
    } catch (e) {
      print("Error reloading event data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _imageUrls = [];

  void _showImageDialog(int initialIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: PageView.builder(
                  controller: PageController(initialPage: initialIndex),
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) {
                    return _buildImageWidget(_imageUrls[index], BoxFit.contain);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(String imageData, BoxFit fit) {
    // Check if it's a base64 image
    if (imageData.startsWith('data:image')) {
      final base64String = imageData.split(',').last;
      return Image.memory(
        base64Decode(base64String),
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/default_event_cover_image.png',
            fit: fit,
          );
        },
      );
    } else {
      // It's an asset path
      return Image.asset(imageData, fit: fit);
    }
  }

  Future<void> _deleteEvent() async {
    if (_currentEventData['id'] == null) return;

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.deleteEvent(_currentEventData['id']);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event removed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to events list
      Navigator.pop(context, true); // Return true to indicate deletion
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRemoveEventDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Event'),
          content: const Text(
            'Are you sure you want to remove this event? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _deleteEvent(); // Delete the event
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MasterScreen(
        title: widget.eventTitle,
        showBackButton: true,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return MasterScreen(
      title: _currentEventData['name'] ?? widget.eventTitle,
      showBackButton: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: screenWidth > 800 ? 800 : screenWidth * 0.9,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Image Carousel
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          height: constraints.maxWidth > 600 ? 250 : 200,
                          child: PageView.builder(
                            itemCount: _imageUrls.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _showImageDialog(index),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _buildImageWidget(
                                    _imageUrls[index],
                                    BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Event Header
                    _buildEventHeader(),

                    const SizedBox(height: 24),

                    // Details Section
                    _buildEventDetails(),

                    const SizedBox(height: 24),

                    // Organizer Section (only for private events)
                    if (!widget.isPublic) ...[
                      _buildOrganizerSection(),
                      const SizedBox(height: 24),
                    ],

                    // Description
                    _buildDescription(),

                    const SizedBox(height: 24),

                    // Tickets Section
                    // Tickets (only for paid events)
                    if (_currentEventData['isPaid'] == true) ...[
                      _buildTicketsSection(),
                      const SizedBox(height: 24),
                    ],

                    // Reviews and Statistics (only for past public events)
                    if (widget.isPublic && widget.isPastEvent) ...[
                      const SizedBox(height: 24),
                      _buildStatisticsSection(),
                      const SizedBox(height: 24),
                      _buildReviewsSection(),
                    ],

                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(
                      isPublic: widget.isPublic,
                      isPastEvent: widget.isPastEvent,
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

  Widget _buildEventHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _currentEventData['name'] ?? 'Event name',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        if (!widget.isPublic)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Private',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (widget.isPastEvent)
          Container(
            margin: EdgeInsets.only(left: !widget.isPublic ? 8 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Past Event',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Details",
          style: TextStyle(
            fontSize: 18,
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
                      "Location",
                      _currentEventData['venue'] ?? 'N/A',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailItem(
                      Icons.calendar_today,
                      "Date",
                      _currentEventData['date'] ?? 'N/A',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailItem(
                      Icons.access_time,
                      "Time",
                      "${_currentEventData['startTime'] ?? 'N/A'} - ${_currentEventData['endTime'] ?? 'N/A'}",
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.grey.withOpacity(0.3),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4776E6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _currentEventData['category'] ?? "Category",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.grey.withOpacity(0.3),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Capacity",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentEventData['capacity'] ?? 0}',
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
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizerSection() {
    final organizerId = _currentEventData['organizerId'];

    return GestureDetector(
      onTap: organizerId != null && _organizer != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailsScreen(userId: organizerId),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _organizerLoading
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _organizer?.profileImage?.data != null
                        ? MemoryImage(
                            Uri.parse(
                              _organizer!.profileImage!.data!,
                            ).data!.contentAsBytes(),
                          )
                        : null,
                    child: _organizer?.profileImage?.data == null
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Organized by',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          _organizer?.fullName ?? "Loading...",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDescription() {
    final description =
        _currentEventData['description'] ?? 'No description available.';
    const int maxLength = 150;
    final bool isLongDescription = description.length > maxLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isDescriptionExpanded || !isLongDescription
              ? description
              : '${description.substring(0, maxLength)}...',
          style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
        ),
        if (isLongDescription) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Text(
              _isDescriptionExpanded ? "Show less" : "Read more",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4776E6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTicketsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tickets",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        if (_ticketsLoading)
          const Center(child: CircularProgressIndicator())
        else if (_tickets.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No tickets available',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          )
        else
          Column(
            children: _tickets.map((ticket) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildTicketOption(
                  ticket.ticketType.toUpperCase(),
                  '${ticket.price.toStringAsFixed(2)} KM',
                  ticket.quantityAvailable,
                  ticket.quantitySold,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTicketOption(
    String type,
    String price,
    int available,
    int sold,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4776E6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available: $available',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Sold: $sold',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Statistics",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _statisticsLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "${_statistics?.totalTicketsSold ?? 0}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4776E6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Tickets Sold",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 40, width: 1, color: Colors.grey[300]),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "${_statistics?.totalRevenue.toStringAsFixed(2) ?? '0.00'} KM",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Total Earned",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 40, width: 1, color: Colors.grey[300]),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _statistics?.averageRating.toStringAsFixed(1) ??
                                "0.0",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Avg Rating",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Reviews",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              "${_reviews.length} reviews",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _reviewsLoading
            ? const Center(child: CircularProgressIndicator())
            : _reviews.isEmpty
            ? const Text("No reviews yet.")
            : Column(
                children: _reviews
                    .map((review) => _buildReviewItem(review))
                    .toList(),
              ),
      ],
    );
  }

  String _getReviewerName(EventReview review) {
    if (review.user?.fullName != null && review.user!.fullName!.isNotEmpty) {
      return review.user!.fullName!;
    }

    final firstName = review.user?.firstName ?? '';
    final lastName = review.user?.lastName ?? '';
    final fullName = "$firstName $lastName".trim();

    return fullName.isNotEmpty ? fullName : "Anonymous";
  }

  Widget _buildReviewItem(EventReview review) {
    // Format date
    String formattedDate = "N/A";
    try {
      final date = DateTime.parse(review.createdAt);
      formattedDate = DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      print("Error parsing date: $e");
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: const Icon(Icons.person, size: 16, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getReviewerName(review),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment ?? "No comment",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons({bool isPublic = true, bool isPastEvent = false}) {
    return Column(
      children: [
        // Conditional rendering for Edit Event Button
        if (isPublic && !isPastEvent)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Navigate to edit event screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditEventScreen(event: _currentEventData),
                  ),
                );

                // Reload data if edit was successful
                if (result == true) {
                  await _reloadEventData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4776E6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Edit Event',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (isPublic && !isPastEvent)
          const SizedBox(height: 12), // Add spacing conditionally
        // Conditional rendering for Remove Event Button
        if (!isPastEvent)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _showRemoveEventDialog,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Remove Event',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
