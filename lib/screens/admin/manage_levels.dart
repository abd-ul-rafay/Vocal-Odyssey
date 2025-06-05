import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/widgets/basic_level_card.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import '../../models/level.dart';
import '../../providers/user_provider.dart';
import '../../services/admin_service.dart';
import '../../utils/functions.dart';

class ManageLevelsScreen extends StatefulWidget {
  ManageLevelsScreen({super.key});

  @override
  _ManageLevelsScreenState createState() => _ManageLevelsScreenState();
}

class _ManageLevelsScreenState extends State<ManageLevelsScreen> {
  late Future<List<Level>> _levelsFuture;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  void _loadLevels() {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _levelsFuture = AdminService.getLevels(userProvider.token!);
    } catch (e) {
      Fluttertoast.showToast(
        msg: extractErrorMessage(e),
      );
    }
  }

  Future<void> _deleteLevel(String id) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await AdminService.deleteLevel(id, userProvider.token!);
    } catch (e) {
      Fluttertoast.showToast(
        msg: extractErrorMessage(e),
      );
    }
  }

  Future<void> _navigateToLevelForm([Level? level]) async {
    await Navigator.pushNamed(context, '/level_form', arguments: level);
    // After return, reload levels
    setState(() {
      _loadLevels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffoldLayout(
      appBar: MyAppBar(title: 'Manage Levels'),
      children: [
        MyElevatedButton(
          text: 'Create New Level',
          onPressed: () => _navigateToLevelForm(),
          verticalPadding: 30.0,
          prefix: Icon(Icons.add_chart_outlined, color: Colors.white, size: 22),
        ),
        SizedBox(height: 10),
        FutureBuilder<List<Level>>(
          future: _levelsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(child: Text('Couldn\'t load levels')),
              );
            } else if (snapshot.hasData) {
              final levels = snapshot.data!;
              return Column(
                children: levels.map((level) {
                  return BasicLevelCard(
                    levelName: level.name,
                    levelType: getContentTypeTitle(level.type),
                    levelDescription: level.description,
                    onPressed: () => _navigateToLevelForm(level),
                    onDeletePressed: () async {
                      await _deleteLevel(level.id);
                      setState(() {
                        levels.remove(level);
                      });
                    },
                  );
                }).toList(),
              );
            }
            return SizedBox(
              height: 200,
              child: Center(child: Text('Something went wrong')),
            );
          },
        ),
      ],
    );
  }
}
