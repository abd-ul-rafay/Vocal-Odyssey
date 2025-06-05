import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supervisor.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'enums.dart';

void showLoadingDialog(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );
}

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelText = 'Cancel',
  String confirmText = 'Confirm',
  Color confirmTextColor = Colors.red,
}) {
  FocusManager.instance.primaryFocus?.unfocus();

  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(color: confirmTextColor),
            ),
          ),
        ],
      );
    },
  );
}

String parseError(http.Response response) {
  try {
    final json = jsonDecode(response.body);
    return json['error'] ?? 'Unknown error';
  } catch (_) {
    return 'Unknown error';
  }
}

String extractErrorMessage(dynamic e) {
  // Remove word 'Exception' from error text
  final message = e.toString();
  final parts = message.split(': ');
  return parts.length > 1 ? parts.sublist(1).join(': ') : message;
}

void googleSignIn(BuildContext context) async {
  try {
    showLoadingDialog(context);
    final result = await AuthService.googleSignIn();
    Navigator.pop(context);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUser(result['user'], result['token']);

    if (userProvider.isLoggedIn) {
      if (userProvider.user is Supervisor) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    }
  } catch (e) {
    Navigator.pop(context);
    Fluttertoast.showToast(
      msg: extractErrorMessage(e),
    );
  }
}

Future<void> logout(BuildContext context) async {
  final confirmed = await showConfirmationDialog(
    context: context,
    title: 'Logout',
    message: 'Are you sure you want to log out?',
    confirmText: 'Logout',
  );

  if (confirmed == true) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    final authProvider = await Provider.of<UserProvider>(context, listen: false);
    authProvider.clearUser();
  }
}

String getContentTypeTitle(ContentType contentType) {
  switch (contentType) {
    case ContentType.phonics:
      return 'Phonics Practice';
    case ContentType.words:
      return 'Words Practice';
    case ContentType.sentences:
      return 'Sentences Practice';
  }
}

MaterialColor getColor(ContentType contentType) {
  switch (contentType) {
    case ContentType.phonics:
      return Colors.blue;
    case ContentType.words:
      return Colors.green;
    case ContentType.sentences:
      return Colors.orange;
  }
}
