import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import '../../models/level.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  PlaygroundScreenState createState() => PlaygroundScreenState();
}

class PlaygroundScreenState extends State<PlaygroundScreen> {
  late Timer _timer;
  bool _isAISpeaking = true;
  Duration _elapsedTime = Duration.zero;
  String _formattedTime = "00:00";

  final ValueNotifier<String> _timeNotifier = ValueNotifier<String>("00:00");

  @override
  void initState() {
    super.initState();

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
      _isAISpeaking = !_isAISpeaking;
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
                    _isAISpeaking = !_isAISpeaking;
                  }),
                  child: Text(
                    _isAISpeaking ? 'AI speaking...' : 'Repeat?',
                    style: TextStyle(
                      fontSize: 16,
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
                        level.content[0],
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
            '1 / ${level.content.length}',
          ),
        ),
        SizedBox(height: 15),
        MyElevatedButton(
          text: _isAISpeaking ? 'Speak Now' : 'Stop Speaking',
          color: color,
          textColor: Colors.white,
          prefix: SvgPicture.asset(
            'assets/icons/${_isAISpeaking ? 'mic' : 'mic_off'}.svg',
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
