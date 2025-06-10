import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:vocal_odyssey/providers/user_provider.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import '../../models/level.dart';
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
      playAudio(AssetSource('/audios/greetings.wav'));
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _handleSpeakButton() async {
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

      print('Recording started: $path');
    } else {
      // Stop recording
      final path = await _recorder.stop();

      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        print('Recording saved to: $path');
        showLoadingDialog(context, text: 'Evaluating your speech');
        final score = await _evaluateRecordedAudio(path);
        Navigator.pop(context);

        if (score == null) {
          Fluttertoast.showToast(msg: "Something went wrong");
          return;
        }

        if (score >= 85) {
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
                    Text(
                      'Good Job! 🎉',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontSize: 20),
                    ),
                    Text(
                      'Your score is: $score',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10,),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        moveToNext();
                      },
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (score >= 60) {
          Fluttertoast.showToast(msg: 'Try again! Score: $score');
          await playAudio(AssetSource('/audios/retry-1.wav'));
          repeatAudio();
        } else {
          Fluttertoast.showToast(msg: 'Try again! Score: $score');
          await playAudio(AssetSource('/audios/retry-2.wav'));
          repeatAudio();
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to record your speech!');
      }
    }
  }

  Future<int?> _evaluateRecordedAudio(String path) async {
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

        print('SpeechAce Pronunciation: $speechaceScore');

        return speechaceScore;
      } else {
        Fluttertoast.showToast(msg: 'Evaluation failed');
      }
    } catch (e) {
      print('Error during evaluation: $e');
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

      print('All audio files loaded successfully');
      if (audioFiles[0] != null) {
        playAudio(BytesSource(audioFiles[currentIndex]!));
      }
    } catch (e) {
      print('Failed to load audio: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> playAudio(Source source) async {
    final audioPlayer = AudioPlayer();
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

  void endLevel() {
    print('End');
    Fluttertoast.showToast(msg: 'Level completed!');
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as PlaygroundScreenArguments;
    final level = arguments.level;

    return MyScaffoldLayout(
      appBar: MyAppBar(title: level.name),
      topPadding: isLoading ? 250 : 10,
      children: isLoading
          ? [buildLoadingIndicator("Getting things ready for you")]
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
                        'assets/icons/timer.svg',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color ?? Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Time is ticking...',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                                color: Colors.blue,
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
                textColor: Colors.orange,
                prefix: Icon(Icons.repeat, color: Colors.orange),
                onPressed: repeatAudio,
              ),
              SizedBox(height: 10),
              MyElevatedButton(
                text: 'Speak',
                textColor: Colors.green,
                prefix: SvgPicture.asset(
                  'assets/icons/${_isRecording ? 'mic_off' : 'mic'}.svg',
                  colorFilter: ColorFilter.mode(Colors.green, BlendMode.srcIn),
                ),
                onPressed: _handleSpeakButton,
              ),
            ],
    );
  }
}

class PlaygroundScreenArguments {
  Level level;

  PlaygroundScreenArguments({required this.level});
}
