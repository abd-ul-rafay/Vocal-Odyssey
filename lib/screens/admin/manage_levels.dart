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
      Fluttertoast.showToast(msg: extractErrorMessage(e));
    }
  }

  Future<bool> _deleteLevel(String id) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Level',
      message: 'Are you sure you want to delete this level?',
      confirmText: 'Delete',
    );

    if (confirmed != true) return false;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await AdminService.deleteLevel(id, userProvider.token!);
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: extractErrorMessage(e));
    }

    return false;
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
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return MyScaffoldLayout(
      appBar: MyAppBar(title: 'Manage Levels'),
      children: [
        MyElevatedButton(
          text: 'Create New Level',
          onPressed: () => _navigateToLevelForm(),
          verticalPadding: 30.0,
          prefix: Icon(
            Icons.add_chart_outlined,
            color: isLightMode
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
            size: 22,
          ),
        ),
        SizedBox(height: 10),
        FutureBuilder<List<Level>>(
          future: _levelsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 200,
                child: buildLoadingIndicator(text: "Loading levels"),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(child: Text('Couldn\'t load levels')),
              );
            } else if (snapshot.hasData) {
              final levels = snapshot.data!..sort((a, b) => contentTypeOrder(a.type).compareTo(contentTypeOrder(b.type)));

              return Column(
                children: levels.map((level) {
                  return BasicLevelCard(
                    levelName: level.name,
                    levelType: getContentTypeTitle(level.type),
                    levelDescription: level.description,
                    onPressed: () => _navigateToLevelForm(level),
                    onDeletePressed: () async {
                      final isDeleted = await _deleteLevel(level.id);

                      if (isDeleted) {
                        setState(() {
                          levels.remove(level);
                        });
                      }
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
