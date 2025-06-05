import 'package:flutter/material.dart';
import 'package:vocal_odyssey/utils/consts.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        icon: Image.asset(
          'assets/images/google.png',
          height: 24,
          width: 24,
        ),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            'Continue with Google',
            style: TextStyle(
              color: !isLightMode ? lightGrey : null,
            ),
          ),
        ),
      ),
    );
  }
}
