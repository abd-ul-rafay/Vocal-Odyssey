import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:vocal_odyssey/providers/user_provider.dart';
import 'package:vocal_odyssey/services/attempt_service.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import '../../models/level.dart';
import '../../providers/level_provider.dart';
import '../../services/speech_service.dart';
import '../../utils/functions.dart';
import '../../utils/enums.dart' as myEnum;

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  PlaygroundScreenState createState() => PlaygroundScreenState();
}

class PlaygroundScreenState extends State<PlaygroundScreen> {
  late Level level;
  List<Uint8List?> audioFiles = [];
  bool isLoading = true;
  int currentIndex = 0;
  Map<String, int> _mistakesCount = {};
  double _scoreSum = 0;
  int _scoreCount = 0;

  final audioPlayer = AudioPlayer();
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments
              as PlaygroundScreenArguments;
      level = arguments.level;
      _fetchAllAudioFiles();
      playAudio(AssetSource('audios/greetings.wav'));
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> showTryAgainDialogue(int score) async {
    if (score >= 60) {
      playAudio(AssetSource('audios/retry-1.wav'));
    } else {
      playAudio(AssetSource('audios/retry-2.wav'));
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/animations/sad.json', width: 90),
              Text('Try Again!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
              SizedBox(height: 2),
              Text('Accuracy: $score'),
              SizedBox(height: 2),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Retry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSpeakButton() async {
    audioPlayer.stop();
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      Fluttertoast.showToast(msg: 'Microphone permission not granted');
      requestMicrophonePermission();
      return;
    }

    if (!_isRecording) {
      // Start recording
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/recorded_audio.wav';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: path,
      );

      setState(() {
        _isRecording = true;
      });
    } else {
      // Stop recording
      final path = await _recorder.stop();

      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        showLoadingDialog(
          context,
          text: 'Evaluating your speech',
          widget: Lottie.asset('assets/animations/bubbles.json', width: 120),
        );
        final score = await _evaluateRecordedAudio(path);
        Navigator.pop(context);

        if (score == null) {
          return;
        }

        if (score < 85) {
          final contentItem = level.content[currentIndex];
          _mistakesCount.update(
            contentItem,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }

        if (score >= 85) {
          _scoreSum += score;
          _scoreCount += 1;

          if (score >= 98) {
            playAudio(AssetSource('audios/feedback-1.wav'));
          } else if (score >= 90) {
            playAudio(AssetSource('audios/feedback-2.wav'));
          } else {
            playAudio(AssetSource('audios/feedback-3.wav'));
          }

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/animations/congrats.json'),
                    Text(
                      'Your accuracy is: $score%',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        moveToNext();
                      },
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          await showTryAgainDialogue(score);
          repeatAudio();
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to record your speech!');
      }
    }
  }

  Future<int?> _evaluateRecordedAudio(String path) async {
    audioPlayer.stop();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final referenceText = level.content[currentIndex];

      final response = await SpeechService.evaluateSpeech(
        token: userProvider.token!,
        text: referenceText,
        audioFile: File(path),
      );

      final Map<String, dynamic> json = jsonDecode(response.body);

      if (json['status'] == 'success') {
        final textScore = json['text_score'];
        final speechaceScore = textScore['speechace_score']['pronunciation'];

        return speechaceScore;
      } else {
        playAudio(AssetSource('audios/failed.wav'));
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Evaluation error');
    }
    return null;
  }

  Future<void> _fetchAllAudioFiles() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      isLoading = true;
      audioFiles = List<Uint8List?>.filled(level.content.length, null);
    });

    try {
      final futures = level.content.asMap().entries.map((entry) async {
        final index = entry.key;

        String label = level.type == myEnum.ContentType.phonics
            ? "Letter"
            : level.type == myEnum.ContentType.words
            ? "Word"
            : "Sentence";

        final text = "The $label is: '${entry.value}'";

        final response = await SpeechService.createSpeech(
          token: userProvider.token!,
          text: text,
          voiceId: 'en-US-iris',
        );

        return (index, response.bodyBytes);
      }).toList();

      final results = await Future.wait(futures);

      setState(() {
        for (final result in results) {
          audioFiles[result.$1] = result.$2;
        }
      });
      if (audioFiles[0] != null) {
        playAudio(BytesSource(audioFiles[currentIndex]!));
      }
    } catch (e) {
      showErrorAndPop(context);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> playAudio(Source source) async {
    await audioPlayer.play(source);
    await audioPlayer.onPlayerComplete.first;
  }

  void repeatAudio() {
    if (audioFiles[currentIndex] != null) {
      playAudio(BytesSource(audioFiles[currentIndex]!));
    }
  }

  void moveToNext() {
    if (currentIndex < level.content.length - 1) {
      setState(() {
        currentIndex += 1;
        if (audioFiles[currentIndex] != null) {
          playAudio(BytesSource(audioFiles[currentIndex]!));
        }
      });
    } else {
      endLevel();
    }
  }

  void endLevel() async {
    audioPlayer.stop();

    double avgScore = 0;
    if (_scoreCount > 0) {
      avgScore = _scoreSum / _scoreCount;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final levelProvider = Provider.of<LevelProvider>(context, listen: false);

    final progressId = levelProvider.levelsWithProgress
        .firstWhere((l) => l.level.id == level.id)
        .progress
        .id;

    int totalMistakes = _mistakesCount.values.fold(
      0,
      (sum, count) => sum + count,
    );
    int stars;

    if (avgScore >= level.idealScore && totalMistakes == 0) {
      stars = 3;
    } else if (avgScore >= level.idealScore && totalMistakes <= 1) {
      stars = 2;
    } else {
      stars = 1;
    }

    try {
      showLoadingDialog(
        context,
        text: 'Saving your attempt...',
        widget: Lottie.asset('assets/animations/fruits.json', width: 90),
      );

      final savedAttempt = await AttemptService.createAttempt(
        token: userProvider.token!,
        progressId: progressId,
        score: avgScore.toInt(),
        mistakesCounts: _mistakesCount,
        stars: stars,
      );

      Navigator.pop(context);
      levelProvider.addAttemptToLevel(progressId, savedAttempt);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Level Complete!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                SizedBox(height: 10),
                Text('Your average score: ${avgScore.toInt()}%',),
                Text('Stars achieved: $stars/3',),
                SizedBox(height: 15),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(stars, (index) {
                    return Lottie.asset(
                      'assets/animations/star.json',
                      width: 70,
                      fit: BoxFit.contain,
                    );
                  }),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text('Continue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (error) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: 'Failed to save attempt: ${error.toString()}',
      );
    }
  }

  Future<void> onBackPressed() async {
    final shouldExit = await showConfirmationDialog(
      context: context,
      title: 'Exit Level',
      message:
      'Your attempt will not be saved!',
      cancelText: 'No',
      confirmText: 'Exit',
    );
    if (shouldExit == true) {
      audioPlayer.stop();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as PlaygroundScreenArguments;
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final level = arguments.level;

    return PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (!didPop) {
            await onBackPressed();
          }
        },
        child: MyScaffoldLayout(
          appBar: MyAppBar(title: level.name, onBack: onBackPressed,),
          topPadding: isLoading ? 150 : 10,
          children: isLoading
              ? [
            buildLoadingIndicator(
              widget: Lottie.asset(
                'assets/animations/shapes_loading.json',
                width: 200,
                fit: BoxFit.contain,

              ),
              text: "Getting things ready for you",
            ),
          ]
              : [
            Text(
              level.description,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/gen_ai.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).iconTheme.color ?? Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feel free to speak,',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'or repeat if you want.',
                          style: TextStyle(fontSize: 16),
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
            SizedBox(height: 20.0),
            AspectRatio(
              aspectRatio: 1.1,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 75.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1),
                  ),
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: getFontSize(level.type),
                      ),
                      duration: Duration(milliseconds: 500),
                      builder: (context, size, child) {
                        return Opacity(
                          opacity: size / getFontSize(level.type),
                          child: Text(
                            level.content[currentIndex],
                            style: TextStyle(
                              fontSize: size,
                              fontWeight: FontWeight.w900,
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
              child: Text('${currentIndex + 1} / ${level.content.length}'),
            ),
            SizedBox(height: 15),
            MyElevatedButton(
              text: 'Repeat',
              prefix: SvgPicture.asset(
                'assets/icons/repeat.svg',
                colorFilter: ColorFilter.mode(
                  isLightTheme
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.grey,
                  BlendMode.srcIn,
                ),
                width: 22,
              ),
              onPressed: repeatAudio,
            ),
            SizedBox(height: 10),
            MyElevatedButton(
              text: !_isRecording ? 'Speak' : 'Stop',
              prefix: SvgPicture.asset(
                'assets/icons/${_isRecording ? 'mic_off' : 'mic'}.svg',
                colorFilter: ColorFilter.mode(
                  isLightTheme
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.grey,
                  BlendMode.srcIn,
                ),
                width: 22,
              ),
              onPressed: _handleSpeakButton,
            ),
          ],
        ),
    );
  }
}

class PlaygroundScreenArguments {
  Level level;

  PlaygroundScreenArguments({required this.level});
}
