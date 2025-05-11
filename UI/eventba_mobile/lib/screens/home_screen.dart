import 'package:eventba_mobile/screens/signup_screen.dart';
import 'package:eventba_mobile/widgets/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:eventba_mobile/screens/login_screen.dart';
import '../widgets/primary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                          style: TextStyle(color: Color(0xFF3165DF)),
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
                        color: Color(0xFF120E5B),
                      ),
                      children: [
                        TextSpan(text: 'Explore Events '),
                        TextSpan(
                          text: 'and \n',
                          style: TextStyle(color: Color(0xFF3165DF)),
                        ),
                        TextSpan(text: 'Get Your Ticket \n'),
                        TextSpan(
                          text: 'Now!',
                          style: TextStyle(color: Color(0xFF3165DF)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Image.asset(
                "assets/images/Home_screen_image.png",
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
                          builder: (context) => LoginScreen(),
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
                          builder: (context) => SignUpScreen(),
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
