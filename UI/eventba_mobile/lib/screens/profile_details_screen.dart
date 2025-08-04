import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eventba_mobile/providers/user_provider.dart';
import 'package:eventba_mobile/models/user/user.dart';
import 'package:eventba_mobile/models/category/category_model.dart';
import 'package:eventba_mobile/providers/category_provider.dart';
import 'package:eventba_mobile/utils/image_helpers.dart';
import 'package:eventba_mobile/widgets/custom_text_field.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/widgets/category_selection_widget.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  User? _user;
  File? _profileImage;

  // Validation flags
  bool _isFirstNameValid = true;
  bool _isLastNameValid = true;
  bool _isEmailValid = true;
  bool _isPhoneValid = true;
  bool _isCurrentPasswordValid = false;
  bool _isNewPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  // Error messages
  String? _firstNameErrorMessage;
  String? _lastNameErrorMessage;
  String? _emailErrorMessage;
  String? _phoneErrorMessage;
  String? _currentPasswordErrorMessage;
  String? _newPasswordErrorMessage;
  String? _confirmPasswordErrorMessage;

  // Category-related state
  List<CategoryModel> _categories = [];
  List<String> _selectedCategoryIds = [];
  bool _isLoadingCategories = true;

  final double fieldWidth = double.infinity; // Responsive width

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadUserProfile();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).get();
      setState(() {
        _categories = categories.result;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await Provider.of<UserProvider>(
        context,
        listen: false,
      ).getProfile();
      _user = user;
      setState(() {
        firstNameController.text = user.firstName;
        lastNameController.text = user.lastName;
        emailController.text = user.email;
        phoneController.text = user.phoneNumber ?? '';
        _selectedCategoryIds = user.interests!
            .map((interest) => interest.id)
            .toList();
      });
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Edit Profile",
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
              const Text(
                "General Information",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: emailController,
                label: "Email",
                hint: "Enter your email",
                width: fieldWidth,
                keyboardType: TextInputType.emailAddress,
                isValid: _isEmailValid,
                errorMessage: _emailErrorMessage,
                onChanged: (text) {
                  setState(() {
                    _isEmailValid =
                        text.trim().isNotEmpty &&
                        RegExp(
                          r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(text);
                    _emailErrorMessage = _isEmailValid
                        ? null
                        : 'Enter a valid email';
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: firstNameController,
                label: "First Name",
                hint: "Enter first name",
                width: fieldWidth,
                isValid: _isFirstNameValid,
                errorMessage: _firstNameErrorMessage,
                onChanged: (text) {
                  setState(() {
                    _isFirstNameValid = text.trim().isNotEmpty;
                    _firstNameErrorMessage = _isFirstNameValid
                        ? null
                        : 'First name is required';
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: lastNameController,
                label: "Last Name",
                hint: "Enter last name",
                width: fieldWidth,
                isValid: _isLastNameValid,
                errorMessage: _lastNameErrorMessage,
                onChanged: (text) {
                  setState(() {
                    _isLastNameValid = text.trim().isNotEmpty;
                    _lastNameErrorMessage = _isLastNameValid
                        ? null
                        : 'Last name is required';
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: phoneController,
                label: "Phone Number",
                hint: "Enter phone number",
                width: fieldWidth,
                keyboardType: TextInputType.phone,
                isValid: _isPhoneValid,
                errorMessage: _phoneErrorMessage,
                onChanged: (text) {
                  setState(() {
                    _isPhoneValid =
                        text.trim().isNotEmpty &&
                        RegExp(
                          r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
                        ).hasMatch(text);
                    _phoneErrorMessage = _isPhoneValid
                        ? null
                        : 'Enter a valid phone number';
                  });
                },
              ),
              const SizedBox(height: 20),
              if (_isLoadingCategories)
                const Center(child: CircularProgressIndicator())
              else
                CategorySelectionWidget(
                  categories: _categories,
                  selectedCategoryIds: _selectedCategoryIds,
                  onCategoriesChanged: (selectedIds) {
                    setState(() {
                      _selectedCategoryIds = selectedIds;
                    });
                  },
                  subtitle: "Select categories you're interested in",
                ),
              const SizedBox(height: 20),
              PrimaryButton(text: "Save Changes", onPressed: _saveProfile),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                "Change Password",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: currentPasswordController,
                label: "Current Password",
                hint: "Enter current password",
                isPassword: true,
                obscureText: obscureCurrent,
                width: fieldWidth,
                isValid: _isCurrentPasswordValid,
                errorMessage: _currentPasswordErrorMessage,
                onToggleVisibility: () {
                  setState(() => obscureCurrent = !obscureCurrent);
                },
                onChanged: (text) {
                  setState(() {
                    _isCurrentPasswordValid = text.trim().isNotEmpty;
                    _currentPasswordErrorMessage = _isCurrentPasswordValid
                        ? null
                        : 'Current password is required';
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: newPasswordController,
                label: "New Password",
                hint: "Enter new password",
                isPassword: true,
                obscureText: obscureNew,
                width: fieldWidth,
                isValid: _isNewPasswordValid,
                errorMessage: _newPasswordErrorMessage,
                onToggleVisibility: () {
                  setState(() => obscureNew = !obscureNew);
                },
                onChanged: (text) {
                  setState(() {
                    _isNewPasswordValid = RegExp(
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
                    ).hasMatch(text);
                    _newPasswordErrorMessage = _isNewPasswordValid
                        ? null
                        : 'Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, and a number.';
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: confirmPasswordController,
                label: "Confirm New Password",
                hint: "Re-enter new password",
                isPassword: true,
                obscureText: obscureConfirm,
                width: fieldWidth,
                isValid: _isConfirmPasswordValid,
                errorMessage: _confirmPasswordErrorMessage,
                onToggleVisibility: () {
                  setState(() => obscureConfirm = !obscureConfirm);
                },
                onChanged: (text) {
                  setState(() {
                    _isConfirmPasswordValid =
                        text.trim().isNotEmpty &&
                        RegExp(
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
                        ).hasMatch(text);
                    _newPasswordErrorMessage = _isConfirmPasswordValid
                        ? null
                        : 'Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, and a number.';
                  });
                },
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: "Change Password",
                onPressed: _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() async {
    setState(() {
      _isFirstNameValid = firstNameController.text.trim().isNotEmpty;
      _firstNameErrorMessage = _isFirstNameValid
          ? null
          : 'First name is required';

      _isLastNameValid = lastNameController.text.trim().isNotEmpty;
      _lastNameErrorMessage = _isLastNameValid ? null : 'Last name is required';

      _isEmailValid =
          emailController.text.trim().isNotEmpty &&
          RegExp(
            r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,4}$',
          ).hasMatch(emailController.text);
      _emailErrorMessage = _isEmailValid ? null : 'Enter a valid email';

      _isPhoneValid =
          phoneController.text.trim().isNotEmpty &&
          RegExp(
            r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
          ).hasMatch(phoneController.text);
      _phoneErrorMessage = _isPhoneValid ? null : 'Enter a valid phone number';
    });

    if (_isFirstNameValid &&
        _isLastNameValid &&
        _isEmailValid &&
        _isPhoneValid) {
      try {
        final request = {
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'email': emailController.text.trim(),
          'phoneNumber': phoneController.text.trim(),
          'interestCategoryIds': _selectedCategoryIds,
        };

        await Provider.of<UserProvider>(context, listen: false)
            .update(_user!.id, request);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Profile saved successfully!'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Failed to save profile. Please try again.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Please fix errors before saving'),
        ),
      );
    }
  }

  void _changePassword() {
    setState(() {
      _isCurrentPasswordValid = currentPasswordController.text
          .trim()
          .isNotEmpty;
      _currentPasswordErrorMessage = _isCurrentPasswordValid
          ? null
          : 'Current password is required';

      _isNewPasswordValid =
          newPasswordController.text.trim().isNotEmpty &&
          newPasswordController.text.length >= 6;
      _newPasswordErrorMessage = _isNewPasswordValid
          ? null
          : 'Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, and a number.';

      _isConfirmPasswordValid =
          confirmPasswordController.text.trim().isNotEmpty &&
          confirmPasswordController.text == newPasswordController.text;
      _confirmPasswordErrorMessage = _isConfirmPasswordValid
          ? null
          : 'Passwords do not match';
    });

    if (_isCurrentPasswordValid &&
        _isNewPasswordValid &&
        _isConfirmPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Password changed successfully!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Please fix errors before changing password'),
        ),
      );
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
