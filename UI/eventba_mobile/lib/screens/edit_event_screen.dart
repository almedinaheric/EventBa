import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:eventba_mobile/providers/event_provider.dart';
import 'package:eventba_mobile/providers/event_image_provider.dart';
import 'package:eventba_mobile/providers/category_provider.dart';
import 'package:eventba_mobile/providers/ticket_provider.dart';
import 'package:eventba_mobile/models/category/category_model.dart';
import 'package:eventba_mobile/models/ticket/ticket.dart';
import 'package:eventba_mobile/utils/image_helpers.dart';
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
  String? _selectedCategory;
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
  List<String> _existingGalleryImageData =
      []; 
  String? _existingCoverImageId; 
  List<String> _existingGalleryImageIds =
      []; 

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
    _selectedCategory =
        event['categoryId']; 
    _venueController = TextEditingController(text: event['venue']);
    _dateController = TextEditingController(text: event['date']);
    _startTimeController = TextEditingController(text: event['startTime']);
    _endTimeController = TextEditingController(text: event['endTime']);
    _descriptionController = TextEditingController(text: event['description']);
    _capacityController = TextEditingController(
      text: event['capacity'].toString(),
    );
    _vipPriceController = TextEditingController(
      text: event['vipPrice']?.toString() ?? '',
    );
    _vipCountController = TextEditingController(
      text: event['vipCount']?.toString() ?? '',
    );
    _ecoPriceController = TextEditingController(
      text: event['ecoPrice']?.toString() ?? '',
    );
    _ecoCountController = TextEditingController(
      text: event['ecoCount']?.toString() ?? '',
    );
    _isPaid = event['isPaid'] ?? false;
    _originalIsPaid = _isPaid; 

    
    _loadExistingImages();

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
      _loadExistingTickets();
      
      
      _fetchGalleryImageIds();
    });
  }

  Future<void> _fetchGalleryImageIds() async {
    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final eventId = widget.event['id'];
      print("Fetching event $eventId from backend to get gallery image IDs...");

      
      
      final url = "${eventProvider.baseUrl}Event/$eventId";
      final uri = Uri.parse(url);
      final headers = eventProvider.createHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body);
        final galleryImageIds = jsonData['galleryImageIds'];

        print("Raw JSON galleryImageIds: $galleryImageIds");

        if (galleryImageIds != null && galleryImageIds is List) {
          final fetchedIds = galleryImageIds
              .map((e) => e?.toString())
              .whereType<String>()
              .where((id) => id.isNotEmpty)
              .toList();

          if (fetchedIds.isNotEmpty) {
            setState(() {
              _existingGalleryImageIds = fetchedIds;
            });
            print(
              "Fetched ${fetchedIds.length} gallery image IDs from backend JSON: $fetchedIds",
            );
          } else {
            print("WARNING: galleryImageIds array is empty");
          }
        } else {
          print(
            "WARNING: galleryImageIds not found in JSON response or not a list",
          );
        }
      } else {
        print("Error fetching event: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching gallery image IDs: $e");
      
    }
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
      _categories = result.result;
    } catch (e) {
      print("Error loading categories: $e");
    } finally {
      setState(() {
        _categoriesLoading = false;
      });
    }
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

    
    _existingCoverImageId = widget.event['coverImageId'];
    print("Loaded existing cover image ID: $_existingCoverImageId");

    
    final galleryImages = widget.event['galleryImages'];
    print("Loading gallery images from event data: $galleryImages");
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
      print("Loaded ${_existingGalleryImageData.length} gallery images");
    } else {
      print("No gallery images found or invalid format");
    }

    
    final galleryImageIds = widget.event['galleryImageIds'];
    print("Loading gallery image IDs from event data: $galleryImageIds");
    if (galleryImageIds != null && galleryImageIds is List) {
      _existingGalleryImageIds = galleryImageIds
          .map((e) => e?.toString())
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .toList();
      print(
        "Loaded ${_existingGalleryImageIds.length} gallery image IDs: $_existingGalleryImageIds",
      );
    } else {
      print("No gallery image IDs found in event data");
      
      
      if (_existingGalleryImageData.isNotEmpty) {
        print(
          "WARNING: Gallery images exist but no IDs found. Will need to fetch event from backend.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return MasterScreenWidget(
      initialIndex: 4,
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Edit Event",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context); 
      },
      child: SingleChildScrollView(
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
                  : DropdownButtonFormField<String>(
                      value: _selectedCategory,
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
                          _selectedCategory = newValue;
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
                width: (screenWidth * 0.9 - 24) / 3,
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
    if (!mounted) return;

    try {
      
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      
      final bool isIOS = !kIsWeb && Platform.isIOS;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: isIOS
            ? 60
            : 70, 
        maxWidth: isIOS ? 1000 : 1200, 
        maxHeight: isIOS ? 1000 : 1200,
        requestFullMetadata:
            false, 
      );

      if (image != null && mounted) {
        setState(() {
          _mainImage = image;
        });
      }
    } catch (e) {
      print('Error picking main image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickAdditionalImage(int index) async {
    if (!mounted) return;

    try {
      
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      
      final bool isIOS = !kIsWeb && Platform.isIOS;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: isIOS
            ? 60
            : 70, 
        maxWidth: isIOS ? 1000 : 1200, 
        maxHeight: isIOS ? 1000 : 1200,
        requestFullMetadata:
            false, 
      );

      if (image != null && mounted) {
        setState(() {
          if (index < _additionalImages.length) {
            _additionalImages[index] = image;
          } else {
            _additionalImages.add(image);
          }
        });
      }
    } catch (e) {
      print('Error picking additional image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            duration: const Duration(seconds: 3),
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

      
      String dateStr = _dateController.text;
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          dateStr =
              '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
        }
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
          'ContentType': ImageHelpers.getContentType(_mainImage!.path),
          'ImageType': 'EventCover',
        };
        final mainImageResponse = await imageProvider.insert(mainImageRequest);
        coverImageId = mainImageResponse.id;
      } else {
        
        coverImageId = null;
      }

      
      
      int statusValue;
      final statusStr = (event['status'] ?? 'Upcoming').toString();
      switch (statusStr) {
        case 'Upcoming':
          statusValue = 0;
          break;
        case 'Past':
          statusValue = 1;
          break;
        case 'Cancelled':
          statusValue = 2;
          break;
        default:
          statusValue = 0; 
      }

      
      String formatTime(String timeStr) {
        
        String cleaned = timeStr.trim().toUpperCase();

        
        bool isPM = cleaned.contains('PM');
        bool isAM = cleaned.contains('AM');

        
        cleaned = cleaned.replaceAll(RegExp(r'\s*(AM|PM)\s*'), '');

        
        final parts = cleaned.split(':');
        if (parts.length < 2) {
          
          return timeStr.length >= 8 ? timeStr.substring(0, 8) : '$timeStr:00';
        }

        int hour = int.tryParse(parts[0]) ?? 0;
        int minute = int.tryParse(parts[1]) ?? 0;
        int second = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;

        
        if (isPM && hour != 12) {
          hour += 12;
        } else if (isAM && hour == 12) {
          hour = 0;
        }

        
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
      }

      final startTimeFormatted = formatTime(_startTimeController.text);
      final endTimeFormatted = formatTime(_endTimeController.text);

      
      final updateData = {
        'id': event['id'],
        'title': _nameController.text,
        'description': _descriptionController.text,
        'location': _venueController.text,
        'startDate': dateStr,
        'endDate': dateStr,
        'startTime': startTimeFormatted,
        'endTime': endTimeFormatted,
        'capacity': calculatedCapacity,
        'currentAttendees': event['currentAttendees'] ?? 0,
        'availableTicketsCount': calculatedCapacity,
        'status': statusValue,
        'isFeatured': event['isFeatured'] ?? false,
        'type': 1, 
        'isPublished': true,
        'isPaid': _isPaid, 
        'categoryId': _selectedCategory ?? event['categoryId'],
        'coverImageId': coverImageId,
      };

      await eventProvider.update(event['id'], updateData);

      
      
      if (_existingGalleryImageData.isNotEmpty &&
          _existingGalleryImageIds.isEmpty) {
        print(
          "Gallery image IDs missing, fetching from backend before processing...",
        );
        await _fetchGalleryImageIds();
      }

      
      final imageProvider = Provider.of<EventImageProvider>(
        context,
        listen: false,
      );
      List<String> finalGalleryImageIds = [];

      print(
        "Processing gallery images - New: ${_additionalImages.length}, Existing IDs: ${_existingGalleryImageIds.length}",
      );
      print("Existing gallery image IDs: $_existingGalleryImageIds");

      
      
      for (int i = 0; i < 3; i++) {
        if (i < _additionalImages.length) {
          
          final additionalImage = _additionalImages[i];
          final bytes = await File(additionalImage.path).readAsBytes();
          final base64Image = base64Encode(bytes);
          final imageRequest = {
            'Data': base64Image,
            'ContentType': ImageHelpers.getContentType(additionalImage.path),
            'ImageType': 'EventGallery',
            'EventId': event['id'],
          };
          final imageResponse = await imageProvider.insert(imageRequest);
          if (imageResponse.id != null && imageResponse.id!.isNotEmpty) {
            finalGalleryImageIds.add(imageResponse.id!);
            print("Added new image at slot $i with ID: ${imageResponse.id}");
          }
        } else if (i < _existingGalleryImageIds.length) {
          
          finalGalleryImageIds.add(_existingGalleryImageIds[i]);
          print(
            "Preserved existing image at slot $i with ID: ${_existingGalleryImageIds[i]}",
          );
        }
        
      }

      print(
        "Final gallery image IDs count: ${finalGalleryImageIds.length} (New: ${_additionalImages.length}, Preserved: ${finalGalleryImageIds.length - _additionalImages.length})",
      );
      print("Final gallery image IDs: $finalGalleryImageIds");

      
      
      await _replaceGalleryImages(event['id'], finalGalleryImageIds);

      
      await _handleTicketTypeChange(event['id'], dateStr);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      print('Error updating event: $e');
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
    } catch (e) {
      print("Error loading existing tickets: $e");
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
        
        await _createTicketsForPaidEvent(eventId, eventDate, ticketProvider);
      } else if (wasPaid && !isNowPaid) {
        
        await _validateAndDeleteTicketsForFreeEvent(eventId, ticketProvider);
      } else if (wasPaid && isNowPaid) {
        
        await _updateTicketsForPaidEvent(eventId, eventDate, ticketProvider);
      }
      
    } catch (e) {
      print("Error handling ticket type change: $e");
      rethrow; 
    }
  }

  Future<void> _validateAndDeleteTicketsForFreeEvent(
    String eventId,
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
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final url = "${eventProvider.baseUrl}Event/$eventId/gallery-images";
      final uri = Uri.parse(url);
      final headers = eventProvider.createHeaders();

      
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
      print('Error replacing gallery images: $e');
      rethrow;
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
