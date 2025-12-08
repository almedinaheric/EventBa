import 'dart:convert';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class TicketQRCode extends StatelessWidget {
  final VoidCallback onClose;
  final String ticketCode;
  final String? qrCodeImage;

  const TicketQRCode({
    super.key,
    required this.onClose,
    required this.ticketCode,
    this.qrCodeImage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (qrCodeImage != null)
            Image.memory(
              base64Decode(qrCodeImage!),
              width: screenWidth * 0.8,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/qr_code.png',
                  width: screenWidth * 0.8,
                );
              },
            )
          else
            Image.asset('assets/images/qr_code.png', width: screenWidth * 0.8),
          const SizedBox(height: 16),
          Text(
            'Code: $ticketCode',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(text: "Ok", onPressed: onClose, width: 240),
        ],
      ),
    );
  }
}
