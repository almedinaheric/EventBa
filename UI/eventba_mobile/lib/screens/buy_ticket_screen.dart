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
      
      bool allFree = true;
      for (var entry in _ticketCounts.entries) {
        if (entry.value > 0 && _ticketMap[entry.key]!.price > 0) {
          allFree = false;
          break;
        }
      }

      if (allFree) {
        
        await _processFreeTickets();
      } else {
        
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

  Future<void> _createPaymentRecord() async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    try {
      await paymentProvider.insert({
        'eventId': widget.eventId,
        'amount': _totalPrice,
        'currency': 'usd',
      });
      print(
        'Payment record created: amount=$_totalPrice, eventId=${widget.eventId}',
      );
    } catch (e) {
      print('Error creating payment record: $e');
      
    }
  }

  Future<void> _processTicketPurchases() async {
    final ticketPurchaseProvider = Provider.of<TicketPurchaseProvider>(
      context,
      listen: false,
    );

    
    for (var entry in _ticketCounts.entries) {
      if (entry.value > 0) {
        final ticket = _ticketMap[entry.key];
        print(
          'Processing ${entry.value} ticket(s) of type: ${ticket?.ticketType ?? entry.key}',
        );

        for (int i = 0; i < entry.value; i++) {
          try {
            print(
              'Creating ticket purchase ${i + 1}/${entry.value} for ticketId: ${entry.key}',
            );
            await ticketPurchaseProvider.insert({
              'ticketId': entry.key,
              'eventId': widget.eventId,
            });
            print(
              '✓ Ticket purchase created: ticketId=${entry.key}, count=${i + 1}/${entry.value}',
            );
          } catch (e) {
            print(
              '✗ Error creating ticket purchase ${i + 1}/${entry.value} for ticketId=${entry.key}: $e',
            );
            throw Exception(
              'Failed to create ticket purchase for ${ticket?.ticketType ?? entry.key}: $e',
            );
          }
        }
      }
    }
    print('All ticket purchases created successfully');
  }

  Future<void> _processFreeTickets() async {
    await _processTicketPurchases();
    setState(() {
      _isProcessing = false;
    });
    _showSuccessDialog();
  }

  Future<void> _processStripePayment() async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    
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
      print(
        'Creating payment intent: amount=${_totalPrice}, ticketId=$ticketId, eventId=${widget.eventId}, quantity=$totalQuantity',
      );

      
      final paymentIntentData = await paymentProvider.createPaymentIntent(
        amount: _totalPrice,
        currency: 'usd',
        ticketId: ticketId,
        eventId: widget.eventId,
        quantity: totalQuantity,
      );

      print('Payment intent created: ${paymentIntentData.toString()}');

      
      if (paymentIntentData['clientSecret'] == null) {
        throw Exception(
          'Invalid payment intent response: missing clientSecret',
        );
      }

      
      if (paymentIntentData['publishableKey'] != null) {
        final backendPublishableKey =
            paymentIntentData['publishableKey'] as String;
        if (backendPublishableKey.isNotEmpty &&
            stripe.Stripe.publishableKey != backendPublishableKey) {
          print('Updating Stripe publishable key from backend');
          stripe.Stripe.publishableKey = backendPublishableKey;
        }
      }

      
      print('Initializing payment sheet...');
      print(
        'Using Stripe publishable key: ${stripe.Stripe.publishableKey.substring(0, 20)}...',
      );

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          merchantDisplayName: 'EventBa',
          style: ThemeMode.light,
        ),
      );

      print('Presenting payment sheet...');
      
      await stripe.Stripe.instance.presentPaymentSheet();

      print('Payment successful! Creating payment record...');
      
      await _createPaymentRecord();

      print('Creating ticket purchases...');
      
      await _processTicketPurchases();

      setState(() {
        _isProcessing = false;
      });

      _showSuccessDialog();
    } on stripe.StripeException catch (e) {
      setState(() {
        _isProcessing = false;
      });

      print('Stripe error: ${e.error.code} - ${e.error.localizedMessage}');

      if (e.error.code != stripe.FailureCode.Canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Payment failed: ${e.error.localizedMessage ?? e.error.message ?? 'Unknown error'}",
            ),
          ),
        );
      }
      rethrow;
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      print('Payment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Payment error: ${e.toString()}"),
        ),
      );
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
                  '${ticket.ticketType}',
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
            '\$${ticket.price.toStringAsFixed(2)}',
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const Text(
                        'Select ticket types and quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.tickets
                          .map((ticket) => _buildTicketSelector(ticket))
                          .toList(),
                      const SizedBox(height: 24),
                      const Text(
                        'Payment method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPaymentOption(0, 'Stripe'),
                    ],
                  ),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${_totalPrice.toStringAsFixed(2)}',
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
          );
        },
      ),
    );
  }
}
