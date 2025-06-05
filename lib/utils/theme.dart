import 'package:flutter/material.dart';
import 'consts.dart';

ThemeData lightThemeData(BuildContext context) {
  return ThemeData.light().copyWith(
    primaryColor: myColor,
    scaffoldBackgroundColor: offWhite,
    appBarTheme: AppBarTheme(
      backgroundColor: offWhite,
    ),
    colorScheme: const ColorScheme.light(
      primary: myColor,
      secondary: myColor,
      onPrimary: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black), // Primary text
      bodyMedium: TextStyle(color: Colors.black), // Secondary text
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    cardTheme: CardThemeData(
      color: offWhite,
    ),
    dialogTheme: DialogThemeData(
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 24,
      ),
    ),
  );
}

ThemeData darkThemeData(BuildContext context) {
  return ThemeData.dark().copyWith(
    primaryColor: myColor,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: myColor,
      secondary: myColor,
      onPrimary: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
        foregroundColor: WidgetStateProperty.all<Color>(lightGrey),
        side: WidgetStateProperty.all<BorderSide>(BorderSide(
          style: BorderStyle.solid,
          width: 0.5,
          color: mediumGrey,
        )),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white), // Primary text
      bodyMedium: TextStyle(color: lightGrey), // Secondary text
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1c1c1c),
      hintStyle: TextStyle(color: lightGrey),
      labelStyle: TextStyle(color: lightGrey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: mediumGrey,
      thickness: 0.5,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        iconColor: WidgetStateProperty.all<Color>(lightGrey),
      ),
    ),
    iconTheme: IconThemeData(
      color: lightGrey,
    ),
    // disabledColor: Colors.grey,
    cardTheme: CardThemeData(
      color: darkGrey,
    ),
    dialogTheme: DialogThemeData(
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkGrey,
      contentTextStyle: TextStyle(color: Colors.white),
      actionTextColor: Colors.white,
    ),
  );
}
