import 'package:flutter/material.dart';

class MyDropdownFormField extends StatelessWidget {
  final String? value;
  final String hintText;
  final IconData iconData;
  final Function(String?) onChanged;
  final List<DropdownMenuItem<String>> items;
  final String? Function(String?) validator;

  const MyDropdownFormField({
    Key? key,
    required this.value,
    required this.hintText,
    required this.iconData,
    required this.onChanged,
    required this.items,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12.0),
        color: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 25.0,
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              hint: Text(hintText),
              isExpanded: true,
              onChanged: onChanged,
              items: items,
              validator: validator,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
