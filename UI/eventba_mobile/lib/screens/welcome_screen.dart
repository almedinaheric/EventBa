import 'package:eventba_mobile/screens/signup_screen.dart';
import 'package:eventba_mobile/widgets/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:eventba_mobile/screens/login_screen.dart';
import '../widgets/primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFE6FF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF120E5B),
                      ),
                      children: [
                        TextSpan(text: 'Event'),
                        TextSpan(
                          text: 'Ba',
                          style: TextStyle(color: Color(0xFF4776E6)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4776E6),
                      ),
                      children: [
                        TextSpan(text: 'Explore Events '),
                        TextSpan(
                          text: 'and \n',
                          style: TextStyle(color: Color(0xFF120E5B)),
                        ),
                        TextSpan(text: 'Get Your Ticket \n'),
                        TextSpan(
                          text: 'Now!',
                          style: TextStyle(color: Color(0xFF120E5B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Image.asset(
                "assets/images/welcome_screen_image.png",
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
              ),
              Column(
                children: [
                  PrimaryButton(
                    text: "Log In",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextLinkButton(
                    prefixText: "Don’t have an account? ",
                    linkText: "Create account.",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
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
