import 'package:eventba_admin/screens/login_screen.dart';
import 'package:eventba_admin/widgets/text_link_button.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

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

  String? _fullNameErrorMessage;
  String? _emailErrorMessage;
  String? _passwordErrorMessage;

  void _onSignUpPressed() {
    if (_fullNameController.text.isEmpty || !_isFullNameValid) {
      _showError("Please enter your full name (name and surname).");
      return;
    }
    if (_emailController.text.isEmpty || !_isEmailValid) {
      _showError("Please enter a valid email address.");
      return;
    }
    if (_passwordController.text.isEmpty || !_isPasswordValid) {
      _showError(
          "Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, and a number.");
      return;
    }

    // Proceed with registration logic
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFDFE6FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF343A40)),
                  ),
                  const SizedBox(height: 124),
                  CustomTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    isValid: _isFullNameValid,
                    errorMessage: _fullNameErrorMessage,
                    width: size.width * 0.7,
                    onChanged: (text) {
                      setState(() {
                        _isFullNameValid =
                            RegExp(r'^[a-zA-Z]+ [a-zA-Z]+$').hasMatch(text);
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
                    width: size.width * 0.7,
                    onChanged: (text) {
                      setState(() {
                        _isEmailValid =
                            RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(text);
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
                    width: size.width * 0.7,
                    onToggleVisibility: _togglePasswordVisibility,
                    onChanged: (text) {
                      setState(() {
                        _isPasswordValid =
                            RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$')
                                .hasMatch(text);
                        _passwordErrorMessage = _isPasswordValid
                            ? null
                            : 'Use at least 8 characters with uppercase, lowercase, and a number.';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: "Sign Up",
                    onPressed: _onSignUpPressed,
                    width: size.width * 0.7,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextLinkButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
