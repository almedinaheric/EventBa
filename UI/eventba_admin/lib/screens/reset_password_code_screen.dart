import 'package:eventba_admin/screens/reset_password_screen.dart';
import 'package:eventba_admin/widgets/text_link_button.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ResetPasswordCodeScreen extends StatefulWidget {
  final String email;

  const ResetPasswordCodeScreen({super.key, required this.email});

  @override
  State<ResetPasswordCodeScreen> createState() =>
      _ResetPasswordCodeScreenState();
}

class _ResetPasswordCodeScreenState extends State<ResetPasswordCodeScreen> {
  final _codeController = TextEditingController();
  bool _isCodeValid = false;
  bool _isLoading = false;
  String? _codeErrorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() async {
    if (_codeController.text.isEmpty || !_isCodeValid) {
      _showError('Please enter a valid 6-digit code.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final isValid = await userProvider.validateResetCode(
        widget.email,
        _codeController.text.trim(),
      );

      if (!mounted) return;

      if (isValid) {
        // Navigate to reset password screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: widget.email,
              code: _codeController.text.trim(),
            ),
          ),
        );
      } else {
        _showError('Invalid or expired code. Please try again.');
      }
    } catch (e) {
      _showError('Failed to validate code. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                    'Enter Reset Code',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF343A40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We sent a 6-digit code to ${widget.email}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C757D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 164),
                  CustomTextField(
                    controller: _codeController,
                    label: 'Reset Code',
                    hint: 'Enter 6-digit code',
                    isValid: _isCodeValid,
                    errorMessage: _codeErrorMessage,
                    width: size.width * 0.4,
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      setState(() {
                        _isCodeValid =
                            text.length == 6 &&
                            RegExp(r'^\d{6}$').hasMatch(text);
                        _codeErrorMessage = _isCodeValid
                            ? null
                            : 'Please enter a valid 6-digit code.';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: _isLoading ? "Validating..." : "Continue",
                    onPressed: _isLoading ? () {} : _onSubmitPressed,
                    width: size.width * 0.4,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: TextLinkButton(
                    linkText: "Back to login.",
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
