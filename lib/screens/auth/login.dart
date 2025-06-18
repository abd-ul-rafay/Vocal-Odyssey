import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/models/admin.dart';
import 'package:vocal_odyssey/models/supervisor.dart';
import 'package:vocal_odyssey/utils/functions.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_text_field.dart';
import 'package:vocal_odyssey/widgets/or_divider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/google_button.dart';
import '../../widgets/my_scaffold_layout.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MyScaffoldLayout(
      topPadding: 100,
      children: [
        Text(
          "Login",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 25),
        Form(
          key: _formKey,
          child: Column(
            children: [
              MyTextField(
                labelText: 'Email',
                hintText: 'e.g., johndoe@gmail.com',
                controller: _emailController,
                icon: Icons.email,
                inputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                focusNode: _emailFocusNode,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_passwordFocusNode),
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
                textInputAction: TextInputAction.done,
                focusNode: _passwordFocusNode,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/recover_password'),
          child: Text('Forgot Password?', style: TextStyle(decoration: TextDecoration.underline),),
        ),
        SizedBox(height: 15),
        MyElevatedButton(
          text: 'Login',
          onPressed: () => _login(context),
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
                  text: "Don't have an account? ",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: "Sign up",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () =>
                        Navigator.pushReplacementNamed(context, '/signup'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    showLoadingDialog(context);

    try {
      final result = await AuthService.login(
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
