import 'package:flutter/material.dart';

class TicketInfoField extends StatelessWidget {
  final String label;
  final String value;

  const TicketInfoField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (!isEmpty) ...[
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF363B3E),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
