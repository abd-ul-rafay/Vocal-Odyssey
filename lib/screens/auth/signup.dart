import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/utils/functions.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import 'package:vocal_odyssey/widgets/my_text_field.dart';
import 'package:vocal_odyssey/widgets/or_divider.dart';
import '../../models/admin.dart';
import '../../models/supervisor.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/google_button.dart';
class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key

  @override
  Widget build(BuildContext context) {
    return MyScaffoldLayout(
      topPadding: 100,
      children: [
        Text(
          "Sign Up",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text('As a Parent/Guardian'),
        SizedBox(height: 25),
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
                    return 'Please enter your full name';
                  } else if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              MyTextField(
                labelText: 'Email',
                hintText: 'e.g., johndoe@gmail.com',
                controller: _emailController,
                inputType: TextInputType.emailAddress,
                icon: Icons.email,
                textInputAction: TextInputAction.next,
                focusNode: _emailFocusNode,
                onEditingComplete: () => FocusScope.of(context).requestFocus(_passwordFocusNode),
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
              MyTextField(
                labelText: 'Password',
                hintText: 'min. 6 characters',
                controller: _passwordController,
                icon: Icons.lock,
                isPassword: true,
                textInputAction: TextInputAction.next,
                focusNode: _passwordFocusNode,
                onEditingComplete: () => FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(value)) {
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
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        MyElevatedButton(
          text: 'Sign Up',
          onPressed: () => _signup(context),
        ),
        OrDivider(),
        GoogleButton(
          onPressed: () => googleSignIn(context),
        ),
        SizedBox(height: 20.0),
        Align(
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Already have an account? ",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: "Login",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap =
                        () => Navigator.pushReplacementNamed(context, '/login'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _signup(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    showLoadingDialog(context);

    try {
      final result = await AuthService.signup(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      Navigator.pop(context);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(result['user'], result['token']);

      if (userProvider.isLoggedIn) {
        if (userProvider.user is Supervisor) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else if (userProvider.user is Admin) {
          Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (route) => false);
        }
      }

    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: extractErrorMessage(e),
      );
    }
  }
}
