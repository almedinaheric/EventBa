import 'package:eventba_mobile/screens/home_screen.dart';
import 'package:eventba_mobile/screens/login_screen.dart';
import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/text_link_button.dart';
import 'package:eventba_mobile/widgets/category_selection_widget.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/category_provider.dart';
import '../models/category/category_model.dart';
import '../utils/authorization.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isFullNameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  String? _fullNameErrorMessage;
  String? _emailErrorMessage;
  String? _passwordErrorMessage;

  List<CategoryModel> _categories = [];
  List<String> _selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).get(authorized: false, filter: {
        'page': 1,
        'pageSize': 1000,
      });
      categories.result.sort((a, b) => a.name.length.compareTo(b.name.length));
      setState(() {
        _categories = categories.result;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      _showError("Failed to load categories. Please try again.");
    }
  }

  void _onSignUpPressed() async {
    if (_fullNameController.text.isEmpty || !_isFullNameValid) {
      _showError("Please enter your full name (name and surname).");
      return;
    }
    if (_emailController.text.isEmpty || !_isEmailValid) {
      _showError("Please enter a valid email address.");
      return;
    }
    if (_passwordController.text.isEmpty || !_isPasswordValid) {
      _showError("Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, and a number.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final names = _fullNameController.text.trim().split(' ');
      final firstName = names.first;
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final requestBody = {
        "firstName": firstName,
        "lastName": lastName,
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
        "roleId": "5cf91d15-a804-4565-972f-be337f156455",
        "interestCategoryIds": _selectedCategoryIds,
      };

      await userProvider.insert(requestBody, authorized: false);

      if (!mounted) return;

      Authorization.email = _emailController.text.trim();
      Authorization.password = _passwordController.text;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MasterScreenWidget(
            initialIndex: 0,
            child: HomeScreen(),
          ),
        ),
      );
    } catch (e) {
      _showError("Registration failed. Please try again. ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(message)
        ));
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFDFE6FF),
      body: SafeArea(
        child: Column(
          children: [
            // Back button row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Centered Sign Up title
            const Center(
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF343A40),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      isValid: _isFullNameValid,
                      errorMessage: _fullNameErrorMessage,
                      width: size.width * 0.9,
                      onChanged: (text) {
                        setState(() {
                          _isFullNameValid = RegExp(
                            r'^[a-zA-Z]+ [a-zA-Z]+$',
                          ).hasMatch(text);
                          _fullNameErrorMessage = _isFullNameValid
                              ? null
                              : 'Please enter your full name.';
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      isValid: _isEmailValid,
                      errorMessage: _emailErrorMessage,
                      width: size.width * 0.9,
                      onChanged: (text) {
                        setState(() {
                          _isEmailValid = RegExp(
                            r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(text);
                          _emailErrorMessage = _isEmailValid
                              ? null
                              : 'Please enter a valid email address.';
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Create a password',
                      isPassword: true,
                      obscureText: !_isPasswordVisible,
                      isValid: _isPasswordValid,
                      errorMessage: _passwordErrorMessage,
                      width: size.width * 0.9,
                      onToggleVisibility: _togglePasswordVisibility,
                      onChanged: (text) {
                        setState(() {
                          _isPasswordValid = RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
                          ).hasMatch(text);
                          _passwordErrorMessage = _isPasswordValid
                              ? null
                              : 'Use at least 8 characters with uppercase, lowercase, and a number.';
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_isLoadingCategories)
                      const Center(child: CircularProgressIndicator())
                    else
                      SizedBox(
                        width: size.width * 0.9,
                        child: CategorySelectionWidget(
                          categories: _categories,
                          selectedCategoryIds: _selectedCategoryIds,
                          onCategoriesChanged: (selectedIds) {
                            setState(() {
                              _selectedCategoryIds = selectedIds;
                            });
                          },
                          subtitle: "Select categories you're interested in",
                        ),
                      ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      text: _isLoading ? "Signing Up..." : "Sign Up",
                      onPressed: _isLoading ? () {} : _onSignUpPressed,
                      width: size.width * 0.9,
                    ),
                    const SizedBox(height: 20),
                    TextLinkButton(
                      prefixText: "Already have an account? ",
                      linkText: "Log in.",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}