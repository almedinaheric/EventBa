import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/providers/ticket_purchase_provider.dart';
import 'package:eventba_mobile/providers/ticket_provider.dart';
import 'package:eventba_mobile/screens/tickets_screen.dart';
import 'package:provider/provider.dart';

class ReservePlaceScreen extends StatefulWidget {
  final String eventId;
  final int availablePlaces;

  const ReservePlaceScreen({
    super.key,
    required this.eventId,
    required this.availablePlaces,
  });

  @override
  State<ReservePlaceScreen> createState() => _ReservePlaceScreenState();
}

class _ReservePlaceScreenState extends State<ReservePlaceScreen> {
  int _quantity = 1;
  bool _isProcessing = false;
  String? _freeTicketId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _quantity = widget.availablePlaces > 0 ? 1 : 0;
    _loadFreeTicket();
  }

  Future<void> _loadFreeTicket() async {
    try {
      final ticketProvider = Provider.of<TicketProvider>(
        context,
        listen: false,
      );
      final tickets = await ticketProvider.getTicketsForEvent(widget.eventId);

      
      final freeTicket = tickets.firstWhere(
        (ticket) => ticket.price == 0,
        orElse: () => throw Exception("No free ticket found for this event"),
      );

      setState(() {
        _freeTicketId = freeTicket.id;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Failed to load ticket information: $e"),
        ),
      );
    }
  }

  Future<void> _reservePlaces() async {
    if (_isProcessing) return;

    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Please select at least one place"),
        ),
      );
      return;
    }

    if (_quantity > widget.availablePlaces) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Only ${widget.availablePlaces} places available"),
        ),
      );
      return;
    }

    if (_freeTicketId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Ticket information not loaded. Please try again."),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final ticketPurchaseProvider = Provider.of<TicketPurchaseProvider>(
        context,
        listen: false,
      );

      
      for (int i = 0; i < _quantity; i++) {
        try {
          print(
            'Creating reservation ${i + 1}/$_quantity for event ${widget.eventId}',
          );
          await ticketPurchaseProvider.insert({
            'ticketId': _freeTicketId,
            'eventId': widget.eventId,
          });
          print('✓ Reservation ${i + 1}/$_quantity created successfully');
        } catch (e) {
          print('✗ Error creating reservation ${i + 1}/$_quantity: $e');
          throw Exception('Failed to create reservation: $e');
        }
      }

      print('All reservations created successfully');

      setState(() {
        _isProcessing = false;
      });

      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Failed to reserve places: $e"),
        ),
      );
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
              'Places reserved!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'You have successfully reserved $_quantity place${_quantity > 1 ? 's' : ''}!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Ok',
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pop(context); 
                
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MasterScreenWidget(
        title: "Reserve Your Place",
        initialIndex: -1,
        appBarType: AppBarType.iconsSideTitleCenter,
        leftIcon: Icons.arrow_back,
        onLeftButtonPressed: () {
          Navigator.pop(context);
        },
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return MasterScreenWidget(
      title: "Reserve Your Place",
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select number of places',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Free Place',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Free event',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Free',
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_quantity > 1) {
                                  _quantity--;
                                }
                              });
                            },
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_quantity < widget.availablePlaces) {
                                  _quantity++;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                        "Only ${widget.availablePlaces} places available",
                                      ),
                                      duration: const Duration(seconds: 1),
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
                ),
                const Spacer(), 
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
                    const Text(
                      'Free',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: _isProcessing ? 'Processing...' : 'Reserve',
                  onPressed: _isProcessing ? () {} : _reservePlaces,
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
