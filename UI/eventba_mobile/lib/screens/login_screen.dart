import 'package:eventba_mobile/providers/user_provider.dart';
import 'package:eventba_mobile/screens/forgot_password_screen.dart';
import 'package:eventba_mobile/screens/home_screen.dart';
import 'package:eventba_mobile/screens/signup_screen.dart';
import 'package:eventba_mobile/utils/authorization.dart';
import 'package:eventba_mobile/widgets/text_link_button.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'package:provider/provider.dart';

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
      _isLoading = false;
    });

    Authorization.email = email;
    Authorization.password = password;

    try {
      //await Provider.of<UserProvider>(context, listen: false).getProfile();
      //Provider.of<UserProvider>(context, listen: false).getProfile();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      print(e);
      _showError("Login failed. Please check your credentials.");
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
          'Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, and a number.');
      return;
    }

    _login(context);
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
                    'Log In',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF343A40)),
                  ),
                  const SizedBox(height: 132),
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
                            RegExp(r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,4}$')
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
                    hint: 'Enter your password',
                    isPassword: true,
                    obscureText: !_isPasswordVisible,
                    isValid: _isPasswordValid,
                    errorMessage: _passwordErrorMessage,
                    width: size.width * 0.9,
                    onToggleVisibility: _togglePasswordVisibility,
                    onChanged: (text) {
                      setState(() {
                        _isPasswordValid =
                            //RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$')
                            RegExp(r'/*').hasMatch(text);
                        _passwordErrorMessage = _isPasswordValid
                            ? null
                            : 'Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, and a number.';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextLinkButton(
                      linkText: "Forgot Password?",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : PrimaryButton(
                          text: "Log In",
                          onPressed: _onLoginPressed,
                          width: size.width * 0.9,
                        ),
                ],
              ),
              TextLinkButton(
                prefixText: "Don’t have an account? ",
                linkText: "Create account.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
