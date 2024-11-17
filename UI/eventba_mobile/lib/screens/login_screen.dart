import 'package:eventba_mobile/screens/home_screen.dart';
import 'package:eventba_mobile/widgets/custom_navigation_bar.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color.fromARGB(255, 18, 14, 91),
                    ),
                    children: [
                      TextSpan(text: 'Event'),
                      TextSpan(
                        text: 'Ba',
                        style: TextStyle(
                          color: Color.fromARGB(255, 49, 101, 223),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16), // Add vertical space
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color.fromARGB(255, 18, 14, 91),
                    ),
                    children: [
                      TextSpan(
                          text: 'Explore Events ',
                          style: TextStyle(
                              color: Color.fromARGB(255, 18, 14, 91))),
                      TextSpan(
                          text: 'and \n',
                          style: TextStyle(
                              color: Color.fromARGB(255, 49, 101, 223))),
                      TextSpan(
                          text: 'Get Your Ticket \n',
                          style: TextStyle(
                              color: Color.fromARGB(255, 18, 14, 91))),
                      TextSpan(
                          text: 'Now!',
                          style: TextStyle(
                              color: Color.fromARGB(255, 49, 101, 223))),
                    ],
                  ),
                ),
              ],
            ),
            // Centered image
            Center(
              child: Image.asset("assets/images/login_screen_image.png"),
            ),
            // Button and account text
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return CustomNavigationBar();
                      },
                    ));
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(
                          255, 49, 101, 223), // Set the button color to blue
                    ),
                    foregroundColor: WidgetStateProperty.all<Color>(
                      Colors.white, // Set the text color to white
                    ),
                    minimumSize: WidgetStateProperty.all<Size>(
                      const Size(300, 48), // Set the button size
                    ),
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(
                          vertical: 16), // Optional: set vertical padding
                    ),
                  ),
                  child: const Text(
                    "Log In",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16), // Add vertical space
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: "Don’t have an account? "),
                      TextSpan(
                        text: "Create account.",
                        style: TextStyle(
                          color: Color.fromARGB(
                              255, 49, 101, 223), // Set color to blue
                          decoration:
                              TextDecoration.underline, // Underline the text
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
