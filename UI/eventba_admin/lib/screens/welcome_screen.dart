import 'package:eventba_admin/screens/signup_screen.dart';
import 'package:eventba_admin/widgets/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:eventba_admin/screens/login_screen.dart';
import '../widgets/primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;
    final isMobile = screenWidth <= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFDFE6FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: isDesktop ? _buildDesktopLayout(context, screenWidth) : _buildMobileLayout(context, screenWidth, isTablet),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, double screenWidth) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                _buildBrandText(isDesktop: true),
                const SizedBox(height: 40),
                _buildWelcomeText(isDesktop: true),
                const SizedBox(height: 40),
              ],
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
              child: Image.asset(
                "assets/images/welcome_screen_image.png",
                width: screenWidth * 0.25,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40),
            _buildButtons(isDesktop: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, double screenWidth, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 60 : 20,
        vertical: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              _buildBrandText(isDesktop: false),
              SizedBox(height: isTablet ? 40 : 32),
              _buildWelcomeText(isDesktop: false),
            ],
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 400 : screenWidth * 0.7,
              maxHeight: isTablet ? 400 : 300,
            ),
            child: Image.asset(
              "assets/images/welcome_screen_image.png",
              width: isTablet ? 400 : screenWidth * 0.7,
              fit: BoxFit.contain,
            ),
          ),
          _buildButtons(isDesktop: false),
        ],
      ),
    );
  }

  Widget _buildBrandText({required bool isDesktop}) {
    return RichText(
      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: isDesktop ? 32 : 24,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF120E5B),
        ),
        children: const [
          TextSpan(text: 'Event'),
          TextSpan(
            text: 'Ba',
            style: TextStyle(color: Color(0xFF4776E6)),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText({required bool isDesktop}) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: isDesktop ? 36 : 28,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF4776E6),
          height: 1.2,
        ),
        children: const [
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
    );
  }

  Widget _buildButtons({required bool isDesktop}) {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: isDesktop ? 400 : double.infinity,
            maxWidth: isDesktop ? 500 : double.infinity,
          ),
          child: PrimaryButton(
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
        ),
        const SizedBox(height: 16),
        TextLinkButton(
          prefixText: "Don't have an account? ",
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
    );
  }
}