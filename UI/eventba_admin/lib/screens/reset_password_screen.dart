import 'package:eventba_admin/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _isLoading = false;
  String? _passwordErrorMessage;
  String? _confirmPasswordErrorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() async {
    if (!_isPasswordValid || !_isConfirmPasswordValid) {
      _showError('Please fix errors before submitting.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.resetPassword(
        widget.email,
        widget.code,
        _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Password reset successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showError('Failed to reset password. Please try again.');
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
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF343A40),
                    ),
                  ),
                  const SizedBox(height: 164),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'New Password',
                    hint: 'Enter new password',
                    isPassword: true,
                    obscureText: _obscurePassword,
                    isValid: _isPasswordValid,
                    errorMessage: _passwordErrorMessage,
                    width: size.width * 0.4,
                    onToggleVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    onChanged: (text) {
                      setState(() {
                        _isPasswordValid = RegExp(
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
                        ).hasMatch(text);
                        _passwordErrorMessage = _isPasswordValid
                            ? null
                            : 'Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, and a number.';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    hint: 'Re-enter new password',
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    isValid: _isConfirmPasswordValid,
                    errorMessage: _confirmPasswordErrorMessage,
                    width: size.width * 0.4,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    onChanged: (text) {
                      setState(() {
                        _isConfirmPasswordValid =
                            text.trim().isNotEmpty &&
                            RegExp(
                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
                            ).hasMatch(text);
                        _confirmPasswordErrorMessage = _isConfirmPasswordValid
                            ? null
                            : 'Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, and a number.';

                        // Also check if passwords match
                        if (_isConfirmPasswordValid &&
                            text != _passwordController.text) {
                          _isConfirmPasswordValid = false;
                          _confirmPasswordErrorMessage =
                              'Passwords do not match.';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: _isLoading ? "Resetting..." : "Reset Password",
                    onPressed: _isLoading ? () {} : _onSubmitPressed,
                    width: size.width * 0.4,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
