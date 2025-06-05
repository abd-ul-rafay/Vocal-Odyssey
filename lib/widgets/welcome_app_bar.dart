import 'package:flutter/material.dart';

class WelcomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final double topPadding;
  final double bottomPadding;
  final Widget actionWidget;
  final double titleWidth;

  const WelcomeAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.topPadding,
    required this.bottomPadding,
    required this.actionWidget,
    this.titleWidth = -1
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(150),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(
          top: topPadding, bottom: bottomPadding,),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: titleWidth == -1 ? null : MediaQuery.of(context).size.width * titleWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            actionWidget,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(150);
}
