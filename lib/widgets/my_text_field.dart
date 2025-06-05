import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? labelText;
  final bool isPassword;
  final bool enabled;
  final IconData? icon;
  final TextInputType? inputType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final String? Function(String?)? validator;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.labelText,
    this.isPassword = false,
    this.enabled = true,
    this.icon,
    this.inputType,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.onEditingComplete,
    this.validator,
  });

  @override
  MyTextFieldState createState() => MyTextFieldState();
}

class MyTextFieldState extends State<MyTextField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _isObscured,
          keyboardType: widget.inputType,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          onEditingComplete: widget.onEditingComplete,
          validator: widget.validator,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            prefixIcon: Icon(
              widget.icon,
              color: widget.enabled
                  ? Theme.of(context).iconTheme.color
                  : null,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 12.0,
            ),
            // border: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(12.0),
            // ),
            // focusedBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(12.0),
            // ),
            // enabledBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(12.0),
            // ),
            // disabledBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(12.0),
            // ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(
                        () {
                          _isObscured = !_isObscured;
                        },
                      );
                    },
                  )
                : null,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
        ),
      ],
    );
  }
}
