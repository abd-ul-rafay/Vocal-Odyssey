import 'package:flutter/material.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffoldLayout(
      topPadding: 150.0,
      axisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/abc.png',
          width: 250,
        ),
        SizedBox(
          height: 30.0,
        ),
        Text(
          "Vocal Odyssey",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          "An Interactive AI Speech Assistant for Kids to Learn Pronunciation",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            // fontWeight: FontWeight.bold,
            height: 0,
          ),
        ),
        SizedBox(
          height: 50.0,
        ),
        MyElevatedButton(
          text: 'Get Started',
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ],
    );
  }
}
