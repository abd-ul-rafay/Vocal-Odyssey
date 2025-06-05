import 'package:flutter/material.dart';
import 'package:vocal_odyssey/screens/admin/admin_dashboard.dart';
import 'package:vocal_odyssey/screens/supervisor/child_form.dart';
import 'package:vocal_odyssey/screens/child/child_dashboard.dart';
import 'package:vocal_odyssey/screens/child/child_settings.dart';
import 'package:vocal_odyssey/screens/supervisor/home.dart';
import 'package:vocal_odyssey/screens/admin/level_form.dart';
import 'package:vocal_odyssey/screens/child/progress/level_overview.dart';
import 'package:vocal_odyssey/screens/auth/login.dart';
import 'package:vocal_odyssey/screens/child/level_selection.dart';
import 'package:vocal_odyssey/screens/admin/manage_levels.dart';
import 'package:vocal_odyssey/screens/admin/manage_users.dart';
import 'package:vocal_odyssey/screens/child/playground.dart';
import 'package:vocal_odyssey/screens/child/progress/progress_report.dart';
import 'package:vocal_odyssey/screens/auth/recover_password.dart';
import 'package:vocal_odyssey/screens/supervisor/settings.dart';
import 'package:vocal_odyssey/screens/auth/signup.dart';
import 'package:vocal_odyssey/screens/auth/welcome.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // Auth Screens
  '/welcome': (context) => WelcomeScreen(),
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignUpScreen(),
  '/recover_password': (context) => RecoverPasswordScreen(),
  // Supervisor Screens
  '/home': (context) => HomeScreen(),
  '/settings': (context) => SettingsScreen(),
  '/child_form': (context) => ChildFormScreen(),
  // Child Screens
  '/child_dashboard': (context) => ChildDashboardScreen(),
  '/child_settings': (context) => ChildSettingsScreen(),
  '/level_selection': (context) => LevelSelectionScreen(),
  '/playground': (context) => PlaygroundScreen(),
  '/progress_report': (context) => ProgressReportScreen(),
  '/level_overview': (context) => LevelOverviewScreen(),
  // Admin Screens
  '/admin_dashboard': (context) => AdminDashboardScreen(),
  '/manage_levels': (context) => ManageLevelsScreen(),
  '/manage_users': (context) => ManageUsersScreen(),
  '/level_form': (context) => LevelFormScreen(),
};
