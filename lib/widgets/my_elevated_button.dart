import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double verticalPadding;
  final Color? color;
  final Color? textColor;
  final Widget? prefix;

  const MyElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.verticalPadding = 20.0,
    this.color,
    this.textColor,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: color,
          padding:
              EdgeInsets.symmetric(horizontal: 16, vertical: verticalPadding),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            if (prefix != null) prefix!,
            Text(
              text,
              style: TextStyle(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
