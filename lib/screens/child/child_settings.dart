import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import '../../providers/child_provider.dart';
import '../../widgets/my_elevated_button.dart';

class ChildSettingsScreen extends StatefulWidget {
  const ChildSettingsScreen({super.key});

  @override
  State<ChildSettingsScreen> createState() => _ChildSettingsScreenState();
}

class _ChildSettingsScreenState extends State<ChildSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final childProvider = Provider.of<ChildProvider>(context);
    final child = childProvider.getSelectedChild();

    return MyScaffoldLayout(
      appBar: MyAppBar(title: 'Child Settings'),
      topPadding: 10,
      children: [
        Text(
          'Name: ${child!.name}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20),
        ),
        SizedBox(height: 2),
        Text('Gender: ${child.gender}', style: TextStyle(fontSize: 16)),
        SizedBox(height: 2),
        Text(
          'Date of Birth: ${DateFormat('MMMM d, yyyy').format(child.dob)}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        MyElevatedButton(
          text: 'Edit Child Profile',
          prefix: Icon(Icons.edit_note, size: 22),
          onPressed: () =>
              Navigator.pushNamed(context, '/child_form', arguments: false),
        ),
        SizedBox(height: 10),
        Divider(),
        SizedBox(height: 5),
        MyElevatedButton(
          text: 'Progress Report',
          prefix: Icon(Icons.analytics_outlined, size: 22),
          onPressed: () => Navigator.pushNamed(context, '/progress_report'),
        ),
        SizedBox(height: 10),
        Divider(),
        SizedBox(height: 5),
        MyElevatedButton(
          text: 'Exit Child Profile',
          prefix: Icon(Icons.exit_to_app, size: 22),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
        ),
      ],
    );
  }
}
