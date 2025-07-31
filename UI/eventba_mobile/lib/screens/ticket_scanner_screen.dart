import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TicketScannerScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const TicketScannerScreen({super.key, required this.eventData});

  @override
  State<TicketScannerScreen> createState() => _TicketScannerScreenState();
}

class _TicketScannerScreenState extends State<TicketScannerScreen> {
  MobileScannerController? controller;
  String? scannedCode;

  final TextEditingController manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller?.dispose();
    manualController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          scannedCode = barcode.rawValue;
        });
        controller?.stop();
        // You could validate the ticket here using scannedCode
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Scan QR Ticket",
      initialIndex: 4,
      appBarType: AppBarType.iconsSideTitleCenter,
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MobileScanner(
                    controller: controller,
                    onDetect: _onDetect,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (scannedCode != null)
                Text(
                  "Scanned Code: $scannedCode",
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                "Or enter code manually",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: manualController,
                decoration: InputDecoration(
                  labelText: "Enter ticket code",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: "Validate Code",
                onPressed: () {
                  final enteredCode = manualController.text.trim();
                  if (enteredCode.isNotEmpty) {
                    setState(() {
                      scannedCode = enteredCode;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
