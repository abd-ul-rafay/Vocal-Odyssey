import 'package:flutter/material.dart';

class MyScaffoldLayout extends StatelessWidget {
  final List<Widget> children;
  final PreferredSizeWidget? appBar;
  final double topPadding;
  final double bottomPadding;
  final CrossAxisAlignment axisAlignment;

  const MyScaffoldLayout({
    super.key,
    required this.children,
    this.appBar,
    this.topPadding = 20.0,
    this.bottomPadding = 20.0,
    this.axisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            bool isScreenWide = maxWidth > 500;
            double contentWidth = isScreenWide ? maxWidth * 0.55 : maxWidth;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0).copyWith(
                  // if there is an appBar, given padding (body's) is used
                  top: isScreenWide && appBar == null ? 20 : topPadding,
                  bottom: isScreenWide ? 20 : bottomPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: contentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: axisAlignment,
                      children: children,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
