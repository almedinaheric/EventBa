import 'package:eventba_admin/screens/tickets_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/widgets/primary_button.dart';

class BuyTicketScreen extends StatefulWidget {
  const BuyTicketScreen({super.key});

  @override
  State<BuyTicketScreen> createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  final Map<String, int> _ticketCounts = {
    'VIP': 0,
    'Economy': 0,
    'Free': 0,
  };

  final Map<String, double> _ticketPrices = {
    'VIP': 30.0,
    'Economy': 15.0,
    'Free': 0.0,
  };

  int _selectedPayment = 0;

  double get _totalPrice {
    double total = 0.0;
    _ticketCounts.forEach((type, count) {
      total += count * _ticketPrices[type]!;
    });
    return total;
  }

  void _confirmPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.blue, size: 60),
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
                      )
                    }),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketSelector(String type) {
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
            child: Text(
              '$type Ticket',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Text('${_ticketPrices[type]} KM',
              style: const TextStyle(color: Colors.blue, fontSize: 16)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.black),
                onPressed: () {
                  setState(() {
                    if (_ticketCounts[type]! > 0) {
                      _ticketCounts[type] = _ticketCounts[type]! - 1;
                    }
                  });
                },
              ),
              Text('${_ticketCounts[type]}',
                  style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _ticketCounts[type] = _ticketCounts[type]! + 1;
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
            _buildTicketSelector('VIP'),
            _buildTicketSelector('Economy'),
            _buildTicketSelector('Free'),
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
                const Text('Total',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${_totalPrice.toStringAsFixed(2)} KM',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Pay',
              onPressed: _confirmPayment,
              width: double.infinity,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
