import 'package:flutter/material.dart';

import 'my_avatar.dart';

class AvatarProgress extends StatelessWidget {
  final double progress;
  final String imagePath;
  final Color? color;

  const AvatarProgress({
    super.key,
    required this.progress,
    required this.imagePath,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: isLightMode ? Colors.grey[300] : Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
              color != null
                  ? color!
                  : isLightMode
                  ? Colors.blue.shade400
                  : Colors.blue.shade600,
            ),
          ),
        ),
        MyAvatar(radius: 25, imagePath: imagePath),
      ],
    );
  }
}
