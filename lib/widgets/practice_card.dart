import 'package:flutter/material.dart';

class PracticeCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final String starRatio;
  final Color startColor;
  final Color endColor;
  final VoidCallback onPressed;
  final double progress;
  final String description;

  const PracticeCard({
    super.key,
    required this.text,
    required this.icon,
    required this.starRatio,
    required this.startColor,
    required this.endColor,
    required this.onPressed,
    required this.progress,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding:
            EdgeInsets.symmetric(horizontal: 16).copyWith(top: 22, bottom: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor.withValues(alpha: 0.8), endColor.withValues(alpha: 0.8)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 5,
              spreadRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 30, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(starRatio, style: TextStyle(color: Colors.white),),
                    SizedBox(width: 2,),
                    Icon(Icons.star_border, color: Colors.white,)
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: -0.5, end: progress),
                duration: Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
