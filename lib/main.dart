import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/utils/app_providers.dart';
import 'package:vocal_odyssey/utils/app_routes.dart';
import 'package:vocal_odyssey/utils/theme.dart';
import 'package:vocal_odyssey/screens/auth/splash.dart';

void main() {
  runApp(
    MultiProvider(
      providers: appProviders,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocal Odyssey',
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
      home: SplashScreen(),
    );
  }
}
