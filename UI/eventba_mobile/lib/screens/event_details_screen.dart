import 'dart:convert';
import 'package:eventba_mobile/models/user/user.dart';
import 'package:eventba_mobile/providers/user_provider.dart';
import 'package:eventba_mobile/screens/buy_ticket_screen.dart';
import 'package:eventba_mobile/screens/reserve_place_screen.dart';
import 'package:eventba_mobile/screens/organizer_profile_screen.dart';
import 'package:eventba_mobile/utils/image_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/ticket_option.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/providers/ticket_provider.dart';
import 'package:eventba_mobile/providers/ticket_purchase_provider.dart';
import 'package:eventba_mobile/providers/user_question_provider.dart';
import 'package:eventba_mobile/models/event/event.dart';
import 'package:eventba_mobile/models/enums/event_type.dart';
import 'package:eventba_mobile/models/ticket/ticket.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool isFollowing = false;
  bool isFavorited = false;
  Event? _event;
  User? _organizer;
  List<Ticket> _tickets = [];
  bool _isLoading = true;
  int _totalTicketsLeft = 0;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final ticketProvider = Provider.of<TicketProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final event = await eventProvider.getById(widget.eventId);

      setState(() {
        _event = event;
      });

      try {
        final currentUser = await userProvider.getProfile();

        final isEventFavorited = currentUser.favoriteEvents.any(
          (favEvent) => favEvent.id == event.id,
        );

        setState(() {
          isFavorited = isEventFavorited;
        });

        try {
          final organizer = await userProvider.getById(event.organizerId);
          setState(() {
            _organizer = organizer;
          });

          setState(() {
            isFollowing = currentUser.following.any(
              (u) => u.id == organizer.id,
            );
          });
        } catch (e) {}
      } catch (e) {}

      final tickets = await ticketProvider.getTicketsForEvent(widget.eventId);
      setState(() {
        _tickets = tickets;

        if (event.isPaid) {
          _totalTicketsLeft = tickets.fold(
            0,
            (sum, ticket) => sum + ticket.quantityAvailable,
          );
        } else {
          _totalTicketsLeft = event.capacity - event.currentAttendees;
        }
      });
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await eventProvider.toggleFavoriteEvent(widget.eventId);

      await Future.delayed(const Duration(milliseconds: 500));

      final updatedUser = await userProvider.getProfile();

      final isEventFavorited = updatedUser.favoriteEvents.any(
        (favEvent) => favEvent.id == widget.eventId,
      );

      setState(() {
        isFavorited = isEventFavorited;
      });
    } catch (e) {}
  }

  Future<void> _toggleFollow() async {
    if (_organizer == null) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (isFollowing) {
        await userProvider.unfollowUser(_organizer!.id);
      } else {
        await userProvider.followUser(_organizer!.id);
      }
      setState(() {
        isFollowing = !isFollowing;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            isFollowing
                ? "Following ${_organizer!.fullName}"
                : "Unfollowed ${_organizer!.fullName}",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Failed to update follow status: $e"),
        ),
      );
    }
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

  Future<void> _showReserveDialog() async {
    final size = MediaQuery.of(context).size;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Reserve Your Place",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            _event!.isPaid
                ? "Are you sure you want to reserve your place for this free ticket?"
                : "Are you sure you want to reserve your place for this free event?",
            style: const TextStyle(fontSize: 16),
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
                    text: "Reserve",
                    width: size.width * 0.3,
                    small: true,
                    onPressed: () async {
                      try {
                        if (_event!.isPaid && _tickets.isNotEmpty) {
                          final freeTicket = _tickets.firstWhere(
                            (t) => t.price == 0,
                          );

                          final ticketPurchaseProvider =
                              Provider.of<TicketPurchaseProvider>(
                                context,
                                listen: false,
                              );

                          await ticketPurchaseProvider.insert({
                            'ticketId': freeTicket.id,
                            'eventId': widget.eventId,
                          });
                        } else {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                "Free event reservation feature coming soon!",
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(context);

                        _loadEventData();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text("Place reserved successfully!"),
                          ),
                        );
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text("Failed to reserve place: $e"),
                          ),
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
                    onPressed: () async {
                      if (questionController.text.trim().isNotEmpty) {
                        try {
                          final questionProvider =
                              Provider.of<UserQuestionProvider>(
                                context,
                                listen: false,
                              );
                          await questionProvider.insert({
                            'question': questionController.text.trim(),
                            'eventId': widget.eventId,
                            'isQuestionForAdmin': false,
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text("Question sent successfully."),
                            ),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text("Failed to send question: $e"),
                            ),
                          );
                        }
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_event == null) {
      return const Scaffold(body: Center(child: Text('Event not found')));
    }

    return MasterScreenWidget(
      appBarType: AppBarType.iconsSideTitleCenter,
      title: _event!.title,
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () => Navigator.pop(context),
      rightIcon: isFavorited ? Icons.favorite : Icons.favorite_border,
      rightIconColor: Colors.red,
      onRightButtonPressed: _toggleFavorite,
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

                    Builder(
                      builder: (context) {
                        List<String> allImages = [];
                        if (_event!.coverImage?.data != null) {
                          allImages.add(_event!.coverImage!.data!);
                        }
                        if (_event!.galleryImages != null &&
                            _event!.galleryImages!.isNotEmpty) {
                          for (var galleryImage in _event!.galleryImages!) {
                            if (galleryImage.data != null &&
                                galleryImage.data!.isNotEmpty) {
                              allImages.add(galleryImage.data!);
                            }
                          }
                        }

                        if (allImages.isEmpty) {
                          return SizedBox(
                            height: 200,
                            child: GestureDetector(
                              onTap: () => _showImageDialog(0),
                              child: Container(
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
                            ),
                          );
                        }

                        return SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: PageController(),
                            scrollDirection: Axis.horizontal,
                            itemCount: allImages.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _showImageDialog(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Builder(
                                    builder: (context) {
                                      final imageData = allImages[index];
                                      try {
                                        String base64String = imageData;
                                        if (imageData.startsWith(
                                          'data:image',
                                        )) {
                                          base64String = imageData
                                              .split(',')
                                              .last;
                                        }
                                        return Image.memory(
                                          base64Decode(base64String),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 200,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/images/default_event_cover_image.png',
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: 200,
                                                );
                                              },
                                        );
                                      } catch (e) {
                                        return Image.asset(
                                          'assets/images/default_event_cover_image.png',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 200,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
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
                                      _event!.startDate,
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
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5B7CF6),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _event!.category.name,
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
                                    Text(
                                      _event!.isPaid
                                          ? "Tickets left"
                                          : "Places left",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _totalTicketsLeft.toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: _totalTicketsLeft > 0
                                            ? Colors.black
                                            : Colors.red,
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

                    const SizedBox(height: 24),

                    const Text(
                      "Organized by",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_organizer != null) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      OrganizerProfileScreen(
                                        userId: _organizer!.id,
                                        name: _organizer!.fullName,
                                        avatarUrl:
                                            _organizer!.profileImage?.data ??
                                            '',
                                        bio: _organizer!.bio ?? '',
                                      ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey[300],
                                child: ClipOval(
                                  child: ImageHelpers.getProfileImage(
                                    _organizer!.profileImage?.data,
                                    height: 48,
                                    width: 48,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _organizer!.fullName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4776E6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: _toggleFollow,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF5B7CF6)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isFollowing ? "Unfollow" : "Follow",
                            style: const TextStyle(
                              color: Color(0xFF5B7CF6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isDescriptionExpanded
                              ? _event!.description
                              : (_event!.description.length > 150
                                    ? '${_event!.description.substring(0, 150)}...'
                                    : _event!.description),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        if (_event!.description.length > 150)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDescriptionExpanded =
                                      !_isDescriptionExpanded;
                                });
                              },
                              child: Text(
                                _isDescriptionExpanded
                                    ? "Show less"
                                    : "Show more",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF5B7CF6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (_event!.isPaid) ...[
                      const Text(
                        "Tickets",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_tickets.isNotEmpty)
                        ..._tickets
                            .map(
                              (ticket) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: TicketOption(
                                  type: ticket.ticketType,
                                  price: "\$${ticket.price.toStringAsFixed(2)}",
                                  available: ticket.quantityAvailable,
                                ),
                              ),
                            )
                            .toList()
                      else
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "No tickets available",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],

                    const SizedBox(height: 16),

                    if (_event!.type == EventType.Private)
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
                            style: TextStyle(
                              color: Color(0xFF5B7CF6),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    if (_event!.type == EventType.Private)
                      const SizedBox(height: 8),

                    if (_event!.isPaid && _tickets.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final hasFreeTickets = _tickets.any(
                              (t) => t.price == 0,
                            );
                            final hasPaidTickets = _tickets.any(
                              (t) => t.price > 0,
                            );

                            if (hasFreeTickets && !hasPaidTickets) {
                              _showReserveDialog();
                            } else {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => BuyTicketScreen(
                                    eventId: widget.eventId,
                                    tickets: _tickets,
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B7CF6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _tickets.every((t) => t.price == 0)
                                ? "Reserve Your Place"
                                : "Buy Ticket",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else if (!_event!.isPaid && _totalTicketsLeft > 0)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => ReservePlaceScreen(
                                  eventId: widget.eventId,
                                  availablePlaces: _totalTicketsLeft,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            ).then((_) {
                              _loadEventData();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B7CF6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Reserve Your Place",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
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
}
