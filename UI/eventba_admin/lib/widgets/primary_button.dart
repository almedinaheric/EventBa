import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final bool outlined;
  final bool small;

  const PrimaryButton({
    required this.text,
    required this.onPressed,
    this.width,
    this.outlined = false,
    this.small = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonWidth = width ?? size.width * 0.9;

    const Color primaryColor = Color(0xFF4776E6);
    final Color textColor = outlined ? primaryColor : Colors.white;
    final Color backgroundColor = outlined ? Colors.transparent : primaryColor;
    const BorderSide borderSide = BorderSide(color: primaryColor, width: 1);
    final EdgeInsetsGeometry padding = small
        ? const EdgeInsets.symmetric(vertical: 4, horizontal: 8)
        : const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
    final double fontSize = small ? 12 : 16;
    final double borderRadius = small ? 4 : 8;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: buttonWidth,
          padding: padding,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.fromBorderSide(borderSide),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
