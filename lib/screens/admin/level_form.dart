import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/models/level.dart';
import 'package:vocal_odyssey/providers/user_provider.dart';
import 'package:vocal_odyssey/services/admin_service.dart';
import 'package:vocal_odyssey/utils/enums.dart';
import 'package:vocal_odyssey/utils/functions.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import 'package:vocal_odyssey/widgets/my_text_field.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_dropdown_form_field.dart';

class LevelFormScreen extends StatefulWidget {
  const LevelFormScreen({super.key});

  @override
  _LevelFormScreenState createState() => _LevelFormScreenState();
}

class _LevelFormScreenState extends State<LevelFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _idealScoreController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _idealScoreFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContentType? _selectedType;

  Level? _initialLevel;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initialLevel = ModalRoute.of(context)!.settings.arguments as Level?;
      final level = _initialLevel;
      if (level != null) {
        _nameController.text = level.name;
        _descriptionController.text = level.description;
        _idealScoreController.text = level.idealScore.toString();
        _contentController.text = level.content.join(' | ');
        _selectedType = level.type;
      }
      _isInitialized = true;
    }
  }

  void _addLevel(Level level) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showLoadingDialog(context);

    try {
      await AdminService.createLevel(
        name: level.name,
        description: level.description,
        idealScore: level.idealScore,
        type: level.type,
        content: level.content,
        token: userProvider.token!,
      );

      Fluttertoast.showToast(
        msg: 'Level created successfully.',
      );

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: extractErrorMessage(e),
      );
    }
  }

  void _editLevel(Level level) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showLoadingDialog(context);

    try {
      await AdminService.updateLevel(
        levelId: level.id,
        name: level.name,
        description: level.description,
        idealScore: level.idealScore,
        type: level.type,
        content: level.content,
        token: userProvider.token!,
      );

      Fluttertoast.showToast(
        msg: 'Level updated successfully.',
      );

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: extractErrorMessage(e),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAddMode = _initialLevel == null;

    return MyScaffoldLayout(
      appBar: MyAppBar(title: isAddMode ? 'Add Level' : 'Edit Level'),
      topPadding: 10,
      children: [
        Text(
          isAddMode ? 'Please complete the form' : 'Modify the fields below',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 15),
        Form(
          key: _formKey,
          child: Column(
            children: [
              MyTextField(
                labelText: 'Name',
                hintText: 'Enter level name',
                controller: _nameController,
                icon: Icons.drive_file_rename_outline,
                inputType: TextInputType.text,
                textInputAction: TextInputAction.next,
                focusNode: _nameFocusNode,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_descriptionFocusNode),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              MyTextField(
                labelText: 'Description',
                hintText: 'Enter level description',
                controller: _descriptionController,
                icon: Icons.description,
                inputType: TextInputType.multiline,
                textInputAction: TextInputAction.next,
                focusNode: _descriptionFocusNode,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_idealScoreFocusNode),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              MyTextField(
                labelText: 'Ideal score',
                hintText: 'Enter ideal score',
                controller: _idealScoreController,
                icon: Icons.timer,
                inputType: TextInputType.number,
                textInputAction: TextInputAction.next,
                focusNode: _idealScoreFocusNode,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_contentFocusNode),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the ideal score';
                  } else if (int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              MyDropdownFormField(
                value: _selectedType?.toString().split('.').last,
                hintText: 'Select Content Type',
                iconData: Icons.category,
                items: ContentType.values
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type.toString().split('.').last,
                        child: Text(
                          type.toString().split('.').last[0].toUpperCase() +
                              type.toString().split('.').last.substring(1),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = ContentType.values.firstWhere(
                      (type) => type.toString().split('.').last == newValue,
                    );
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a content type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              MyTextField(
                labelText: 'Content',
                hintText: 'Enter content separated by |',
                controller: _contentController,
                icon: Icons.text_fields,
                textInputAction: TextInputAction.done,
                focusNode: _contentFocusNode,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the content';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              MyElevatedButton(
                text: isAddMode ? 'Add Level' : 'Save Changes',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newLevel = Level(
                      isAddMode
                          ? DateTime.now().millisecondsSinceEpoch.toString()
                          : _initialLevel!.id,
                      name: _nameController.text,
                      description: _descriptionController.text,
                      idealScore: int.parse(_idealScoreController.text),
                      type: _selectedType!,
                      content: _contentController.text.split('|').map((e) => e.trim()).toList(),
                    );

                    isAddMode ? _addLevel(newLevel) : _editLevel(newLevel);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
