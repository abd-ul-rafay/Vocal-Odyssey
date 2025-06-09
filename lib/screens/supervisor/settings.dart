import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/services/supervisor_service.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import '../../models/supervisor.dart';
import '../../providers/user_provider.dart';
import '../../utils/functions.dart';
import '../../widgets/my_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    _nameController.text = userProvider.user?.name ?? '';
    _emailController.text = (userProvider.user as Supervisor).email;

    return MyScaffoldLayout(
      appBar: MyAppBar(title: 'Settings'),
      children: [
        Text(
          'Edit Your Info',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              MyTextField(
                labelText: 'Full Name',
                hintText: 'e.g., John Doe',
                controller: _nameController,
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the full name';
                  } else if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              MyTextField(
                labelText: 'Email',
                hintText: 'e.g., john.doe@gmail.com',
                controller: _emailController,
                icon: Icons.email,
                enabled: false,
              ),
              SizedBox(height: 12),
              // Save Button
              MyElevatedButton(
                text: 'Update',
                onPressed: () => _updateSupervisor(
                    userProvider, _nameController.text.trim()),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Divider(),
        ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text(
            'Privacy & Security',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => _showInfoDialog(
            context,
            'Privacy & Security',
            'Your privacy is important to us. Vocal Odyssey follows strict guidelines like COPPA and GDPR to ensure your child\'s data is protected. We never store raw voice data and all personal information is securely encrypted. Only parents have access to their child\'s progress, and nothing is shared with anyone.',
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text(
            'Help & Support',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => _showInfoDialog(
            context,
            'Help & Support',
            'If you have any questions, feedback, or run into issues while using the app, we’re here to help! Vocal Odyssey is designed to be simple and fun, but if you ever need assistance, don’t hesitate to contact us at vocalodyssey.team@gmail.com. We’ll get back to you as soon as possible.',
          ),
        ),
        Divider(),
        SizedBox(
          height: 15,
        ),
        MyElevatedButton(
          text: 'Logout',
          onPressed: () async => logout(context),
          color: isLightTheme ? Colors.redAccent : null,
          textColor: !isLightTheme ? Colors.redAccent : null,
        ),
      ],
    );
  }

  void _updateSupervisor(UserProvider userProvider, String name) async {
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text == userProvider.user!.name) {
      Fluttertoast.showToast(
        msg: 'The name hasn\'t been modified.',
      );

      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }

    showLoadingDialog(context);

    final user = await SupervisorService.updateSupervisor(
        userProvider.user!.id, name, userProvider.token!);

    userProvider.updateUser(user);

    Fluttertoast.showToast(
      msg: 'Your name is updated!',
    );

    Navigator.pop(context);
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(
          message,
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
