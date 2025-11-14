import 'package:eventba_admin/providers/user_provider.dart';
import 'package:eventba_admin/screens/forgot_password_screen.dart';
import 'package:eventba_admin/screens/home_screen.dart';
import 'package:eventba_admin/utils/authorization.dart';
import 'package:eventba_admin/widgets/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  String? _emailErrorMessage;
  String? _passwordErrorMessage;

  Future<void> _login(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    Authorization.email = email;
    Authorization.password = password;

    try {
      await Provider.of<UserProvider>(context, listen: false).getProfile();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      // Clear credentials on failed login
      Authorization.email = null;
      Authorization.password = null;

      // Show appropriate error message
      String errorMessage = "Login failed. Please check your credentials.";
      if (e.toString().contains("Unauthorized") ||
          e.toString().contains("403")) {
        errorMessage =
            "Access denied. Only administrators can access this app.";
      }

      _showError(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onLoginPressed() {
    if (_emailController.text.isEmpty || !_isEmailValid) {
      _showError('Please enter a valid email.');
      return;
    }
    if (_passwordController.text.isEmpty || !_isPasswordValid) {
      _showError(
        'Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, and a number.',
      );
      return;
    }

    _login(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
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
            mainAxisAlignment: MainAxisAlignment.center, // vertical centering
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF343A40),
                    ),
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    isValid: _isEmailValid,
                    errorMessage: _emailErrorMessage,
                    width: size.width * 0.4,
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
                    hint: 'Enter your password',
                    isPassword: true,
                    obscureText: !_isPasswordVisible,
                    isValid: _isPasswordValid,
                    errorMessage: _passwordErrorMessage,
                    width: size.width * 0.4,
                    onToggleVisibility: _togglePasswordVisibility,
                    onChanged: (text) {
                      setState(() {
                        _isPasswordValid =
                            text.trim().isNotEmpty &&
                            //RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$')
                            RegExp(r'/*').hasMatch(text);
                        _passwordErrorMessage = _isPasswordValid
                            ? null
                            : 'Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, and a number.';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Spacer(), // This will push the TextLinkButton to the right
                      Padding(
                        padding: EdgeInsets.only(
                          right: size.width * 0.29,
                        ), // Adjust the right padding as needed
                        child: TextLinkButton(
                          linkText: "Forgot Password?",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : PrimaryButton(
                          text: "Log In",
                          onPressed: _onLoginPressed,
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
