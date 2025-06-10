import 'package:flutter/material.dart';
import 'dart:io';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/widgets/primary_button.dart';
import 'package:eventba_admin/widgets/custom_text_field.dart';
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

  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _nameController = TextEditingController(text: event['name']);
    _selectedCategory = event['category'];
    _venueController = TextEditingController(text: event['venue']);
    _dateController = TextEditingController(text: event['date']);
    _startTimeController = TextEditingController(text: event['startTime']);
    _endTimeController = TextEditingController(text: event['endTime']);
    _descriptionController = TextEditingController(text: event['description']);
    _capacityController = TextEditingController(text: event['capacity'].toString());
    _vipPriceController = TextEditingController(text: event['vipPrice']?.toString() ?? '');
    _vipCountController = TextEditingController(text: event['vipCount']?.toString() ?? '');
    _ecoPriceController = TextEditingController(text: event['ecoPrice']?.toString() ?? '');
    _ecoCountController = TextEditingController(text: event['ecoCount']?.toString() ?? '');
    _isPaid = event['isPaid'] ?? false;
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
          Navigator.pop(context); // Back button functionality
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
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Event category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: ['Music', 'Sports', 'Art', 'Technology', 'Food']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
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
              const Text("Pricing and Tickets", style: TextStyle(fontWeight: FontWeight.bold)),
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
                const Text("VIP tickets", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _vipPriceController,
                        hint: 'VIP price',
                        width: double.infinity,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                const Text("ECONOMY tickets", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _ecoPriceController,
                        hint: 'Economy price',
                        width: double.infinity,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                child: PrimaryButton(
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
        )
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle the update event logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully!')),
      );
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
