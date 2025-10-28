import 'package:eventba_mobile/screens/tickets_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/models/ticket/ticket.dart';
import 'package:eventba_mobile/providers/ticket_purchase_provider.dart';
import 'package:eventba_mobile/providers/payment_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

class BuyTicketScreen extends StatefulWidget {
  final String eventId;
  final List<Ticket> tickets;

  const BuyTicketScreen({
    super.key,
    required this.eventId,
    required this.tickets,
  });

  @override
  State<BuyTicketScreen> createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  late Map<String, int> _ticketCounts;
  late Map<String, Ticket> _ticketMap;

  int _selectedPayment = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _ticketCounts = {};
    _ticketMap = {};

    for (var ticket in widget.tickets) {
      _ticketCounts[ticket.id] = 0;
      _ticketMap[ticket.id] = ticket;
    }
  }

  double get _totalPrice {
    double total = 0.0;
    _ticketCounts.forEach((ticketId, count) {
      total += count * _ticketMap[ticketId]!.price;
    });
    return total;
  }

  void _confirmPayment() async {
    if (_isProcessing) return;

    // Check if any tickets are selected
    if (_ticketCounts.values.every((count) => count == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Please select at least one ticket"),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Check if all selected tickets are free
      bool allFree = true;
      for (var entry in _ticketCounts.entries) {
        if (entry.value > 0 && _ticketMap[entry.key]!.price > 0) {
          allFree = false;
          break;
        }
      }

      if (allFree) {
        // Free tickets - no payment needed
        await _processFreeTickets();
      } else {
        // Paid tickets - process with Stripe
        await _processStripePayment();
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Failed to process payment: $e"),
        ),
      );
    }
  }

  Future<void> _processFreeTickets() async {
    final ticketPurchaseProvider = Provider.of<TicketPurchaseProvider>(
      context,
      listen: false,
    );

    // Create ticket purchases for each selected ticket
    for (var entry in _ticketCounts.entries) {
      if (entry.value > 0) {
        for (int i = 0; i < entry.value; i++) {
          await ticketPurchaseProvider.insert({
            'ticketId': entry.key,
            'eventId': widget.eventId,
          });
        }
      }
    }

    _showSuccessDialog();
  }

  Future<void> _processStripePayment() async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    // Get the first paid ticket for payment intent metadata
    String ticketId = '';
    int totalQuantity = 0;

    for (var entry in _ticketCounts.entries) {
      if (entry.value > 0) {
        if (ticketId.isEmpty) {
          ticketId = entry.key;
        }
        totalQuantity += entry.value;
      }
    }

    try {
      // Create payment intent
      final paymentIntentData = await paymentProvider.createPaymentIntent(
        amount: _totalPrice,
        currency: 'usd',
        ticketId: ticketId,
        eventId: widget.eventId,
        quantity: totalQuantity,
      );

      // Initialize payment sheet
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          merchantDisplayName: 'EventBa',
          style: ThemeMode.light,
        ),
      );

      // Present payment sheet
      await stripe.Stripe.instance.presentPaymentSheet();

      // Payment successful - create ticket purchases
      await _processFreeTickets();
    } on stripe.StripeException catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (e.error.code != stripe.FailureCode.Canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("Payment failed: ${e.error.localizedMessage}"),
          ),
        );
      }
      rethrow;
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.blue,
              size: 60,
            ),
            const SizedBox(height: 20),
            const Text(
              'Ticket confirmed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Find your ticket and its details in the Tickets section of the application!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Ok',
              onPressed: () => {
                Navigator.pop(context),
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const MasterScreenWidget(
                      child: TicketsScreen(),
                      initialIndex: 3,
                      title: "Tickets",
                      appBarType: AppBarType.titleCenterIconRight,
                      rightIcon: null,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketSelector(Ticket ticket) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ticket.ticketType} Ticket',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Available: ${ticket.quantityAvailable}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${ticket.price.toStringAsFixed(2)} KM',
            style: const TextStyle(color: Colors.blue, fontSize: 16),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    if (_ticketCounts[ticket.id]! > 0) {
                      _ticketCounts[ticket.id] = _ticketCounts[ticket.id]! - 1;
                    }
                  });
                },
              ),
              Text(
                '${_ticketCounts[ticket.id]}',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                onPressed: () {
                  setState(() {
                    if (_ticketCounts[ticket.id]! < ticket.quantityAvailable) {
                      _ticketCounts[ticket.id] = _ticketCounts[ticket.id]! + 1;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text("No more tickets available"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int index, String label) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.black),
            const SizedBox(width: 16),
            Expanded(child: Text(label)),
            Radio<int>(
              value: index,
              groupValue: _selectedPayment,
              onChanged: (val) => setState(() => _selectedPayment = val!),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Buy Ticket",
      initialIndex: -1,
      appBarType: AppBarType.iconsSideTitleCenter,
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Select ticket types and quantity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.tickets
                .map((ticket) => _buildTicketSelector(ticket))
                .toList(),
            const SizedBox(height: 24),
            const Text(
              'Payment method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPaymentOption(0, 'Credit Card'),
            _buildPaymentOption(1, 'PayPal'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_totalPrice.toStringAsFixed(2)} KM',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: _isProcessing ? 'Processing...' : 'Pay',
              onPressed: _isProcessing ? () {} : _confirmPayment,
              width: double.infinity,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
