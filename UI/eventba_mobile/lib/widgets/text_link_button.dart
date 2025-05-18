import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TextLinkButton extends StatelessWidget {
  final String? prefixText;
  final String linkText;
  final VoidCallback onTap;

  const TextLinkButton({
    super.key,
    this.prefixText,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        children: [
          if (prefixText != null)
            TextSpan(
              text: prefixText,
            ),
          TextSpan(
            text: linkText,
            style: const TextStyle(
              color: Color(0xFF4776E6),
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }
}
