import 'package:flutter/material.dart';

class TicketScannerScreen extends StatelessWidget {
  const TicketScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Ticket")),
      body: const Center(child: Text("QR Scanner coming soon...")),
    );
  }
}
