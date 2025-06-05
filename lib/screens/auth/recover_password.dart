import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import 'package:vocal_odyssey/widgets/my_text_field.dart';

import '../../services/auth_service.dart';
import '../../utils/functions.dart';

class RecoverPasswordScreen extends StatelessWidget {
  RecoverPasswordScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MyScaffoldLayout(
      appBar: MyAppBar(title: 'Recover Password'),
      children: [
        Text(
          "Enter your Email and Change Password",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Form(
          key: _emailFormKey,
          child: Column(
            children: [
              MyTextField(
                labelText: 'Email',
                hintText: 'example@email.com',
                controller: _emailController,
                icon: Icons.email,
                inputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                focusNode: _emailFocusNode,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              MyElevatedButton(
                text: 'Request OTP',
                onPressed: () => _handleRequestOtp(context),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Form(
          key: _passFormKey,
          child: Column(
            children: [
              MyTextField(
                labelText: 'Enter OTP',
                hintText: '',
                controller: _otpController,
                icon: Icons.numbers,
                inputType: TextInputType.number,
                textInputAction: TextInputAction.next,
                focusNode: _otpFocusNode,
                onEditingComplete: () => FocusScope.of(context).requestFocus(_newPasswordFocusNode),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'OTP must be numeric';
                  }
                  if (value.length != 6) {
                    return 'OTP must be 6 characters only';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              MyTextField(
                labelText: 'New Password',
                hintText: 'min. 6 characters',
                controller: _newPasswordController,
                icon: Icons.lock,
                isPassword: true,
                textInputAction: TextInputAction.next,
                focusNode: _newPasswordFocusNode,
                onEditingComplete: () => FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$').hasMatch(value)) {
                    return 'Password must include both letters and numbers';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              MyTextField(
                labelText: 'Confirm Password',
                hintText: 'same as above',
                controller: _confirmPasswordController,
                icon: Icons.check_circle_rounded,
                isPassword: true,
                textInputAction: TextInputAction.done,
                focusNode: _confirmPasswordFocusNode,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              MyElevatedButton(
                text: 'Save',
                onPressed: () => _handleRecoverPassword(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleRequestOtp(BuildContext context) async {
    if (!_emailFormKey.currentState!.validate()) return;

    try {
      showLoadingDialog(context);
      await AuthService.requestPasswordRecovery(_emailController.text.trim());
      Navigator.of(context).pop();

      Fluttertoast.showToast(
        msg: 'You\'ll receive an OTP via this email.',
      );
    } catch (e) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: extractErrorMessage(e),
      );
    }
  }

  Future<void> _handleRecoverPassword(BuildContext context) async {
    if (!_passFormKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;

    try {
      showLoadingDialog(context);
      await AuthService.recoverPassword(email, otp, newPassword);
      Navigator.of(context).pop();

      Fluttertoast.showToast(
        msg: 'Password reset successful!',
      );
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: extractErrorMessage(e),
      );
    }
  }
}
