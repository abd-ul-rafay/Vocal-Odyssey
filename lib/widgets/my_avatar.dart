import 'package:flutter/material.dart';
import 'package:vocal_odyssey/utils/consts.dart';

class MyAvatar extends StatelessWidget {
  final double radius;
  final String imagePath;

  const MyAvatar({
    super.key,
    required this.radius,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage(imagePath.isEmpty ? defaultImagePath : imagePath),
      backgroundColor: Colors.transparent,
    );
  }
}
