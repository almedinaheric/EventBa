import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/providers/event_review_provider.dart';
import 'package:eventba_mobile/providers/user_provider.dart';
import 'package:eventba_mobile/models/event_review/event_review.dart';
import 'package:eventba_mobile/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventReviewsScreen extends StatefulWidget {
  final String eventTitle;
  final String? eventId;

  const EventReviewsScreen({super.key, required this.eventTitle, this.eventId});

  @override
  State<EventReviewsScreen> createState() => _EventReviewsScreenState();
}

class _EventReviewsScreenState extends State<EventReviewsScreen> {
  List<EventReview> _reviews = [];
  Map<String, User> _users = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _loadReviews();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviewProvider = Provider.of<EventReviewProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final reviews = await reviewProvider.getReviewsForEvent(widget.eventId!);

      final usersMap = <String, User>{};
      for (final review in reviews) {
        try {
          final user = await userProvider.getById(review.userId);
          usersMap[review.userId] = user;
        } catch (e) {}
      }

      setState(() {
        _reviews = reviews;
        _users = usersMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      initialIndex: 4,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Reviews",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text("No reviews yet."),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                final user = _users[review.userId];
                final userName = user?.fullName ?? 'Anonymous';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatDate(review.createdAt),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              Icons.star,
                              size: 16,
                              color: i < review.rating
                                  ? Colors.amber
                                  : Colors.grey,
                            );
                          }),
                        ),
                        if (review.comment.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(review.comment),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
