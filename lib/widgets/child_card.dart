import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vocal_odyssey/widgets/avatar_progress.dart';

class ChildCard extends StatelessWidget {
  final String name;
  final String gender;
  final String dob;
  final String imagePath;
  final VoidCallback onClick;
  final VoidCallback onDeleteClick;

  const ChildCard({
    super.key,
    required this.name,
    required this.gender,
    required this.dob,
    required this.imagePath,
    required this.onClick,
    required this.onDeleteClick,
  });

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;

    return GestureDetector(
      onTap: onClick,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isLightMode)
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16).copyWith(bottom: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AvatarProgress(
                    progress: 1,
                    imagePath: imagePath,
                    color: isLightMode ? Colors.grey[300] : Colors.grey[800],
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text("$gender - Born $dob"),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: onDeleteClick,
                icon: SvgPicture.asset(
                  'assets/icons/delete.svg',
                  colorFilter: ColorFilter.mode(
                    isLightMode ? Colors.red : Colors.redAccent,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
