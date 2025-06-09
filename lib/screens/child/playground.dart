import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import '../../models/level.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  PlaygroundScreenState createState() => PlaygroundScreenState();
}

class PlaygroundScreenState extends State<PlaygroundScreen> {
  late Level _level;

  final FlutterTts _flutterTts = FlutterTts();

  int _currentIndex = 0;

  late Timer _timer;
  Duration _elapsedTime = Duration.zero;
  String _formattedTime = "00:00";
  final ValueNotifier<String> _timeNotifier = ValueNotifier<String>("00:00");

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as PlaygroundScreenArguments;
      _level = args.level;

      _setupTts();
      _showStartDialog();
    });
  }

  Future<void> _setupTts() async {
    await _flutterTts.setVoice({"name": "en-gb-x-gba-local", "locale": "en-GB"});
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setPitch(1.3);
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.speak("Hi there");
  }

  void _startLevel() {
    _startTimer();
    _speakCurrentContent("Let's start with");
  }

  Future<void> _speakCurrentContent(String initials) async {
    if (_currentIndex < _level.content.length) {
      final text = initials + "\n" + _level.content[_currentIndex];
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    }
  }

  void _moveToNextContent() {
    if (_currentIndex < _level.content.length - 1) {
      setState(() {
        _currentIndex++;
      });

      _speakCurrentContent("Good job, now try speaking");
    }
  }

  void _repeatContent() {
    _speakCurrentContent("I'll repeat");
  }

  void _showStartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final color = Theme.of(context).iconTheme.color;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Lottie.asset(
                'assets/animations/robot.json',
                width: 50,
                height: 50,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Hi there! 👋",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Are you ready to play this level and practice pronunciation? 😊",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 5),
              Icon(Icons.campaign_rounded, size: 40, color: color),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _startLevel();
              },
              icon: Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                "Let’s Go!",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime += Duration(seconds: 1);
        _formattedTime = _formatDuration(_elapsedTime);
      });
      _timeNotifier.value = _formattedTime;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  // Format the duration as mm:ss
  String _formatDuration(Duration duration) {
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _onSpeakNowPressed() {
    setState(() {
      _moveToNextContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
    ModalRoute.of(context)!.settings.arguments as PlaygroundScreenArguments;
    final level = arguments.level;
    final color = getColor(level.type);

    return MyScaffoldLayout(
      appBar: MyAppBar(title: level.name, color: color),
      topPadding: 10,
      children: [
        Text(
          level.description,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() {
                    _repeatContent();
                  }),
                  child: Text(
                    'Repeat?',
                    style: TextStyle(
                      fontSize: 20,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  spacing: 10,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/timer.svg',
                      colorFilter: ColorFilter.mode(
                        color,
                        BlendMode.srcIn,
                      ),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: _timeNotifier,
                      builder: (context, value, child) {
                        return Text(
                          'Time: $value',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            Lottie.asset(
              'assets/animations/robot.json',
              width: 75,
              height: 75,
            ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        AspectRatio(
          aspectRatio: 1.1,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 75.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color,
                  width: 1,
                ),
              ),
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween:
                      Tween<double>(begin: 0, end: _getFontSize(level.type)),
                  duration: Duration(milliseconds: 500),
                  builder: (context, size, child) {
                    return Opacity(
                      opacity: size / _getFontSize(level.type),
                      // Ensures opacity goes from 0 to 1
                      child: Text(
                        level.content[_currentIndex],
                        style: TextStyle(
                          fontSize: size,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Center(
          child: Text(
            '${_currentIndex + 1} / ${level.content.length}',
          ),
        ),
        SizedBox(height: 15),
        MyElevatedButton(
          text: 'Next',
          color: color,
          textColor: Colors.white,
          prefix: SvgPicture.asset(
            // 'assets/icons/${_isAISpeaking ? 'mic' : 'mic_off'}.svg',
            'assets/icons/mic.svg',
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: _onSpeakNowPressed,
        ),
      ],
    );
  }

  double _getFontSize(contentType) {
    switch (contentType) {
      case ContentType.phonics:
        return 100;
      case ContentType.words:
        return 75;
      case ContentType.sentences:
      default:
        return 50;
    }
  }
}

class PlaygroundScreenArguments {
  Level level;

  PlaygroundScreenArguments({required this.level});
}
