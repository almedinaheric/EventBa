import 'package:flutter/material.dart';
import 'package:eventba_admin/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFE6FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/app_icon.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 48),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 32,
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
            const SizedBox(height: 8),
            const Text(
              'Discover Events, Secure Your Tickets!',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF120E5B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
