import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/models/level_with_progress.dart';
import 'package:vocal_odyssey/providers/user_provider.dart';
import 'package:vocal_odyssey/services/level_service.dart';
import 'package:vocal_odyssey/providers/child_provider.dart';
import 'package:vocal_odyssey/providers/level_provider.dart';
import 'package:vocal_odyssey/utils/enums.dart';
import 'package:vocal_odyssey/widgets/avatar_progress.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import 'package:vocal_odyssey/widgets/practice_card.dart';
import '../../utils/functions.dart';
import '../../widgets/welcome_app_bar.dart';

class LevelStats {
  final int totalAchievedStars;
  final int totalStars;
  final int percentageWithAttempts;

  LevelStats({
    required this.totalAchievedStars,
    required this.totalStars,
    required this.percentageWithAttempts,
  });
}

class ChildDashboardScreen extends StatefulWidget {
  const ChildDashboardScreen({super.key});

  @override
  State<ChildDashboardScreen> createState() => _ChildDashboardScreenState();
}

class _ChildDashboardScreenState extends State<ChildDashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final childProvider = Provider.of<ChildProvider>(context, listen: false);
    final levelProvider = Provider.of<LevelProvider>(context, listen: false);

    try {
      final levels = await LevelService.getLevelsWithProgress(
        userProvider.token!,
        childProvider.getSelectedChild()!.id,
      );

      levelProvider.setLevels(levels);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load levels.");
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = Provider.of<ChildProvider>(context);
    final levelProvider = Provider.of<LevelProvider>(context);

    final child = childProvider.getSelectedChild();
    final levels = levelProvider.levelsWithProgress;

    final stats = getLevelStats(levels);

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          final shouldExit = await showConfirmationDialog(
            context: context,
            title: 'Exit App',
            message:
                'Do you really want to exit the app? Use Settings to return to the home screen.',
            cancelText: 'No',
            confirmText: 'Exit',
          );
          if (shouldExit == true) {
            SystemNavigator.pop();
          }
        }
      },
      child: MyScaffoldLayout(
        topPadding: 0,
        appBar: WelcomeAppBar(
          title: 'Hi, ${child!.name}',
          subtitle: 'Welcome to Vocal Odyssey',
          topPadding: 20,
          bottomPadding: 10,
          actionWidget: Transform.rotate(
            angle: -pi / 2,
            child: Transform.scale(
              scaleX: -1,
              child: Lottie.asset('assets/animations/cartoon.json', width: 90),
            ),
          ),
        ),
        children: _isLoading
            ? [
                SizedBox(height: 200),
                buildLoadingIndicator("Loading your details"),
              ]
            : [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 20,
                      children: [
                        AvatarProgress(
                          progress: stats.percentageWithAttempts / 100,
                          imagePath: child.imagePath,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress: ${stats.percentageWithAttempts}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  "${stats.totalAchievedStars} / ${stats.totalStars}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onVerticalDragEnd: (_) =>
                          Navigator.pushNamed(context, '/child_settings'),
                      onTap: () => Fluttertoast.showToast(
                        msg:
                            "Drag the button down to open settings — this helps prevent accidental taps by kids.",
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/manage.svg',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color ?? Colors.grey,
                          BlendMode.srcIn,
                        ),
                        width: 26,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                Text(
                  'Ready to practice your pronunciation?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10),
                Column(
                  children: List.generate(3, (i) {
                    final contentType = _getCardContentType(i);
                    final specificStats = getLevelStats(
                      levels
                          .where((level) => level.level.type == contentType)
                          .toList(),
                    );

                    return PracticeCard(
                      text: _getCardText(i),
                      description: _getCardDescription(i),
                      starRatio:
                          '${specificStats.totalAchievedStars} / ${specificStats.totalStars}',
                      progress: specificStats.percentageWithAttempts / 100,
                      icon: _getCardIcon(i),
                      startColor: _getCardColor(i, true),
                      endColor: _getCardColor(i, false),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/level_selection',
                        arguments: contentType,
                      ),
                    );
                  }),
                ),
              ],
      ),
    );
  }

  LevelStats getLevelStats(List<LevelWithProgress> levels) {
    final totalAchievedStars = levels
        .map((level) {
          if (level.attempts.isEmpty) return 0;
          return level.attempts
              .map((a) => a.stars.round())
              .reduce((a, b) => a > b ? a : b);
        })
        .fold(0, (sum, stars) => sum + stars);

    final totalStars = levels.length * 3;

    final levelsWithAttempts = levels
        .where((level) => level.attempts.isNotEmpty)
        .length;

    final percentageWithAttempts = levels.isEmpty
        ? 0
        : ((levelsWithAttempts / levels.length) * 100).round();

    return LevelStats(
      totalAchievedStars: totalAchievedStars,
      totalStars: totalStars,
      percentageWithAttempts: percentageWithAttempts,
    );
  }

  String _getCardText(int index) {
    switch (index) {
      case 0:
        return 'Phonics Practice';
      case 1:
        return 'Words Practice';
      case 2:
        return 'Sentences Practice';
      default:
        return '';
    }
  }

  String _getCardDescription(int index) {
    switch (index) {
      case 0:
        return 'Improve your pronunciation with phonics.';
      case 1:
        return 'Build vocabulary with new words.';
      case 2:
        return 'Enhance sentence structure and fluency.';
      default:
        return '';
    }
  }

  IconData _getCardIcon(int index) {
    switch (index) {
      case 0:
        return Icons.volume_up;
      case 1:
        return Icons.text_fields;
      case 2:
        return Icons.chat_bubble;
      default:
        return Icons.star;
    }
  }

  Color _getCardColor(int index, bool isStartColor) {
    switch (index) {
      case 0:
        return isStartColor ? Colors.blue : Colors.blueAccent;
      case 1:
        return isStartColor ? Colors.green : Colors.greenAccent;
      case 2:
        return isStartColor ? Colors.orange : Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  ContentType _getCardContentType(int index) {
    switch (index) {
      case 0:
        return ContentType.phonics;
      case 1:
        return ContentType.words;
      default:
        return ContentType.sentences;
    }
  }
}
