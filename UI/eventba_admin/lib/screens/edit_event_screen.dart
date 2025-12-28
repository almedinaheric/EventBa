import 'dart:convert';
import 'dart:io';
import 'package:eventba_admin/widgets/custom_text_field.dart';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/widgets/primary_button.dart';
import 'package:eventba_admin/providers/event_provider.dart';
import 'package:eventba_admin/providers/category_provider.dart';
import 'package:eventba_admin/providers/ticket_provider.dart';
import 'package:eventba_admin/providers/image_provider.dart';
import 'package:eventba_admin/models/category/category_model.dart';
import 'package:eventba_admin/models/ticket/ticket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
  String? _existingCoverImageData;
  List<String> _existingGalleryImageData = [];
  String? _existingCoverImageId;
  List<String> _existingGalleryImageIds = [];

  bool _isPaid = false;
  bool _originalIsPaid = false;
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
    final startDate = event['startDate'] ?? event['date'] ?? '';
    final endDate = event['endDate'] ?? event['date'] ?? '';
    _dateController = TextEditingController(
      text: startDate.isNotEmpty && endDate.isNotEmpty
          ? "$startDate - $endDate"
          : (event['date'] ?? ''),
    );
    _startTimeController = TextEditingController(text: event['startTime']);
    _endTimeController = TextEditingController(text: event['endTime']);
    _descriptionController = TextEditingController(text: event['description']);
    _capacityController = TextEditingController(
      text: event['capacity']?.toString() ?? '0',
    );

    _vipPriceController = TextEditingController(text: '');
    _vipCountController = TextEditingController(text: '');
    _ecoPriceController = TextEditingController(text: '');
    _ecoCountController = TextEditingController(text: '');

    _isPaid = event['isPaid'] ?? false;
    _originalIsPaid = _isPaid;

    _loadExistingImages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
      _loadExistingTickets();
    });
  }

  void _loadExistingImages() {
    final coverImage = widget.event['coverImage'];
    if (coverImage != null) {
      if (coverImage is String && coverImage.isNotEmpty) {
        _existingCoverImageData = coverImage;
      } else if (coverImage is Map<String, dynamic> &&
          coverImage['data'] != null) {
        _existingCoverImageData = coverImage['data'] as String;
      }
    }

    final coverImageIdValue = widget.event['coverImageId'];
    _existingCoverImageId = coverImageIdValue?.toString();

    final galleryImages = widget.event['galleryImages'];
    if (galleryImages != null && galleryImages is List) {
      _existingGalleryImageData = galleryImages
          .map((e) {
            if (e is String) {
              return e;
            } else if (e is Map<String, dynamic> && e['data'] != null) {
              return e['data'] as String;
            }
            return null;
          })
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final galleryImageIds = widget.event['galleryImageIds'];
    if (galleryImageIds != null && galleryImageIds is List) {
      _existingGalleryImageIds = galleryImageIds
          .map((e) => e?.toString())
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .toList();
    }
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
    } catch (e) {}
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesLoading = true;
    });

    try {
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      final result = await categoryProvider.get();

      if (mounted) {
        setState(() {
          _categories = result.result;
          _categoriesLoading = false;

          if (_selectedCategoryId != null) {
            final categoryExists = _categories.any(
              (cat) => cat.id == _selectedCategoryId,
            );
            if (!categoryExists) {
              if (_categories.isNotEmpty) {
                _selectedCategoryId = _categories.first.id;
              }
            }
          } else if (_categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
        });
      }
    } catch (e) {
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
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _mainImage != null
                  ? Image.file(
                      File(_mainImage!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 160,
                    )
                  : _existingCoverImageData != null
                  ? _buildBase64Image(_existingCoverImageData!, 160)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 40),
                          SizedBox(height: 8),
                          Text('Add main image'),
                        ],
                      ),
                    ),
            ),
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
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: index < _additionalImages.length
                      ? Image.file(
                          File(_additionalImages[index].path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 80,
                        )
                      : index < _existingGalleryImageData.length
                      ? _buildBase64Image(_existingGalleryImageData[index], 80)
                      : const Center(child: Icon(Icons.add)),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBase64Image(String imageData, double height) {
    try {
      String base64String = imageData;
      if (imageData.startsWith('data:image')) {
        base64String = imageData.split(',').last;
      }
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.broken_image)),
          );
        },
      );
    } catch (e) {
      return Container(
        height: height,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.broken_image)),
      );
    }
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
    DateTimeRange? initialDateRange;
    final currentDateText = _dateController.text;
    if (currentDateText.contains(' - ')) {
      final parts = currentDateText.split(' - ');
      if (parts.length == 2) {
        try {
          final startDate = DateTime.parse(parts[0].trim());
          final endDate = DateTime.parse(parts[1].trim());
          initialDateRange = DateTimeRange(start: startDate, end: endDate);
        } catch (e) {}
      }
    } else if (currentDateText.isNotEmpty) {
      try {
        final singleDate = DateTime.parse(currentDateText.trim());
        initialDateRange = DateTimeRange(
          start: singleDate,
          end: singleDate.add(const Duration(days: 1)),
        );
      } catch (e) {}
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange:
          initialDateRange ??
          DateTimeRange(start: today, end: today.add(const Duration(days: 1))),
      firstDate: today,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.start.toLocal().toString().split(' ')[0]} - ${picked.end.toLocal().toString().split(' ')[0]}";
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

  Future<void> _handleTicketTypeChange(String eventId, String eventDate) async {
    try {
      final ticketProvider = Provider.of<TicketProvider>(
        context,
        listen: false,
      );

      final wasPaid = _originalIsPaid;
      final isNowPaid = _isPaid;

      if (!wasPaid && isNowPaid) {
        await _validateAndDeleteTicketsForPaidEvent(
          eventId,
          eventDate,
          ticketProvider,
        );
      } else if (wasPaid && !isNowPaid) {
        await _validateAndDeleteTicketsForFreeEvent(
          eventId,
          eventDate,
          ticketProvider,
        );
      } else if (wasPaid && isNowPaid) {
        await _updateTicketsForPaidEvent(eventId, eventDate, ticketProvider);
      } else if (!wasPaid && !isNowPaid) {
        await _updateTicketsForFreeEvent(eventId, eventDate, ticketProvider);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _validateAndDeleteTicketsForFreeEvent(
    String eventId,
    String eventDate,
    TicketProvider ticketProvider,
  ) async {
    for (var ticket in _existingTickets) {
      if (ticket.quantitySold > 0) {
        throw Exception(
          'Cannot change event to free. ${ticket.quantitySold} ${ticket.ticketType} ticket(s) have already been sold.',
        );
      }
    }

    if (_existingTickets.isNotEmpty) {
      await ticketProvider.deleteAllTicketsForEvent(eventId);
    }

    final capacity = int.tryParse(_capacityController.text) ?? 0;
    if (capacity > 0) {
      DateTime saleStartDate = DateTime.now();
      DateTime eventDateParsed = DateTime.parse(eventDate);
      DateTime eventDateEndOfDay = DateTime(
        eventDateParsed.year,
        eventDateParsed.month,
        eventDateParsed.day,
        23,
        59,
        59,
      );
      DateTime saleEndDate =
          eventDateEndOfDay.isBefore(saleStartDate) ||
              eventDateEndOfDay.isAtSameMomentAs(saleStartDate)
          ? saleStartDate.add(const Duration(days: 1))
          : eventDateEndOfDay;

      final freeTicketData = {
        'eventId': eventId,
        'ticketType': 'Free',
        'price': 0.0,
        'quantity': capacity,
        'saleStartDate': saleStartDate.toIso8601String(),
        'saleEndDate': saleEndDate.toIso8601String(),
      };
      await ticketProvider.createTicket(freeTicketData);
    }
  }

  Future<void> _validateAndDeleteTicketsForPaidEvent(
    String eventId,
    String eventDate,
    TicketProvider ticketProvider,
  ) async {
    for (var ticket in _existingTickets) {
      if (ticket.ticketType == 'Free' && ticket.quantitySold > 0) {
        throw Exception(
          'Cannot change event to paid. ${ticket.quantitySold} free ticket(s) have already been purchased.',
        );
      }
    }

    final freeTickets = _existingTickets
        .where((t) => t.ticketType == 'Free')
        .toList();
    if (freeTickets.isNotEmpty) {
      for (var ticket in freeTickets) {
        await ticketProvider.deleteTicket(ticket.id);
      }
    }

    await _createTicketsForPaidEvent(eventId, eventDate, ticketProvider);
  }

  Future<void> _createTicketsForPaidEvent(
    String eventId,
    String eventDate,
    TicketProvider ticketProvider,
  ) async {
    final vipPrice = double.tryParse(_vipPriceController.text) ?? 0.0;
    final vipCount = int.tryParse(_vipCountController.text) ?? 0;
    final ecoPrice = double.tryParse(_ecoPriceController.text) ?? 0.0;
    final ecoCount = int.tryParse(_ecoCountController.text) ?? 0;

    final hasVip = vipCount > 0 && vipPrice > 0;
    final hasEco = ecoCount > 0 && ecoPrice > 0;

    if (!hasVip && !hasEco) {
      throw Exception(
        'Paid events must have at least one ticket type (VIP or Economy) with both price and quantity greater than 0',
      );
    }

    if (vipCount > 0 && vipPrice <= 0) {
      throw Exception('VIP tickets require a price greater than 0');
    }
    if (vipPrice > 0 && vipCount <= 0) {
      throw Exception('VIP tickets require a quantity greater than 0');
    }

    if (ecoCount > 0 && ecoPrice <= 0) {
      throw Exception('Economy tickets require a price greater than 0');
    }
    if (ecoPrice > 0 && ecoCount <= 0) {
      throw Exception('Economy tickets require a quantity greater than 0');
    }

    DateTime saleStartDate = DateTime.now();
    DateTime eventDateParsed = DateTime.parse(eventDate);

    DateTime eventDateEndOfDay = DateTime(
      eventDateParsed.year,
      eventDateParsed.month,
      eventDateParsed.day,
      23,
      59,
      59,
    );

    DateTime saleEndDate =
        eventDateEndOfDay.isBefore(saleStartDate) ||
            eventDateEndOfDay.isAtSameMomentAs(saleStartDate)
        ? saleStartDate.add(const Duration(days: 1))
        : eventDateEndOfDay;

    if (hasVip) {
      final vipTicketData = {
        'eventId': eventId,
        'ticketType': 'Vip',
        'price': vipPrice,
        'quantity': vipCount,
        'saleStartDate': saleStartDate.toIso8601String(),
        'saleEndDate': saleEndDate.toIso8601String(),
      };
      await ticketProvider.createTicket(vipTicketData);
    }

    if (hasEco) {
      final ecoTicketData = {
        'eventId': eventId,
        'ticketType': 'Economy',
        'price': ecoPrice,
        'quantity': ecoCount,
        'saleStartDate': saleStartDate.toIso8601String(),
        'saleEndDate': saleEndDate.toIso8601String(),
      };
      await ticketProvider.createTicket(ecoTicketData);
    }
  }

  Future<void> _updateTicketsForFreeEvent(
    String eventId,
    String eventDate,
    TicketProvider ticketProvider,
  ) async {
    final capacity = int.tryParse(_capacityController.text) ?? 0;

    if (capacity <= 0) {
      throw Exception('Free events require a capacity greater than 0');
    }

    Ticket? existingFreeTicket;
    for (var ticket in _existingTickets) {
      if (ticket.ticketType == 'Free' && ticket.price == 0) {
        existingFreeTicket = ticket;
        break;
      }
    }

    DateTime saleStartDate = DateTime.now();
    DateTime eventDateParsed = DateTime.parse(eventDate);
    DateTime eventDateEndOfDay = DateTime(
      eventDateParsed.year,
      eventDateParsed.month,
      eventDateParsed.day,
      23,
      59,
      59,
    );
    DateTime saleEndDate =
        eventDateEndOfDay.isBefore(saleStartDate) ||
            eventDateEndOfDay.isAtSameMomentAs(saleStartDate)
        ? saleStartDate.add(const Duration(days: 1))
        : eventDateEndOfDay;

    final freeTicketData = {
      'eventId': eventId,
      'ticketType': 'Free',
      'price': 0.0,
      'quantity': capacity,
      'saleStartDate': saleStartDate.toIso8601String(),
      'saleEndDate': saleEndDate.toIso8601String(),
    };

    if (existingFreeTicket != null) {
      freeTicketData['id'] = existingFreeTicket.id;
      await ticketProvider.updateTicket(existingFreeTicket.id, freeTicketData);
    } else {
      await ticketProvider.createTicket(freeTicketData);
    }
  }

  Future<void> _updateTicketsForPaidEvent(
    String eventId,
    String eventDate,
    TicketProvider ticketProvider,
  ) async {
    final vipPrice = double.tryParse(_vipPriceController.text) ?? 0.0;
    final vipCount = int.tryParse(_vipCountController.text) ?? 0;
    final ecoPrice = double.tryParse(_ecoPriceController.text) ?? 0.0;
    final ecoCount = int.tryParse(_ecoCountController.text) ?? 0;

    final hasVip = vipCount > 0 && vipPrice > 0;
    final hasEco = ecoCount > 0 && ecoPrice > 0;

    if (!hasVip && !hasEco) {
      throw Exception(
        'Paid events must have at least one ticket type (VIP or Economy) with both price and quantity greater than 0',
      );
    }

    if (vipCount > 0 && vipPrice <= 0) {
      throw Exception('VIP tickets require a price greater than 0');
    }
    if (vipPrice > 0 && vipCount <= 0) {
      throw Exception('VIP tickets require a quantity greater than 0');
    }

    if (ecoCount > 0 && ecoPrice <= 0) {
      throw Exception('Economy tickets require a price greater than 0');
    }
    if (ecoPrice > 0 && ecoCount <= 0) {
      throw Exception('Economy tickets require a quantity greater than 0');
    }

    DateTime saleStartDate = DateTime.now();
    DateTime eventDateParsed = DateTime.parse(eventDate);

    DateTime eventDateEndOfDay = DateTime(
      eventDateParsed.year,
      eventDateParsed.month,
      eventDateParsed.day,
      23,
      59,
      59,
    );

    DateTime saleEndDate =
        eventDateEndOfDay.isBefore(saleStartDate) ||
            eventDateEndOfDay.isAtSameMomentAs(saleStartDate)
        ? saleStartDate.add(const Duration(days: 1))
        : eventDateEndOfDay;

    Ticket? existingVipTicket;
    Ticket? existingEcoTicket;

    for (var ticket in _existingTickets) {
      if (ticket.ticketType == 'Vip') {
        existingVipTicket = ticket;
      } else if (ticket.ticketType == 'Economy') {
        existingEcoTicket = ticket;
      }
    }

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
        vipTicketData['id'] = existingVipTicket.id;
        await ticketProvider.updateTicket(existingVipTicket.id, vipTicketData);
      } else {
        await ticketProvider.createTicket(vipTicketData);
      }
    } else if (existingVipTicket != null) {
      if (existingVipTicket.quantitySold > 0) {
        throw Exception(
          'Cannot delete VIP ticket. ${existingVipTicket.quantitySold} ticket(s) have already been sold.',
        );
      }
      await ticketProvider.deleteTicket(existingVipTicket.id);
    }

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
        ecoTicketData['id'] = existingEcoTicket.id;
        await ticketProvider.updateTicket(existingEcoTicket.id, ecoTicketData);
      } else {
        await ticketProvider.createTicket(ecoTicketData);
      }
    } else if (existingEcoTicket != null) {
      if (existingEcoTicket.quantitySold > 0) {
        throw Exception(
          'Cannot delete Economy ticket. ${existingEcoTicket.quantitySold} ticket(s) have already been sold.',
        );
      }
      await ticketProvider.deleteTicket(existingEcoTicket.id);
    }
  }

  Future<void> _replaceGalleryImages(
    String eventId,
    List<String> imageIds,
  ) async {
    try {
      final url =
          "${Provider.of<EventProvider>(context, listen: false).baseUrl}Event/$eventId/gallery-images";
      final uri = Uri.parse(url);
      final headers = Provider.of<EventProvider>(
        context,
        listen: false,
      ).createHeaders();

      final guidIds = imageIds.map((id) => id).toList();

      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(guidIds),
      );

      if (response.statusCode >= 300) {
        throw Exception(
          'Failed to replace gallery images: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateController.text.isNotEmpty &&
        _startTimeController.text.isNotEmpty &&
        _endTimeController.text.isNotEmpty) {
      try {
        final dateRangeParts = _dateController.text.split(' - ');
        if (dateRangeParts.length == 2) {
          final startDateStr = dateRangeParts[0].trim();
          final endDateStr = dateRangeParts[1].trim();

          if (startDateStr == endDateStr) {
            int formatTimeToMinutes(String timeStr) {
              final parts = timeStr.split(' ');
              final timePart = parts[0];
              final timeParts = timePart.split(':');
              int hour = int.parse(timeParts[0]);
              final minute = int.parse(timeParts[1]);

              if (parts.length > 1) {
                final period = parts[1].toUpperCase();
                if (period == 'PM' && hour != 12) {
                  hour += 12;
                } else if (period == 'AM' && hour == 12) {
                  hour = 0;
                }
              }

              return hour * 60 + minute;
            }

            final startTimeMinutes = formatTimeToMinutes(
              _startTimeController.text,
            );
            final endTimeMinutes = formatTimeToMinutes(_endTimeController.text);

            if (startTimeMinutes >= endTimeMinutes) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Start time must be before end time when dates are the same',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
          }
        }
      } catch (e) {}
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final event = widget.event;

      final dateRangeParts = _dateController.text.split(' - ');
      String startDateStr;
      String endDateStr;

      if (dateRangeParts.length == 2) {
        startDateStr = dateRangeParts[0].trim();
        endDateStr = dateRangeParts[1].trim();
      } else {
        final dateStr = _dateController.text.trim();
        if (dateStr.contains('/')) {
          final parts = dateStr.split('/');
          if (parts.length == 3) {
            startDateStr =
                '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
          } else {
            startDateStr = dateStr;
          }
        } else {
          startDateStr = dateStr;
        }
        endDateStr = startDateStr;
      }

      int calculatedCapacity;
      if (_isPaid) {
        final vipCount = int.tryParse(_vipCountController.text) ?? 0;
        final ecoCount = int.tryParse(_ecoCountController.text) ?? 0;
        calculatedCapacity = vipCount + ecoCount;
      } else {
        calculatedCapacity = int.tryParse(_capacityController.text) ?? 0;
      }

      String? coverImageId;
      if (_mainImage != null) {
        final imageProvider = Provider.of<EventImageProvider>(
          context,
          listen: false,
        );
        final bytes = await File(_mainImage!.path).readAsBytes();
        final base64Image = base64Encode(bytes);
        final mainImageRequest = {
          'Data': base64Image,
          'ContentType': 'image/jpeg',
          'ImageType': 'EventCover',
        };
        final mainImageResponse = await imageProvider.insert(mainImageRequest);
        coverImageId = mainImageResponse.id;
      } else {
        coverImageId = _existingCoverImageId;
      }

      final updateData = {
        'id': event['id'],
        'title': _nameController.text,
        'description': _descriptionController.text,
        'location': _venueController.text,
        'startDate': startDateStr,
        'endDate': endDateStr,
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'capacity': calculatedCapacity,
        'currentAttendees': event['currentAttendees'] ?? 0,
        'availableTicketsCount': calculatedCapacity,
        'status': event['status'] ?? 'Upcoming',
        'isFeatured': event['isFeatured'] ?? false,
        'type': event['type'] ?? 'Public',
        'isPublished': true,
        'isPaid': _isPaid,
        'categoryId': _selectedCategoryId ?? event['categoryId'],
        'coverImageId': coverImageId,
      };

      await eventProvider.updateEvent(event['id'], updateData);

      final imageProvider = Provider.of<EventImageProvider>(
        context,
        listen: false,
      );
      List<String> finalGalleryImageIds = [];

      for (int i = 0; i < 3; i++) {
        if (i < _additionalImages.length) {
          final additionalImage = _additionalImages[i];
          final bytes = await File(additionalImage.path).readAsBytes();
          final base64Image = base64Encode(bytes);
          final imageRequest = {
            'Data': base64Image,
            'ContentType': 'image/jpeg',
            'ImageType': 'EventGallery',
            'EventId': event['id'],
          };
          final imageResponse = await imageProvider.insert(imageRequest);
          if (imageResponse.id != null && imageResponse.id!.isNotEmpty) {
            finalGalleryImageIds.add(imageResponse.id!);
          }
        } else if (i < _existingGalleryImageIds.length) {
          finalGalleryImageIds.add(_existingGalleryImageIds[i]);
        }
      }

      await _replaceGalleryImages(event['id'], finalGalleryImageIds);

      await _handleTicketTypeChange(event['id'], endDateStr);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

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
