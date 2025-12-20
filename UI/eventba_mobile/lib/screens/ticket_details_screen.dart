import 'dart:convert';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/organizer_section.dart';
import 'package:eventba_mobile/widgets/ticket_qr_code.dart';
import 'package:eventba_mobile/widgets/ticket_info_field.dart';
import 'package:eventba_mobile/widgets/ticket_type_badge.dart';
import 'package:eventba_mobile/widgets/add_review_dialog.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/utils/image_helpers.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/providers/ticket_provider.dart';
import 'package:eventba_mobile/providers/user_provider.dart';
import 'package:eventba_mobile/providers/event_review_provider.dart';
import 'package:eventba_mobile/models/event/event.dart';
import 'package:eventba_mobile/models/ticket/ticket.dart';
import 'package:eventba_mobile/models/ticket_purchase/ticket_purchase.dart';
import 'package:eventba_mobile/models/user/user.dart';
import 'package:eventba_mobile/models/event_review/event_review.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TicketDetailsScreen extends StatefulWidget {
  final String eventId;
  final List<TicketPurchase> purchases;

  const TicketDetailsScreen({
    super.key,
    required this.eventId,
    required this.purchases,
  });

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  Event? _event;
  User? _organizer;
  User? _currentUser;
  Map<String, Ticket> _tickets = {};
  Map<String, List<TicketPurchase>> _purchasesByTicketId = {};
  EventReview? _userReview;
  bool _isLoading = true;
  String? _selectedQRCode;
  String? _selectedTicketCode;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final ticketProvider = Provider.of<TicketProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Load event
      final event = await eventProvider.getById(widget.eventId);

      // Load tickets for the event
      final tickets = await ticketProvider.getTicketsForEvent(widget.eventId);
      final ticketsMap = {for (var t in tickets) t.id: t};

      // Group purchases by ticket ID
      final purchasesByTicketId = <String, List<TicketPurchase>>{};
      for (final purchase in widget.purchases) {
        purchasesByTicketId
            .putIfAbsent(purchase.ticketId, () => [])
            .add(purchase);
      }

      // Load organizer
      User? organizer;
      try {
        organizer = await userProvider.getById(event.organizerId);
      } catch (e) {
        print("Failed to load organizer: $e");
      }

      // Load current user profile
      User? currentUser;
      try {
        currentUser = await userProvider.getProfile();
      } catch (e) {
        print("Failed to load current user: $e");
      }

      // Load user's review if event is past
      EventReview? userReview;
      if (currentUser != null) {
        try {
          final reviewProvider = Provider.of<EventReviewProvider>(
            context,
            listen: false,
          );
          userReview = await reviewProvider.getUserReviewForEvent(
            eventId: widget.eventId,
            userId: currentUser.id,
          );
        } catch (e) {
          print("Error loading user review: $e");
          // User hasn't reviewed yet, that's fine
          userReview = null;
        }
      }

      setState(() {
        _event = event;
        _tickets = ticketsMap;
        _purchasesByTicketId = purchasesByTicketId;
        _organizer = organizer;
        _currentUser = currentUser;
        _userReview = userReview;
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to load ticket details: $e");
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
      // Time is in format "HH:mm:ss" or "HH:mm"
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  bool _isEventPast() {
    if (_event == null) return false;
    try {
      final eventStartDateTime = DateTime.parse(
        '${_event!.startDate} ${_event!.startTime}',
      );
      return eventStartDateTime.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  Widget _buildUserReviewCard() {
    if (_userReview == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Your Review",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                _formatReviewDate(_userReview!.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 20,
                color: index < _userReview!.rating
                    ? Colors.amber
                    : Colors.grey[300],
              );
            }),
          ),
          if (_userReview!.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _userReview!.comment,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  Future<void> _showAddReviewDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AddReviewDialog(
          eventTitle: _event?.title ?? '',
          onSubmit: (rating, comment) async {
            try {
              final reviewProvider = Provider.of<EventReviewProvider>(
                context,
                listen: false,
              );
              final newReview = await reviewProvider.createReview(
                eventId: widget.eventId,
                rating: rating,
                comment: comment,
              );
              if (mounted) {
                setState(() {
                  _userReview = newReview;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text("Review submitted successfully!"),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text("Failed to submit review: ${e.toString()}"),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading || _event == null) {
      return MasterScreenWidget(
        initialIndex: 3,
        appBarType: AppBarType.iconsSideTitleCenter,
        title: "Ticket details",
        leftIcon: Icons.arrow_back,
        onLeftButtonPressed: () {
          Navigator.pop(context);
        },
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return MasterScreenWidget(
      initialIndex: 3,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Ticket details",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
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
                        child: _event!.coverImage?.data != null
                            ? ImageHelpers.getImage(
                                _event!.coverImage!.data,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/default_event_cover_image.png',
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Event details
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TicketInfoField(
                                  label: "Name",
                                  value: _event!.title,
                                ),
                              ),
                              const Spacer(flex: 1),
                              Expanded(
                                child: TicketInfoField(
                                  label: "Location",
                                  value: _event!.location,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TicketInfoField(
                                  label: "Date",
                                  value: _formatDate(_event!.startDate),
                                ),
                              ),
                              const Spacer(flex: 1),
                              Expanded(
                                child: TicketInfoField(
                                  label: "Time",
                                  value: _formatTime(_event!.startTime),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Organizer section
                      if (_organizer != null)
                        OrganizerSection(
                          organizerId: _organizer!.id,
                          bio: _organizer!.bio ?? '',
                          imageUrl:
                              _organizer!.profileImage?.data ??
                              'assets/images/profile_placeholder.png',
                          name:
                              "${_organizer!.firstName} ${_organizer!.lastName}",
                          isFollowing:
                              _currentUser != null &&
                              _currentUser!.following.any(
                                (u) => u.id == _organizer!.id,
                              ),
                        ),

                      const SizedBox(height: 16),

                      Text(
                        "You have purchased ${widget.purchases.length} ticket${widget.purchases.length > 1 ? 's' : ''} for this event. To view the QR code for each ticket, simply click on the blue button below.",
                        style: const TextStyle(fontSize: 14, height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 24),

                      // Display tickets grouped by ticket type
                      ..._purchasesByTicketId.entries.map((entry) {
                        final ticketId = entry.key;
                        final purchases = entry.value;
                        final ticket = _tickets[ticketId];

                        if (ticket == null) return const SizedBox.shrink();

                        return Column(
                          children: purchases.map((purchase) {
                            return TicketTypeBadge(
                              type: ticket.ticketType,
                              price: "${ticket.price.toStringAsFixed(2)}KM",
                              onShowQR: () {
                                setState(() {
                                  _selectedQRCode = purchase.qrCodeImage != null
                                      ? base64Encode(purchase.qrCodeImage!)
                                      : null;
                                  _selectedTicketCode = purchase.ticketCode;
                                });
                              },
                            );
                          }).toList(),
                        );
                      }).toList(),

                      const SizedBox(height: 24),

                      // Show user's review or Add Review button for past events
                      if (_isEventPast())
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _userReview != null
                              ? _buildUserReviewCard()
                              : PrimaryButton(
                                  text: "Add Review",
                                  onPressed: () {
                                    _showAddReviewDialog(context);
                                  },
                                ),
                        ),

                      const SizedBox(height: 60), // bottom spacing
                    ],
                  ),
                ),
              ),
            ],
          ),

          // QR Code overlay
          if (_selectedQRCode != null && _selectedTicketCode != null)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: TicketQRCode(
                  ticketCode: _selectedTicketCode!,
                  qrCodeImage: _selectedQRCode!,
                  onClose: () {
                    setState(() {
                      _selectedQRCode = null;
                      _selectedTicketCode = null;
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
