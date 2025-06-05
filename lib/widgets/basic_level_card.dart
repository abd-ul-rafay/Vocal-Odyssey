import 'package:flutter/material.dart';

class BasicLevelCard extends StatelessWidget {
  final String levelName;
  final String levelDescription;
  final String levelType;
  final VoidCallback onPressed;
  final VoidCallback? onDeletePressed;
  final bool isAdmin;

  const BasicLevelCard({
    super.key,
    required this.levelName,
    required this.levelDescription,
    required this.levelType,
    required this.onPressed,
    this.onDeletePressed,
    this.isAdmin = true,
  });

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  levelName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    levelDescription,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  levelType,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
            Visibility(
              visible: isAdmin,
              child: IconButton(
                onPressed: onDeletePressed,
                icon: Icon(Icons.delete, size: 20,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
