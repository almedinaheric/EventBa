import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/widgets/primary_button.dart';
import 'package:eventba_admin/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:eventba_admin/providers/event_provider.dart';
import 'package:eventba_admin/providers/image_provider.dart';
import 'package:eventba_admin/providers/category_provider.dart';

import 'package:image_picker/image_picker.dart';
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

  final TextEditingController _nameController = TextEditingController();
  String? _selectedCategoryId;
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

  XFile? _mainImage;
  List<XFile> _additionalImages = [];

  bool _isPaid = false;
  bool _isLoading = false;

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
    final formWidth = screenWidth * 0.6;

    return MasterScreen(
      title: 'Create Event',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: formWidth,
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
                    width: screenWidth * 0.6,
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
                    width: screenWidth * 0.6,
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
                    width: screenWidth * 0.6,
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
                      width: screenWidth * 0.6,
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
                  const SizedBox(height: 60),
                ],
              ),
            ),
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
            width: screenWidth * 0.6,
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
                width: (screenWidth * 0.6 - 24) / 3,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Failed to pick image: ${e.toString()}'),
          ),
        );
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Failed to pick image: ${e.toString()}'),
          ),
        );
      }
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: tomorrow,
        end: tomorrow.add(const Duration(days: 1)),
      ),
      firstDate: tomorrow,
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

    bool timeValid = true;
    String? timeErrorMessage;
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
              timeValid = false;
              timeErrorMessage =
                  'Start time must be before end time when dates are the same';
            }
          }
        }
      } catch (e) {}
    }

    bool allValid =
        _isNameValid &&
        _isCategoryValid &&
        _isVenueValid &&
        _isDateValid &&
        _isStartTimeValid &&
        _isEndTimeValid &&
        _isDescriptionValid &&
        timeValid &&
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
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            timeErrorMessage ?? 'Please fix errors before submitting',
          ),
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

      final dateRangeParts = _dateController.text.split(' - ');
      if (dateRangeParts.length != 2) {
        throw FormatException(
          'Invalid date range format. Expected "YYYY-MM-DD - YYYY-MM-DD"',
        );
      }

      final startDateFormatted = dateRangeParts[0];
      final endDateFormatted = dateRangeParts[1];

      String formatTime(String timeStr) {
        try {
          if (timeStr.contains('AM') || timeStr.contains('PM')) {
            final parts = timeStr
                .replaceAll(' AM', '')
                .replaceAll(' PM', '')
                .split(':');
            if (parts.length >= 2) {
              int hour = int.parse(parts[0]);
              int minute = int.parse(parts[1]);

              if (timeStr.contains('PM') && hour != 12) {
                hour += 12;
              } else if (timeStr.contains('AM') && hour == 12) {
                hour = 0;
              }

              return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
            }
          } else {
            final parts = timeStr.split(':');
            if (parts.length >= 2) {
              final hour = parts[0].padLeft(2, '0');
              final minute = parts[1].padLeft(2, '0');
              return '$hour:$minute:00';
            }
          }
          return timeStr;
        } catch (e) {
          return timeStr;
        }
      }

      final startTimeFormatted = formatTime(_startTimeController.text);
      final endTimeFormatted = formatTime(_endTimeController.text);

      String? coverImageId;
      if (_mainImage != null) {
        final bytes = await File(_mainImage!.path).readAsBytes();
        final base64Image = base64Encode(bytes);
        final mainImageRequest = {
          'Data': base64Image,
          'ContentType': 'image/jpeg',
        };
        final mainImageResponse = await imageProvider.insert(mainImageRequest);
        coverImageId = mainImageResponse.id;
      }

      int totalCapacity;
      if (_isPaid) {
        totalCapacity =
            int.parse(_vipCountController.text.trim()) +
            int.parse(_ecoCountController.text.trim());
      } else {
        totalCapacity = int.parse(_capacityController.text.trim());
      }

      final request = {
        'title': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _venueController.text.trim(),
        'startDate': startDateFormatted,
        'endDate': endDateFormatted,
        'startTime': startTimeFormatted,
        'endTime': endTimeFormatted,
        'capacity': totalCapacity,
        'availableTicketsCount': totalCapacity,
        'status': 'Upcoming',
        'isFeatured': false,
        'type': 'Public',
        'isPublished': true,
        'isPaid': _isPaid,
        'categoryId': _selectedCategoryId,
        if (coverImageId != null) 'coverImageId': coverImageId,
      };

      final createdEvent = await eventProvider.insert(request);
      final eventId = createdEvent.id;

      if (_additionalImages.isNotEmpty) {
        List<String> galleryImageIds = [];

        for (var i = 0; i < _additionalImages.length; i++) {
          final additionalImage = _additionalImages[i];
          final bytes = await File(additionalImage.path).readAsBytes();
          final base64Image = base64Encode(bytes);
          final imageRequest = {
            'Data': base64Image,
            'ContentType': 'image/jpeg',
            'ImageType': 'EventGallery',
            'EventId': eventId,
          };
          final imageResponse = await imageProvider.insert(imageRequest);
          galleryImageIds.add(imageResponse.id!);
        }

        if (galleryImageIds.isNotEmpty) {
          await _linkGalleryImages(eventId, galleryImageIds);
        }
      }

      try {
        await _createTickets(eventId, startDateFormatted);
      } catch (e) {}

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Event created successfully!'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
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
          'Failed to link gallery images: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {}
  }

  Future<void> _createTickets(String eventId, String eventDate) async {
    final url =
        "${Provider.of<EventProvider>(context, listen: false).baseUrl}Ticket";
    final uri = Uri.parse(url);
    final headers = Provider.of<EventProvider>(
      context,
      listen: false,
    ).createHeaders();

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

    if (_isPaid) {
      final vipCount = int.tryParse(_vipCountController.text.trim()) ?? 0;
      final vipPrice = double.tryParse(_vipPriceController.text.trim()) ?? 0.0;

      if (vipCount > 0 && vipPrice > 0) {
        final vipTicketRequest = {
          'eventId': eventId,
          'ticketType': 'Vip',
          'price': vipPrice,
          'quantity': vipCount,
          'saleStartDate': saleStartDate.toIso8601String(),
          'saleEndDate': saleEndDate.toIso8601String(),
        };

        final vipResponse = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(vipTicketRequest),
        );

        if (vipResponse.statusCode >= 300) {
          throw Exception(
            'Failed to create VIP ticket: ${vipResponse.statusCode} - ${vipResponse.body}',
          );
        }
      }

      final ecoCount = int.tryParse(_ecoCountController.text.trim()) ?? 0;
      final ecoPrice = double.tryParse(_ecoPriceController.text.trim()) ?? 0.0;

      if (ecoCount > 0 && ecoPrice > 0) {
        final ecoTicketRequest = {
          'eventId': eventId,
          'ticketType': 'Economy',
          'price': ecoPrice,
          'quantity': ecoCount,
          'saleStartDate': saleStartDate.toIso8601String(),
          'saleEndDate': saleEndDate.toIso8601String(),
        };

        final ecoResponse = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(ecoTicketRequest),
        );

        if (ecoResponse.statusCode >= 300) {
          throw Exception(
            'Failed to create Economy ticket: ${ecoResponse.statusCode} - ${ecoResponse.body}',
          );
        }
      }
    } else {
      final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
      if (capacity > 0) {
        final freeTicketRequest = {
          'eventId': eventId,
          'ticketType': 'Free',
          'price': 0.0,
          'quantity': capacity,
          'saleStartDate': saleStartDate.toIso8601String(),
          'saleEndDate': saleEndDate.toIso8601String(),
        };

        final freeResponse = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(freeTicketRequest),
        );

        if (freeResponse.statusCode >= 300) {
          throw Exception(
            'Failed to create free ticket: ${freeResponse.statusCode} - ${freeResponse.body}',
          );
        }
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
