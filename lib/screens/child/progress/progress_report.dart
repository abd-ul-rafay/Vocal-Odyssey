import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import '../../../providers/level_provider.dart';
import '../../../utils/functions.dart';
import '../../../widgets/basic_level_card.dart';

class ProgressReportScreen extends StatelessWidget {
  ProgressReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levelProvider = Provider.of<LevelProvider>(context);
    final lwp = levelProvider.levelsWithProgress;final levels = [
      for (var l in lwp)
        if (l.attempts.isNotEmpty) l.level
    ]..sort((a, b) => contentTypeOrder(a.type).compareTo(contentTypeOrder(b.type)));


    return MyScaffoldLayout(
      appBar: MyAppBar(title: 'Progress Report'),
      children: [
        Text(
          'These are the progress made by your child',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10,),
        if (levels.isEmpty) Padding(
          padding: EdgeInsets.only(top: 250),
          child: Center(child: Text('No Progress Made Yet!'),),
        ),
        ...levels.map((level) {
          return BasicLevelCard(
            levelName: level.name,
            levelType: getContentTypeTitle(level.type),
            levelDescription: level.description,
            onPressed: () => Navigator.pushNamed(context, '/level_overview', arguments: level),
            isAdmin: false,
          );
        }),
      ],
    );
  }
}
