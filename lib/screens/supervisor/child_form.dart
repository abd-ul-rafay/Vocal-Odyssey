import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/utils/consts.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_avatar.dart';
import 'package:vocal_odyssey/widgets/my_dropdown_form_field.dart';
import 'package:vocal_odyssey/widgets/my_elevated_button.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import 'package:vocal_odyssey/widgets/my_text_field.dart';
import '../../providers/child_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/child_service.dart';
import '../../utils/functions.dart';

class ChildFormScreen extends StatefulWidget {
  const ChildFormScreen({super.key});

  @override
  ChildFormScreenState createState() => ChildFormScreenState();
}

class ChildFormScreenState extends State<ChildFormScreen> {
  late ChildProvider childProvider;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime? _dateOfBirth;
  String _labelText = 'Date of Birth';
  String _gender = 'Male';
  String _imagePath = defaultImagePath;

  bool _isInit = true;
  late bool isSaveMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      childProvider = Provider.of<ChildProvider>(context);
      isSaveMode = ModalRoute.of(context)!.settings.arguments as bool;

      if (!isSaveMode) {
        final child = childProvider.getSelectedChild();
        _nameController.text = child!.name;
        _dateOfBirth = child.dob;
        _dobController.text = '${_dateOfBirth!.toLocal()}'.split(' ')[0];
        _labelText = 'Date of Birth';
        _gender = child.gender;
        _imagePath = child.imagePath;
      }

      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffoldLayout(
      appBar: MyAppBar(
        title: isSaveMode ? 'Child Profile Creation' : 'Edit Child Profile',
      ),
      children: [
        Center(
          child: GestureDetector(
            onTap: () => showAvatarPickerDialog(context),
            child: MyAvatar(
              radius: 75,
              imagePath: _imagePath,
            ),
          ),
        ),
        SizedBox(height: 5),
        Center(child: Text('Select Child\'s Avatar')),
        SizedBox(height: 15),
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
                    return 'Please enter the full name';
                  } else if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: () => _pickDateOfBirth(context),
                child: AbsorbPointer(
                  child: MyTextField(
                    labelText: _labelText,
                    hintText: _dateOfBirth != null
                        ? '${_dateOfBirth!.toLocal()}'.split(' ')[0]
                        : 'e.g., 01/01/2000',
                    controller: _dobController,
                    icon: Icons.calendar_today,
                    validator: (value) {
                      if (_dateOfBirth == null) {
                        return 'Please select the date of birth';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 12),
              MyDropdownFormField(
                value: _gender,
                hintText: 'Select Gender',
                iconData: Icons.male,
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue ?? 'Male';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a gender';
                  }
                  return null;
                },
                items: <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    })
                    .toList(),
              ),
              SizedBox(height: 12),
              MyElevatedButton(
                text: isSaveMode ? 'Save' : 'Update',
                onPressed: () => isSaveMode
                    ? _saveChild(context)
                    : _updateChild(
                        context,
                        childProvider.getSelectedChild()!.id,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _dateOfBirth) {
      setState(() {
        _dateOfBirth = pickedDate;
        _dobController.text = '${_dateOfBirth!.toLocal()}'.split(' ')[0];
      });
    }
  }

  Future<void> showAvatarPickerDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose an Avatar',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: avatarPaths.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final path = avatarPaths[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _imagePath = path;
                        });
                        Navigator.pop(ctx);
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(path),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChild(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    showLoadingDialog(context);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final child = await ChildService.createChild(
        name: _nameController.text.trim(),
        gender: _gender.toLowerCase(),
        dob: _dateOfBirth!.toIso8601String().split('T')[0],
        // e.g., '2025-05-23'
        imagePath: _imagePath,
        supervisorId: userProvider.user!.id,
        token: userProvider.token!,
      );

      childProvider.addChild(child);

      Navigator.pop(context);
      Navigator.pop(context);

      Fluttertoast.showToast(msg: 'Child created successfully!');
    } catch (e) {
      Navigator.pop(context);

      Fluttertoast.showToast(msg: extractErrorMessage(e));
    }
  }

  Future<void> _updateChild(BuildContext context, childId) async {
    if (!_formKey.currentState!.validate()) return;

    showLoadingDialog(context);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final child = await ChildService.updateChild(
        name: _nameController.text.trim(),
        gender: _gender.toLowerCase(),
        dob: _dateOfBirth!.toIso8601String().split('T')[0],
        imagePath: _imagePath,
        childId: childId,
        token: userProvider.token!,
      );

      childProvider.updateChild(child);

      Navigator.pop(context);
      Navigator.pop(context);

      Fluttertoast.showToast(msg: 'Child updated successfully!');
    } catch (e) {
      Navigator.pop(context);

      Fluttertoast.showToast(msg: extractErrorMessage(e));
    }
  }
}
