import 'dart:convert';
import 'dart:io';
import 'package:eventba_mobile/providers/event_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eventba_mobile/providers/category_provider.dart';
import 'package:http/http.dart' as http;

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({super.key});

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _categories = [];

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _vipPriceController = TextEditingController();
  final TextEditingController _vipCountController = TextEditingController();
  final TextEditingController _ecoPriceController = TextEditingController();
  final TextEditingController _ecoCountController = TextEditingController();

  // Image handling
  XFile? _mainImage;
  List<XFile> _additionalImages = [];

  bool _isPaid = false;
  bool _isLoading = false;

  // Validation flags and error messages
  bool _isNameValid = true;
  bool _isCategoryValid = true;
  bool _isVenueValid = true;
  bool _isDateValid = true;
  bool _isStartTimeValid = true;
  bool _isEndTimeValid = true;
  bool _isDescriptionValid = true;
  bool _isCapacityValid = true;
  bool _isVipPriceValid = true;
  bool _isVipCountValid = true;
  bool _isEcoPriceValid = true;
  bool _isEcoCountValid = true;

  String? _nameErrorMessage;
  String? _categoryErrorMessage;
  String? _venueErrorMessage;
  String? _dateErrorMessage;
  String? _startTimeErrorMessage;
  String? _endTimeErrorMessage;
  String? _descriptionErrorMessage;
  String? _capacityErrorMessage;
  String? _vipPriceErrorMessage;
  String? _vipCountErrorMessage;
  String? _ecoPriceErrorMessage;
  String? _ecoCountErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      final categories = await categoryProvider.get();

      setState(() {
        _categories = categories.result
            .map((category) => {'id': category.id, 'name': category.name})
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Failed to fetch categories: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                isValid: _isNameValid,
                errorMessage: _nameErrorMessage,
                width: screenWidth * 0.9,
                onChanged: (text) {
                  setState(() {
                    _isNameValid = text.trim().isNotEmpty;
                    _nameErrorMessage = _isNameValid
                        ? null
                        : 'Event name is required';
                  });
                },
              ),
              const SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Event category',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF9FBFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: _isCategoryValid
                          ? null
                          : _categoryErrorMessage,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    hint: const Text('Choose category'),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategoryId = newValue;
                        _selectedCategoryName = _categories.firstWhere(
                          (c) => c['id'] == newValue,
                        )['name'];
                        _isCategoryValid = newValue != null;
                        _categoryErrorMessage = _isCategoryValid
                            ? null
                            : 'Category is required';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Category is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _venueController,
                label: 'Venue address',
                hint: 'Enter venue address',
                isValid: _isVenueValid,
                errorMessage: _venueErrorMessage,
                width: screenWidth * 0.9,
                onChanged: (text) {
                  setState(() {
                    _isVenueValid = text.trim().isNotEmpty;
                    _venueErrorMessage = _isVenueValid
                        ? null
                        : 'Venue is required';
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _dateController,
                label: 'Date',
                hint: 'Select date',
                isValid: _isDateValid,
                errorMessage: _dateErrorMessage,
                width: double.infinity,
                readOnly: true,
                onTap: _pickDate,
                onChanged: (text) {
                  setState(() {
                    _isDateValid = text.trim().isNotEmpty;
                    _dateErrorMessage = _isDateValid
                        ? null
                        : 'Date is required';
                  });
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _startTimeController,
                      label: 'Start time',
                      hint: 'Start',
                      isValid: _isStartTimeValid,
                      errorMessage: _startTimeErrorMessage,
                      width: double.infinity,
                      readOnly: true,
                      onTap: _pickStartTime,
                      onChanged: (text) {
                        setState(() {
                          _isStartTimeValid = text.trim().isNotEmpty;
                          _startTimeErrorMessage = _isStartTimeValid
                              ? null
                              : 'Start time is required';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _endTimeController,
                      label: 'End time',
                      hint: 'End',
                      isValid: _isEndTimeValid,
                      errorMessage: _endTimeErrorMessage,
                      width: double.infinity,
                      readOnly: true,
                      onTap: _pickEndTime,
                      onChanged: (text) {
                        setState(() {
                          _isEndTimeValid = text.trim().isNotEmpty;
                          _endTimeErrorMessage = _isEndTimeValid
                              ? null
                              : 'End time is required';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Add description',
                isValid: _isDescriptionValid,
                errorMessage: _descriptionErrorMessage,
                width: screenWidth * 0.9,
                maxLines: 3,
                onChanged: (text) {
                  setState(() {
                    _isDescriptionValid = text.trim().isNotEmpty;
                    _descriptionErrorMessage = _isDescriptionValid
                        ? null
                        : 'Description is required';
                  });
                },
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
                  isValid: _isCapacityValid,
                  errorMessage: _capacityErrorMessage,
                  width: screenWidth * 0.9,
                  keyboardType: TextInputType.number,
                  onChanged: (text) {
                    setState(() {
                      _isCapacityValid =
                          text.trim().isNotEmpty &&
                          int.tryParse(text.trim()) != null &&
                          int.parse(text.trim()) > 0;
                      _capacityErrorMessage = _isCapacityValid
                          ? null
                          : 'Capacity required and must be a positive number';
                    });
                  },
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
                        isValid: _isVipPriceValid,
                        errorMessage: _vipPriceErrorMessage,
                        width: double.infinity,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (text) {
                          setState(() {
                            _isVipPriceValid =
                                text.trim().isNotEmpty &&
                                double.tryParse(text.trim()) != null &&
                                double.parse(text.trim()) >= 0;
                            _vipPriceErrorMessage = _isVipPriceValid
                                ? null
                                : 'VIP price required and must be a number ≥ 0';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _vipCountController,
                        hint: 'Number of VIP tickets',
                        isValid: _isVipCountValid,
                        errorMessage: _vipCountErrorMessage,
                        width: double.infinity,
                        keyboardType: TextInputType.number,
                        onChanged: (text) {
                          setState(() {
                            _isVipCountValid =
                                text.trim().isNotEmpty &&
                                int.tryParse(text.trim()) != null &&
                                int.parse(text.trim()) >= 0;
                            _vipCountErrorMessage = _isVipCountValid
                                ? null
                                : 'VIP ticket count required and must be ≥ 0';
                          });
                        },
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
                        isValid: _isEcoPriceValid,
                        errorMessage: _ecoPriceErrorMessage,
                        width: double.infinity,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (text) {
                          setState(() {
                            _isEcoPriceValid =
                                text.trim().isNotEmpty &&
                                double.tryParse(text.trim()) != null &&
                                double.parse(text.trim()) >= 0;
                            _ecoPriceErrorMessage = _isEcoPriceValid
                                ? null
                                : 'Economy price required and must be ≥ 0';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _ecoCountController,
                        hint: 'Number of economy tickets',
                        isValid: _isEcoCountValid,
                        errorMessage: _ecoCountErrorMessage,
                        width: double.infinity,
                        keyboardType: TextInputType.number,
                        onChanged: (text) {
                          setState(() {
                            _isEcoCountValid =
                                text.trim().isNotEmpty &&
                                int.tryParse(text.trim()) != null &&
                                int.parse(text.trim()) >= 0;
                            _ecoCountErrorMessage = _isEcoCountValid
                                ? null
                                : 'Economy ticket count required and must be ≥ 0';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),
              Center(
                child: PrimaryButton(
                  text: _isLoading ? "Creating..." : "Create Event",
                  onPressed: _isLoading ? () {} : _onSubmitPressed,
                ),
              ),
              const SizedBox(height: 60), // for safe area
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
                width: (screenWidth * 0.9 - 24) / 3,
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
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _mainImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Failed to pick image: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> _pickAdditionalImage(int index) async {
    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Failed to pick image: ${e.toString()}'),
        ),
      );
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
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 1)),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.start.toLocal().toString().split(' ')[0]} - ${picked.end.toLocal().toString().split(' ')[0]}";
        _isDateValid = true;
        _dateErrorMessage = null;
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
        _isStartTimeValid = true;
        _startTimeErrorMessage = null;
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
        _isEndTimeValid = true;
        _endTimeErrorMessage = null;
      });
    }
  }

  void _validateForm() {
    setState(() {
      _isNameValid = _nameController.text.trim().isNotEmpty;
      _nameErrorMessage = _isNameValid ? null : 'Event name is required';

      _isCategoryValid = _selectedCategoryId != null;
      _categoryErrorMessage = _isCategoryValid ? null : 'Category is required';

      _isVenueValid = _venueController.text.trim().isNotEmpty;
      _venueErrorMessage = _isVenueValid ? null : 'Venue is required';

      _isDateValid = _dateController.text.trim().isNotEmpty;
      _dateErrorMessage = _isDateValid ? null : 'Date is required';

      _isStartTimeValid = _startTimeController.text.trim().isNotEmpty;
      _startTimeErrorMessage = _isStartTimeValid
          ? null
          : 'Start time is required';

      _isEndTimeValid = _endTimeController.text.trim().isNotEmpty;
      _endTimeErrorMessage = _isEndTimeValid ? null : 'End time is required';

      _isDescriptionValid = _descriptionController.text.trim().isNotEmpty;
      _descriptionErrorMessage = _isDescriptionValid
          ? null
          : 'Description is required';

      if (!_isPaid) {
        _isCapacityValid =
            _capacityController.text.trim().isNotEmpty &&
            int.tryParse(_capacityController.text.trim()) != null &&
            int.parse(_capacityController.text.trim()) > 0;
        _capacityErrorMessage = _isCapacityValid
            ? null
            : 'Capacity required and must be a positive number';
      } else {
        _isVipPriceValid =
            _vipPriceController.text.trim().isNotEmpty &&
            double.tryParse(_vipPriceController.text.trim()) != null &&
            double.parse(_vipPriceController.text.trim()) >= 0;
        _vipPriceErrorMessage = _isVipPriceValid
            ? null
            : 'VIP price required and must be a number ≥ 0';

        _isVipCountValid =
            _vipCountController.text.trim().isNotEmpty &&
            int.tryParse(_vipCountController.text.trim()) != null &&
            int.parse(_vipCountController.text.trim()) >= 0;
        _vipCountErrorMessage = _isVipCountValid
            ? null
            : 'VIP ticket count required and must be ≥ 0';

        _isEcoPriceValid =
            _ecoPriceController.text.trim().isNotEmpty &&
            double.tryParse(_ecoPriceController.text.trim()) != null &&
            double.parse(_ecoPriceController.text.trim()) >= 0;
        _ecoPriceErrorMessage = _isEcoPriceValid
            ? null
            : 'Economy price required and must be ≥ 0';

        _isEcoCountValid =
            _ecoCountController.text.trim().isNotEmpty &&
            int.tryParse(_ecoCountController.text.trim()) != null &&
            int.parse(_ecoCountController.text.trim()) >= 0;
        _ecoCountErrorMessage = _isEcoCountValid
            ? null
            : 'Economy ticket count required and must be ≥ 0';
      }
    });
  }

  void _onSubmitPressed() {
    _validateForm();

    bool allValid =
        _isNameValid &&
        _isCategoryValid &&
        _isVenueValid &&
        _isDateValid &&
        _isStartTimeValid &&
        _isEndTimeValid &&
        _isDescriptionValid &&
        (!_isPaid
            ? _isCapacityValid
            : (_isVipPriceValid &&
                  _isVipCountValid &&
                  _isEcoPriceValid &&
                  _isEcoCountValid));

    if (allValid) {
      _createEvent();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Please fix errors before submitting'),
        ),
      );
    }
  }

  Future<void> _createEvent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final imageProvider = Provider.of<EventImageProvider>(
        context,
        listen: false,
      );

      // Split the date range into start and end date strings
      final dateRangeParts = _dateController.text.split(' - ');
      if (dateRangeParts.length != 2) {
        throw FormatException(
          'Invalid date range format. Expected "YYYY-MM-DD - YYYY-MM-DD"',
        );
      }

      final startDateParts = dateRangeParts[0].split('-');
      final endDateParts = dateRangeParts[1].split('-');

      if (startDateParts.length != 3 || endDateParts.length != 3) {
        throw FormatException('Invalid date format. Use YYYY-MM-DD');
      }

      final startDateFormatted =
          '${startDateParts[2]}-${startDateParts[1]}-${startDateParts[0]}';
      final endDateFormatted =
          '${endDateParts[2]}-${endDateParts[1]}-${endDateParts[0]}';

      final startTimeParts = _startTimeController.text.split(':');
      final endTimeParts = _endTimeController.text.split(':');

      // Upload main/cover image
      String? coverImageId;
      if (_mainImage != null) {
        final bytes = await File(_mainImage!.path).readAsBytes();
        final mainImageRequest = {'data': bytes, 'contentType': 'image/jpeg'};
        final mainImageResponse = await imageProvider.insert(mainImageRequest);
        coverImageId = mainImageResponse.id;
      }

      // Calculate total capacity
      int totalCapacity;
      if (_isPaid) {
        totalCapacity =
            int.parse(_vipCountController.text.trim()) +
            int.parse(_ecoCountController.text.trim());
      } else {
        totalCapacity = int.parse(_capacityController.text.trim());
      }

      // Create event request
      final request = {
        'title': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _venueController.text.trim(),
        'startDate': startDateFormatted,
        'endDate': endDateFormatted,
        'startTime': '${startTimeParts[0]}:${startTimeParts[1]}:00',
        'endTime': '${endTimeParts[0]}:${endTimeParts[1]}:00',
        'capacity': totalCapacity,
        'availableTicketsCount': totalCapacity,
        'status': 'Upcoming',
        'isFeatured': true,
        'type': _isPaid ? 'Public' : 'Private',
        'isPublished': true,
        'categoryId': _selectedCategoryId,
        'coverImageId': coverImageId,
      };

      print('Creating event with request: $request');

      final createdEvent = await eventProvider.insert(request);
      final eventId = createdEvent.id;

      print('Event created with ID: $eventId');

      // Upload and link gallery images
      if (_additionalImages.isNotEmpty) {
        List<String> galleryImageIds = [];

        for (var additionalImage in _additionalImages) {
          final bytes = await File(additionalImage.path).readAsBytes();
          final imageRequest = {'data': bytes, 'contentType': 'image/jpeg'};
          final imageResponse = await imageProvider.insert(imageRequest);
          galleryImageIds.add(imageResponse.id);
        }

        // Link gallery images to event
        if (galleryImageIds.isNotEmpty) {
          await _linkGalleryImages(eventId, galleryImageIds);
        }
      }

      // Create tickets (both for free and paid events)
      await _createTickets(eventId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Event created successfully!'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Failed to create event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Failed to create event: $e'),
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

  Future<void> _linkGalleryImages(String eventId, List<String> imageIds) async {
    try {
      final url =
          "${Provider.of<EventProvider>(context, listen: false).baseUrl}Event/$eventId/gallery-images";
      final uri = Uri.parse(url);
      final headers = Provider.of<EventProvider>(
        context,
        listen: false,
      ).createHeaders();

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(imageIds),
      );

      if (response.statusCode >= 300) {
        throw Exception(
          'Failed to link gallery images: ${response.statusCode}',
        );
      }

      print('Gallery images linked successfully');
    } catch (e) {
      print('Error linking gallery images: $e');
      // Don't throw - event is already created, this is optional
    }
  }

  Future<void> _createTickets(String eventId) async {
    try {
      final url =
          "${Provider.of<EventProvider>(context, listen: false).baseUrl}Ticket";
      final uri = Uri.parse(url);
      final headers = Provider.of<EventProvider>(
        context,
        listen: false,
      ).createHeaders();

      if (_isPaid) {
        // Create VIP ticket
        if (int.parse(_vipCountController.text.trim()) > 0) {
          final vipTicketRequest = {
            'eventId': eventId,
            'ticketType': 'Vip',
            'price': double.parse(_vipPriceController.text.trim()),
            'quantity': int.parse(_vipCountController.text.trim()),
            'saleStartDate': DateTime.now().toIso8601String(),
            'saleEndDate': DateTime.now()
                .add(const Duration(days: 365))
                .toIso8601String(),
          };

          final vipResponse = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(vipTicketRequest),
          );

          if (vipResponse.statusCode >= 300) {
            throw Exception(
              'Failed to create VIP ticket: ${vipResponse.statusCode}',
            );
          }
          print('VIP ticket created');
        }

        // Create Economy ticket
        if (int.parse(_ecoCountController.text.trim()) > 0) {
          final ecoTicketRequest = {
            'eventId': eventId,
            'ticketType': 'Economy',
            'price': double.parse(_ecoPriceController.text.trim()),
            'quantity': int.parse(_ecoCountController.text.trim()),
            'saleStartDate': DateTime.now().toIso8601String(),
            'saleEndDate': DateTime.now()
                .add(const Duration(days: 365))
                .toIso8601String(),
          };

          final ecoResponse = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(ecoTicketRequest),
          );

          if (ecoResponse.statusCode >= 300) {
            throw Exception(
              'Failed to create Economy ticket: ${ecoResponse.statusCode}',
            );
          }
          print('Economy ticket created');
        }
      } else {
        // Create free ticket
        final freeTicketRequest = {
          'eventId': eventId,
          'ticketType': 'Free',
          'price': 0.0,
          'quantity': int.parse(_capacityController.text.trim()),
          'saleStartDate': DateTime.now().toIso8601String(),
          'saleEndDate': DateTime.now()
              .add(const Duration(days: 365))
              .toIso8601String(),
        };

        final freeResponse = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(freeTicketRequest),
        );

        if (freeResponse.statusCode >= 300) {
          throw Exception(
            'Failed to create free ticket: ${freeResponse.statusCode}',
          );
        }
        print('Free ticket created');
      }
    } catch (e) {
      print('Error creating tickets: $e');
      throw e; // Rethrow as this is critical
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
