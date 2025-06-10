import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/providers/child_provider.dart';
import 'package:vocal_odyssey/widgets/child_card.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import '../../providers/user_provider.dart';
import '../../services/child_service.dart';
import '../../utils/functions.dart';
import '../../widgets/welcome_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _loadChildrenFuture;

  @override
  void initState() {
    super.initState();
    _loadChildrenFuture = _loadChildren();
  }

  Future<void> _loadChildren() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final childProvider = Provider.of<ChildProvider>(context, listen: false);

    final children = await ChildService.getChildren(
      userProvider.user!.id,
      userProvider.token!,
    );
    childProvider.setChildren(children);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final childProvider = Provider.of<ChildProvider>(context);
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return MyScaffoldLayout(
      topPadding: 0,
      appBar: WelcomeAppBar(
        title: 'Hi, ${userProvider.user?.name}',
        subtitle: 'Welcome to Vocal Odyssey',
        topPadding: 30,
        bottomPadding: 30,
        titleWidth: 0.75,
        actionWidget: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/settings'),
          child: SvgPicture.asset(
            'assets/icons/settings.svg',
            width: 30,
            colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color ?? Colors.grey,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      children: [
        MyElevatedButton(
          text: 'Create Child Profile',
          onPressed: () => Navigator.pushNamed(
            context,
            '/child_form',
            arguments: true,
          ),
          verticalPadding: 30.0,
          prefix: Icon(
            Icons.person_add_alt,
            size: 22,
            color: isLightMode ? Colors.white : null,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Divider(),
        FutureBuilder<void>(
          future: _loadChildrenFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 250,
                child: buildLoadingIndicator("Loading child profiles"),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(child: Text('Couldn\'t load children profiles')),
              );
            } else if (childProvider.children.isEmpty) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No child profile found!',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontSize: 18),
                      ),
                      SizedBox(height: 2,),
                      Text('Tap the button above to add one.'),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: childProvider.children.asMap().entries.map((entry) {
                final index = entry.key;
                final child = entry.value;

                return ChildCard(
                  name: child.name,
                  gender: child.gender,
                  dob: DateFormat('MMMM d, yyyy').format(child.dob),
                  imagePath: child.imagePath,
                  onClick: () => _onChildCardClick(context, index),
                  onDeleteClick: () async => _deleteChild(context, child.id),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _deleteChild(BuildContext context, String childId) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Profile',
      message: 'Are you sure you want to delete this profile?',
      confirmText: 'Delete',
    );

    if (confirmed == true) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final childProvider = Provider.of<ChildProvider>(context, listen: false);

      try {
        await ChildService.deleteChild(childId, userProvider.token!);
        childProvider.removeChild(childId);
      } catch (e) {
        Fluttertoast.showToast(
          msg: extractErrorMessage(e),
        );
      }
    }
  }

  void _onChildCardClick(BuildContext context, int index) {
    final childProvider = Provider.of<ChildProvider>(context, listen: false);
    childProvider.setSelectedChild(index);
    Navigator.pushReplacementNamed(context, '/child_dashboard',);
  }
}
