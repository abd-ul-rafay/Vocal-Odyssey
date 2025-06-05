import 'package:flutter/material.dart';

class IconButtonBox extends StatelessWidget {
  final Icon icon;
  final VoidCallback onClick;

  const IconButtonBox({
    super.key,
    required this.icon,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: 50, // Adjust size as needed
        height: 50, // Adjust size as needed
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12), // Add curve to the box
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: icon,
        ),
      ),
    );
  }
}
