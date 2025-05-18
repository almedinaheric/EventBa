import 'package:eventba_mobile/screens/tickets_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class TicketQRCode extends StatelessWidget {
  final VoidCallback onClose;

  const TicketQRCode({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
          Image.asset(
            'assets/images/qr_code.png',
            width: screenWidth * 0.8,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: "Ok",
            onPressed: onClose,
            width: 240,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
