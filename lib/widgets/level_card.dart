import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

class LevelCard extends StatefulWidget {
  final String levelName;
  final String levelDescription;
  final IconData icon;
  final MaterialColor color;
  final VoidCallback onPressed;
  final String animationPath;
  final bool isLocked;
  final int stars;

  const LevelCard({
    super.key,
    required this.levelName,
    required this.levelDescription,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.animationPath,
    this.isLocked = false,
    this.stars = 0,
  });

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLocked ? null : widget.onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.color),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20).copyWith(top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: widget.color),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SvgPicture.asset(
                          widget.isLocked
                              ? 'assets/icons/lock.svg'
                              : 'assets/icons/play.svg',
                          colorFilter:
                              ColorFilter.mode(widget.color, BlendMode.srcIn),
                          width: 16,
                        ),
                      ),
                      if (!widget.isLocked)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: 3,
                          children: List.generate(3, (index) {
                            return SvgPicture.asset(
                              'assets/icons/${index < widget.stars ? 'star' : 'star_outlined'}.svg',
                              colorFilter: ColorFilter.mode(
                                  widget.color, BlendMode.srcIn),
                              width: 20,
                            );
                          }),
                        ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.levelName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    widget.levelDescription,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
            // This container will prevent any white spaces at the corner
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -35,
              right: -35,
              child: Lottie.asset(
                widget.animationPath,
                width: 140,
                height: 140,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
