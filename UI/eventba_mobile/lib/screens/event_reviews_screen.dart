import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';

class EventReviewsScreen extends StatelessWidget {
  final String eventTitle;

  const EventReviewsScreen({super.key, required this.eventTitle});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {
        "name": "John Doe",
        "rating": 5,
        "comment": "Amazing event! Great organization and atmosphere.",
        "date": "May 2, 2025"
      },
      {
        "name": "Jane Smith",
        "rating": 4,
        "comment": "Really enjoyed it, would attend again.",
        "date": "May 3, 2025"
      },
    ];

    return MasterScreenWidget(
      initialIndex: 4,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Reviews",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context); // Back button functionality
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
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
                        review["name"]! as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        review["date"]! as String,
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
                        color: i < (review["rating"] as int) ? Colors.amber : Colors.grey,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(review["comment"]! as String),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}