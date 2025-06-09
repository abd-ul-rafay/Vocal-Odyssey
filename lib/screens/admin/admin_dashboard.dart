import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import '../../providers/user_provider.dart';
import '../../utils/functions.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    return MyScaffoldLayout(
      children: [
        Text(
          'Hi, ${userProvider.user?.name}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Welcome as an Admin',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(
          height: 50.0,
        ),
        MyElevatedButton(
          text: 'Manage Levels',
          onPressed: () => Navigator.pushNamed(context, '/manage_levels'),
          verticalPadding: 30.0,
          prefix: Icon(
            Icons.leaderboard,
            color: isLightTheme ? Colors.white : Theme.of(context).iconTheme.color,
            size: 22,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        MyElevatedButton(
          text: 'Manage Users',
          onPressed: () => Navigator.pushNamed(context, '/manage_users'),
          verticalPadding: 30.0,
          prefix: Icon(
            Icons.manage_accounts,
            color: isLightTheme ? Colors.white : Theme.of(context).iconTheme.color,
            size: 22,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        MyElevatedButton(
          text: 'Exit Account',
          onPressed: () async => logout(context),
          verticalPadding: 30.0,
          color: isLightTheme ? Colors.redAccent : null,
          textColor: !isLightTheme ? Colors.redAccent : null,
          prefix: Icon(
            Icons.logout,
            color: !isLightTheme ? Colors.redAccent : Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }
}
