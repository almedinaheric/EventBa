import 'dart:io';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/providers/ticket_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class TicketScannerScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const TicketScannerScreen({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  @override
  State<TicketScannerScreen> createState() => _TicketScannerScreenState();
}

class _TicketScannerScreenState extends State<TicketScannerScreen> {
  MobileScannerController? controller;
  String? scannedCode;
  bool _isValidating = false;
  bool _isSimulator = false;

  final TextEditingController manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfSimulator();
    if (!_isSimulator) {
      controller = MobileScannerController();
    }
  }

  void _checkIfSimulator() {
    if (kIsWeb) {
      _isSimulator = true;
    } else {
      try {
        // Check if running on iOS simulator or Android emulator
        if (Platform.isIOS) {
          // On iOS simulator, camera might not be available
          // We'll show manual input as fallback
          _isSimulator =
              false; // Try to use camera, fallback to manual if needed
        } else if (Platform.isAndroid) {
          // On Android, check build fingerprint for emulator indicators
          final model = Platform.environment['ANDROID_MODEL'] ?? '';
          _isSimulator =
              model.toLowerCase().contains('sdk') ||
              model.toLowerCase().contains('emulator') ||
              model.toLowerCase().contains('google_sdk');
        } else {
          _isSimulator = false;
        }
      } catch (e) {
        // If we can't determine, assume it's a real device
        _isSimulator = false;
      }
    }
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
      if (barcode.rawValue != null && !_isValidating) {
        // Extract ticket code from QR data format: "EVENT:...|TICKET:CODE|USER:..."
        String ticketCode = barcode.rawValue!;
        if (ticketCode.contains('|TICKET:')) {
          final parts = ticketCode.split('|TICKET:');
          if (parts.length > 1) {
            final ticketPart = parts[1].split('|')[0];
            ticketCode = ticketPart;
          }
        }
        _validateTicket(ticketCode);
        break;
      }
    }
  }

  Future<void> _validateTicket(String ticketCode) async {
    if (_isValidating) return;

    setState(() {
      _isValidating = true;
      scannedCode = ticketCode;
    });

    try {
      final ticketProvider = Provider.of<TicketProvider>(
        context,
        listen: false,
      );

      await ticketProvider.validateTicket(widget.eventId, ticketCode);

      if (mounted) {
        try {
          await controller?.stop();
        } catch (e) {
          // Ignore errors when stopping
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("Ticket validated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        // Reset after a delay to allow scanning again
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              scannedCode = null;
              _isValidating = false;
            });
            try {
              controller?.start();
            } catch (e) {
              // Ignore errors if already started
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("Validation failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
        // Allow scanning again after error
        try {
          controller?.start();
        } catch (startError) {
          // Ignore errors if already started
        }
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
              if (!_isSimulator) ...[
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Scanned Code: $scannedCode",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_isValidating)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
              ],
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_isValidating)
                const CircularProgressIndicator()
              else
                PrimaryButton(
                  text: "Validate Code",
                  onPressed: () {
                    final enteredCode = manualController.text.trim();
                    if (enteredCode.isNotEmpty) {
                      _validateTicket(enteredCode);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text("Please enter a ticket code"),
                        ),
                      );
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
