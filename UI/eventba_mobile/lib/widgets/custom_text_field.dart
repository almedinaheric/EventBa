import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isPassword;
  final bool isValid;
  final String? errorMessage;
  final VoidCallback? onToggleVisibility;
  final double? width;
  final Function(String)? onChanged;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.isPassword = false,
    this.isValid = true,
    this.errorMessage,
    this.onToggleVisibility,
    this.width,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textFieldWidth = width ?? MediaQuery.of(context).size.width * 0.9;

    return SizedBox(
      width: textFieldWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: label,
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isValid ? Colors.green : Colors.red,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isValid ? Colors.green : Colors.red,
                  width: 2.0,
                ),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
            ),
            keyboardType: isPassword
                ? TextInputType.visiblePassword
                : TextInputType.emailAddress,
          ),
          if (!isValid && errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
