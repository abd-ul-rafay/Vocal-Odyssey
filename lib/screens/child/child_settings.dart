import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/models/level_stats.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import '../../providers/child_provider.dart';
import '../../widgets/avatar_progress.dart';
import '../../widgets/my_elevated_button.dart';

class ChildSettingsScreen extends StatefulWidget {
  const ChildSettingsScreen({super.key});

  @override
  State<ChildSettingsScreen> createState() => _ChildSettingsScreenState();
}

class _ChildSettingsScreenState extends State<ChildSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final stats = ModalRoute.of(context)!.settings.arguments as LevelStats;
    final childProvider = Provider.of<ChildProvider>(context);
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final child = childProvider.getSelectedChild();

    return MyScaffoldLayout(
      appBar: MyAppBar(title: 'Child Settings'),
      topPadding: 10,
      children: [
        Text(
          'Child Name: ${child!.name}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
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
          ],
        ),
        SizedBox(height: 10),
        Text('Gender is ${child.gender}', style: TextStyle(fontSize: 18)),
        SizedBox(height: 3),
        Text(
          'Date of Birth is ${DateFormat('MMMM d, yyyy').format(child.dob)}',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 10),
        Divider(),
        SizedBox(height: 10),
        MyElevatedButton(
          text: 'Edit Child Profile',
          prefix: Icon(Icons.edit_note, size: 22),
          onPressed: () =>
              Navigator.pushNamed(context, '/child_form', arguments: false),
        ),
        SizedBox(height: 15),
        MyElevatedButton(
          text: 'Progress Report',
          prefix: Icon(Icons.analytics_outlined, size: 22),
          onPressed: () => Navigator.pushNamed(context, '/progress_report'),
        ),
        SizedBox(height: 15),
        MyElevatedButton(
          text: 'Exit Child Profile',
          prefix: Icon(
            Icons.exit_to_app,
            size: 22,
            color: !isLightTheme ? Colors.redAccent : Colors.white
          ),
          color: isLightTheme ? Colors.redAccent : null,
          textColor: !isLightTheme ? Colors.redAccent : null,
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
        ),
      ],
    );
  }
}
