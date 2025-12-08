import 'package:flutter/material.dart';

class TicketOption extends StatelessWidget {
  final String type;
  final String price;
  final int? available;

  const TicketOption({
    super.key,
    required this.type,
    required this.price,
    this.available,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF5B7CF6)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5B7CF6),
                ),
              ),
              if (available != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Available: $available',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5B7CF6),
            ),
          ),
        ],
      ),
    );
  }
}
