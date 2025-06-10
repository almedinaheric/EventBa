import 'package:flutter/material.dart';

class TicketTypeBadge extends StatelessWidget {
  final String type;
  final String price;
  final VoidCallback onShowQR;

  const TicketTypeBadge({
    super.key,
    required this.type,
    required this.price,
    required this.onShowQR,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          // First item takes 2/3
          Expanded(
            flex: 2,
            child: Text(
              type,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Second item (price) takes 1/6
          Expanded(
            flex: 1,
            child: Text(
              price,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF363B3E),
              ),
            ),
          ),

          // Third item (QR button) takes 1/6
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onShowQR,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4776E6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.qr_code,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
