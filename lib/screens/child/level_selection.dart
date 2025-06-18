import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/providers/level_provider.dart';
import 'package:vocal_odyssey/screens/child/playground.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import 'package:vocal_odyssey/widgets/level_card.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  List<bool> _visibleList = [];
  late ContentType contentType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_visibleList.isNotEmpty) return; // Prevents reinitializing on rebuilds

    contentType = ModalRoute.of(context)!.settings.arguments as ContentType;
    final levelProvider = Provider.of<LevelProvider>(context);
    _visibleList = List.generate(levelProvider.getLevelsByType(contentType).length, (_) => false);

    _animateLevels();
  }

  void _animateLevels() {
    Future.delayed(const Duration(milliseconds: 100), () {
      for (int i = 0; i < _visibleList.length; i++) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          if (mounted) {
            setState(() {
              _visibleList[i] = true;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final levelProvider = Provider.of<LevelProvider>(context);
    final levelsWithProgress = levelProvider.getLevelsByType(contentType);
    final color = getColor(contentType);

    requestMicrophonePermission();

    return MyScaffoldLayout(
      appBar: MyAppBar(
        title: _getTitle(contentType),
        color: color,
      ),
      children: [
        Text(
          _getDescription(contentType),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        ...levelsWithProgress.asMap().entries.map((entry) {
          final index = entry.key;
          final level = entry.value.level;
          final attempts = entry.value.attempts;

          final isFirstLevel = index == 0;
          final hasAttempts = attempts.isNotEmpty;

          final wasPreviousAttempted = index > 0 && levelsWithProgress[index - 1].attempts.isNotEmpty;
          final isLocked = !(isFirstLevel || hasAttempts || wasPreviousAttempted);

          final stars = attempts.isNotEmpty
              ? attempts.map((a) => a.stars.round()).fold<int>(0, (prev, curr) => curr > prev ? curr : prev)
              : 0;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _visibleList[index] ? 1.0 : 0.0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 500),
              offset: _visibleList[index] ? Offset(0, 0) : Offset(-1, 0),
              curve: Curves.easeOut,
              child: LevelCard(
                levelName: level.name,
                levelDescription: level.description,
                color: color,
                icon: Icons.subdirectory_arrow_right,
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/playground',
                  arguments: PlaygroundScreenArguments(level: level),
                ),
                animationPath: _getCardAnimationPath(contentType),
                isLocked: isLocked,
                stars: stars,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  String _getTitle(ContentType contentType) {
    switch (contentType) {
      case ContentType.phonics:
        return 'Phonics Practice';
      case ContentType.words:
        return 'Words Practice';
      case ContentType.sentences:
        return 'Sentences Practice';
    }
  }

  String _getDescription(ContentType contentType) {
    switch (contentType) {
      case ContentType.phonics:
        return 'Let\'s start with the sounds and letters!';
      case ContentType.words:
        return 'Time to practice some words!';
      case ContentType.sentences:
        return 'Now, let\'s put those words together!';
    }
  }

  String _getCardAnimationPath(ContentType contentType) {
    switch (contentType) {
      case ContentType.phonics:
        return 'assets/animations/blue_ball.json';
      case ContentType.words:
        return 'assets/animations/green_ball.json';
      case ContentType.sentences:
        return 'assets/animations/orange_ball.json';
    }
  }
}
