import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isPassword;
  final bool obscureText;
  final bool isValid;
  final String? errorMessage;
  final double width;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? suffixIcon;
  final VoidCallback? onToggleVisibility;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label = '',
    required this.hint,
    this.isPassword = false,
    this.obscureText = false,
    this.isValid = true,
    this.errorMessage,
    required this.width,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffixIcon,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
          ],
          TextField(
            controller: controller,
            obscureText: isPassword ? obscureText : false,
            onChanged: onChanged,
            readOnly: readOnly,
            enabled: enabled,
            onTap: onTap,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              errorText: isValid ? null : errorMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FBFF),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}
