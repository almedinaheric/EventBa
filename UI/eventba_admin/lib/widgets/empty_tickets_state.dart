import 'package:flutter/material.dart';

class EmptyTicketsState extends StatelessWidget {
  const EmptyTicketsState({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        width: screenWidth * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const Text(
              "#",
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4776E6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Looks like you haven't attended any events yet! Keep an eye out for upcoming events that interest you and purchase your tickets here. Your past tickets will be saved in this section for future reference.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
