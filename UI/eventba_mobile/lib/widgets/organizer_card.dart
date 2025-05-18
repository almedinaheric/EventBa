import 'package:flutter/material.dart';

class OrganizerCard extends StatelessWidget {
  final String imageUrl;
  final String name;

  const OrganizerCard({
    super.key,
    required this.imageUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(imageUrl),
          radius: 16,
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4776E6),
          ),
        ),
      ],
    );
  }
}
