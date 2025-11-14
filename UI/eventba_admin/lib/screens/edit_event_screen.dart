import 'package:eventba_admin/widgets/custom_text_field.dart';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/widgets/primary_button.dart';
import 'package:eventba_admin/providers/event_provider.dart';
import 'package:eventba_admin/providers/category_provider.dart';
import 'package:eventba_admin/providers/ticket_provider.dart';
import 'package:eventba_admin/models/category/category_model.dart';
import 'package:eventba_admin/models/ticket/ticket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EditEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  String? _selectedCategoryId;
  late TextEditingController _venueController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _descriptionController;
  late TextEditingController _capacityController;
  late TextEditingController _vipPriceController;
  late TextEditingController _vipCountController;
  late TextEditingController _ecoPriceController;
  late TextEditingController _ecoCountController;

  XFile? _mainImage;
  List<XFile> _additionalImages = [];

  bool _isPaid = false;
  bool _isLoading = false;
  List<CategoryModel> _categories = [];
  bool _categoriesLoading = true;
  List<Ticket> _existingTickets = [];

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _nameController = TextEditingController(text: event['name']);
    _selectedCategoryId = event['categoryId'];
    _venueController = TextEditingController(text: event['venue']);
    _dateController = TextEditingController(text: event['date']);
    _startTimeController = TextEditingController(text: event['startTime']);
    _endTimeController = TextEditingController(text: event['endTime']);
    _descriptionController = TextEditingController(text: event['description']);
    _capacityController = TextEditingController(
      text: event['capacity']?.toString() ?? '0',
    );

    // Initialize ticket controllers with empty strings
    _vipPriceController = TextEditingController(text: '');
    _vipCountController = TextEditingController(text: '');
    _ecoPriceController = TextEditingController(text: '');
    _ecoCountController = TextEditingController(text: '');

    _isPaid = event['isPaid'] ?? false;

    // Load categories and tickets after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
      _loadExistingTickets();
    });
  }

  Future<void> _loadExistingTickets() async {
    try {
      final ticketProvider = Provider.of<TicketProvider>(
        context,
        listen: false,
      );
      final tickets = await ticketProvider.getTicketsForEvent(
        widget.event['id'],
      );

      setState(() {
        _existingTickets = tickets;

        // Populate ticket fields if tickets exist
        for (var ticket in tickets) {
          if (ticket.ticketType == 'Vip') {
            _vipPriceController.text = ticket.price.toString();
            _vipCountController.text = ticket.quantity.toString();
          } else if (ticket.ticketType == 'Economy') {
            _ecoPriceController.text = ticket.price.toString();
            _ecoCountController.text = ticket.quantity.toString();
          }
        }
      });
    } catch (e) {
      print("Error loading existing tickets: $e");
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesLoading = true;
    });

    try {
      print("Loading categories...");
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      print("CategoryProvider obtained");
      final result = await categoryProvider.get();
      print("Categories loaded: ${result.result.length} categories");

      if (mounted) {
        setState(() {
          _categories = result.result;
          _categoriesLoading = false;

          // Verify selected category exists in loaded categories
          if (_selectedCategoryId != null) {
            final categoryExists = _categories.any(
              (cat) => cat.id == _selectedCategoryId,
            );
            if (!categoryExists) {
              print(
                "Warning: Selected category ID $_selectedCategoryId not found in loaded categories",
              );
              // Set to first category if current selection doesn't exist
              if (_categories.isNotEmpty) {
                _selectedCategoryId = _categories.first.id;
                print("Reset to first category: ${_categories.first.name}");
              }
            } else {
              print(
                "Selected category found: ${_categories.firstWhere((cat) => cat.id == _selectedCategoryId).name}",
              );
            }
          } else if (_categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.id;
            print(
              "No category selected, setting to first: ${_categories.first.name}",
            );
          }
        });
        print("Categories set in state. Count: ${_categories.length}");
      }
    } catch (e, stackTrace) {
      print("Error loading categories: $e");
      print("Stack trace: $stackTrace");
      if (mounted) {
        setState(() {
          _categoriesLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return MasterScreen(
      title: 'Edit Event',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageUploadSection(screenWidth),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: 'Event name',
                hint: 'Enter event name',
                width: screenWidth * 0.9,
              ),
              const SizedBox(height: 12),
              const Text(
                'Event category',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _categoriesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _categories.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'No categories available. Please try refreshing.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Event category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: _categories.map((CategoryModel category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategoryId = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _venueController,
                label: 'Venue address',
                hint: 'Enter venue address',
                width: screenWidth * 0.9,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _dateController,
                label: 'Date',
                hint: 'Select date',
                width: double.infinity,
                readOnly: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _startTimeController,
                      label: 'Start time',
                      hint: 'Start',
                      width: double.infinity,
                      readOnly: true,
                      onTap: _pickStartTime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _endTimeController,
                      label: 'End time',
                      hint: 'End',
                      width: double.infinity,
                      readOnly: true,
                      onTap: _pickEndTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Add description',
                width: screenWidth * 0.9,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                "Pricing and Tickets",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriceTypeButton(false, 'Free'),
                  const SizedBox(width: 12),
                  _buildPriceTypeButton(true, 'Paid'),
                ],
              ),
              const SizedBox(height: 16),
              if (!_isPaid)
                CustomTextField(
                  controller: _capacityController,
                  label: 'Capacity',
                  hint: 'Enter event capacity',
                  width: screenWidth * 0.9,
                  keyboardType: TextInputType.number,
                ),
              if (_isPaid) ...[
                const SizedBox(height: 12),
                const Text(
                  "VIP tickets",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _vipPriceController,
                        hint: 'VIP price',
                        width: double.infinity,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _vipCountController,
                        hint: 'Number of VIP tickets',
                        width: double.infinity,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "ECONOMY tickets",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _ecoPriceController,
                        hint: 'Economy price',
                        width: double.infinity,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _ecoCountController,
                        hint: 'Number of economy tickets',
                        width: double.infinity,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : PrimaryButton(
                        text: "Update Event",
                        onPressed: _submitForm,
                      ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickMainImage,
          child: Container(
            height: 160,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              image: _mainImage != null
                  ? DecorationImage(
                      image: FileImage(File(_mainImage!.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _mainImage == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 40),
                        SizedBox(height: 8),
                        Text('Add main image'),
                      ],
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (index) {
            return GestureDetector(
              onTap: () => _pickAdditionalImage(index),
              child: Container(
                width: ((screenWidth * 0.8) - 32 - 16 * 2) / 3,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  image: index < _additionalImages.length
                      ? DecorationImage(
                          image: FileImage(File(_additionalImages[index].path)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: index >= _additionalImages.length
                    ? const Center(child: Icon(Icons.add))
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _pickMainImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _mainImage = image;
      });
    }
  }

  Future<void> _pickAdditionalImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (index < _additionalImages.length) {
          _additionalImages[index] = image;
        } else {
          _additionalImages.add(image);
        }
      });
    }
  }

  Widget _buildPriceTypeButton(bool isPaidButton, String label) {
    final isSelected = _isPaid == isPaidButton;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isPaid = isPaidButton;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4776E6) : Colors.transparent,
            border: Border.all(
              color: isSelected ? const Color(0xFF4776E6) : Colors.grey,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _startTimeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _pickEndTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _endTimeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _manageTickets(String eventId, String eventDate) async {
    try {
      final ticketProvider = Provider.of<TicketProvider>(
        context,
        listen: false,
      );

      if (_isPaid) {
        // Event is PAID - create or update VIP and Economy tickets
        final vipPrice = double.tryParse(_vipPriceController.text) ?? 0.0;
        final vipCount = int.tryParse(_vipCountController.text) ?? 0;
        final ecoPrice = double.tryParse(_ecoPriceController.text) ?? 0.0;
        final ecoCount = int.tryParse(_ecoCountController.text) ?? 0;

        // Parse the date for ticket sale dates
        DateTime saleStartDate = DateTime.now();
        DateTime saleEndDate = DateTime.parse(eventDate);

        // Find existing tickets
        Ticket? existingVipTicket;
        Ticket? existingEcoTicket;

        for (var ticket in _existingTickets) {
          if (ticket.ticketType == 'Vip') {
            existingVipTicket = ticket;
          } else if (ticket.ticketType == 'Economy') {
            existingEcoTicket = ticket;
          }
        }

        // Handle VIP tickets
        if (vipCount > 0 && vipPrice > 0) {
          final vipTicketData = {
            'eventId': eventId,
            'ticketType': 'Vip',
            'price': vipPrice,
            'quantity': vipCount,
            'saleStartDate': saleStartDate.toIso8601String(),
            'saleEndDate': saleEndDate.toIso8601String(),
          };

          if (existingVipTicket != null) {
            // Update existing VIP ticket
            vipTicketData['id'] = existingVipTicket.id;
            vipTicketData['quantityAvailable'] =
                existingVipTicket.quantityAvailable;
            vipTicketData['quantitySold'] = existingVipTicket.quantitySold;
            await ticketProvider.updateTicket(
              existingVipTicket.id,
              vipTicketData,
            );
          } else {
            // Create new VIP ticket
            await ticketProvider.createTicket(vipTicketData);
          }
        } else if (existingVipTicket != null) {
          // Delete VIP ticket if it exists but no longer needed
          await ticketProvider.deleteTicket(existingVipTicket.id);
        }

        // Handle Economy tickets
        if (ecoCount > 0 && ecoPrice > 0) {
          final ecoTicketData = {
            'eventId': eventId,
            'ticketType': 'Economy',
            'price': ecoPrice,
            'quantity': ecoCount,
            'saleStartDate': saleStartDate.toIso8601String(),
            'saleEndDate': saleEndDate.toIso8601String(),
          };

          if (existingEcoTicket != null) {
            // Update existing Economy ticket
            ecoTicketData['id'] = existingEcoTicket.id;
            ecoTicketData['quantityAvailable'] =
                existingEcoTicket.quantityAvailable;
            ecoTicketData['quantitySold'] = existingEcoTicket.quantitySold;
            await ticketProvider.updateTicket(
              existingEcoTicket.id,
              ecoTicketData,
            );
          } else {
            // Create new Economy ticket
            await ticketProvider.createTicket(ecoTicketData);
          }
        } else if (existingEcoTicket != null) {
          // Delete Economy ticket if it exists but no longer needed
          await ticketProvider.deleteTicket(existingEcoTicket.id);
        }
      } else {
        // Event is FREE - delete all existing tickets
        if (_existingTickets.isNotEmpty) {
          await ticketProvider.deleteAllTicketsForEvent(eventId);
        }
      }
    } catch (e) {
      print("Error managing tickets: $e");
      // Don't throw - tickets are supplementary, event update succeeded
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final event = widget.event;

      // Parse date from controller (format: "YYYY-MM-DD")
      String dateStr = _dateController.text;
      if (dateStr.contains('/')) {
        // Convert from display format to ISO format if needed
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          dateStr =
              '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
        }
      }

      // Calculate capacity based on event type (paid/free)
      int calculatedCapacity;
      if (_isPaid) {
        // For paid events, capacity = VIP tickets + Economy tickets
        final vipCount = int.tryParse(_vipCountController.text) ?? 0;
        final ecoCount = int.tryParse(_ecoCountController.text) ?? 0;
        calculatedCapacity = vipCount + ecoCount;
      } else {
        // For free events, use the capacity field
        calculatedCapacity = int.tryParse(_capacityController.text) ?? 0;
      }

      // Prepare update data matching EventUpdateRequestDto
      final updateData = {
        'id': event['id'],
        'title': _nameController.text,
        'description': _descriptionController.text,
        'location': _venueController.text,
        'startDate': dateStr, // Format: "YYYY-MM-DD"
        'endDate': dateStr, // Format: "YYYY-MM-DD"
        'startTime': _startTimeController.text, // Format: "HH:MM"
        'endTime': _endTimeController.text, // Format: "HH:MM"
        'capacity': calculatedCapacity,
        'currentAttendees': event['currentAttendees'] ?? 0,
        'availableTicketsCount': calculatedCapacity,
        'status': event['status'] ?? 'Upcoming',
        'isFeatured': event['isFeatured'] ?? false,
        'type': event['type'] ?? 'Public',
        'isPublished': true,
        'categoryId': _selectedCategoryId ?? event['categoryId'],
        'coverImageId': event['coverImageId'],
      };

      await eventProvider.updateEvent(event['id'], updateData);

      if (!mounted) return;

      // Now handle tickets based on event type (paid/free)
      await _manageTickets(event['id'], dateStr);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back with success flag
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _vipPriceController.dispose();
    _vipCountController.dispose();
    _ecoPriceController.dispose();
    _ecoCountController.dispose();
    super.dispose();
  }
}
