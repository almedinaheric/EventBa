import 'package:eventba_mobile/screens/login_screen.dart';
import 'package:eventba_mobile/widgets/text_link_button.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isEmailValid = false;
  String? _emailErrorMessage;

  void _onSubmitPressed() {
    if (_emailController.text.isEmpty || !_isEmailValid) {
      _showError('Please enter a valid email.');
      return;
    }

    // Proceed with your password reset logic
    // For now, we're just showing a message after form validation
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password reset link has been sent to your email')));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
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
                    'Forgot Password',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF343A40)),
                  ),
                  const SizedBox(height: 164),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    isValid: _isEmailValid,
                    errorMessage: _emailErrorMessage,
                    width: size.width * 0.9,
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
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: "Send Reset Link",
                    onPressed: _onSubmitPressed,
                    width: size.width * 0.9,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: TextLinkButton(
                  linkText: "Back to login.",
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
