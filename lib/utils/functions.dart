import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supervisor.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'enums.dart';

void showLoadingDialog(BuildContext context, {Widget? widget, String? text}) {
  FocusManager.instance.primaryFocus?.unfocus();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget != null ? widget : CircularProgressIndicator(),
            if (text != null) ...[
              const SizedBox(height: 16),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget buildLoadingIndicator({Widget? widget, String? text}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Center(child: widget != null ? widget : CircularProgressIndicator()),
      SizedBox(height: 15),
      if (text != null)
        Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
    ],
  );
}

void showErrorAndPop(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Error"),
      content: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text("Something went wrong. Please try again."),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text("OK"),
        ),
      ],
    ),
  ).then((_) {
    Navigator.of(context).pop(); // Pop the screen after dialog is dismissed
  });
}

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelText = 'Cancel',
  String confirmText = 'Confirm',
  Color confirmTextColor = Colors.redAccent,
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

Future<void> requestMicrophonePermission() async {
  final status = await Permission.microphone.request();
  if (!status.isGranted) {
    throw Exception('Microphone permission denied');
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

double getFontSize(contentType) {
  switch (contentType) {
    case ContentType.phonics:
      return 100;
    case ContentType.words:
      return 75;
    case ContentType.sentences:
    default:
      return 50;
  }
}
