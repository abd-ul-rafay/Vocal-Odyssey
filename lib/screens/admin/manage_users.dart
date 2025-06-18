import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/models/supervisor.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import 'package:vocal_odyssey/widgets/user_card.dart';
import 'package:vocal_odyssey/widgets/my_text_field.dart';
import '../../providers/user_provider.dart';
import '../../services/admin_service.dart';
import '../../utils/functions.dart';

class ManageUsersScreen extends StatefulWidget {
  ManageUsersScreen({super.key});

  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<Supervisor> users;
  List<Supervisor> filteredUsers = [];
  bool _isLoading = true;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _getUsers();
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _getUsers() async {
    final userProvider = Provider.of<UserProvider>(context);

    try {
      users = await AdminService.getUsers(userProvider.token!);
      filteredUsers = users;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load users.");
    }
  }

  Future<bool> _removeUser(String userId) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete User',
      message: 'Are you sure you want to delete this user?',
      confirmText: 'Delete',
    );

    if (confirmed != true) return false;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await AdminService.deleteUser(userId, userProvider.token!);
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to delete users.");
    }

    return false;
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users
          .where((user) =>
              user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffoldLayout(
      appBar: MyAppBar(title: 'Manage Users'),
      children: [
        MyTextField(
          hintText: 'Search by name or email...',
          controller: _searchController,
          icon: Icons.search,
          inputType: TextInputType.text,
        ),
        SizedBox(height: 10),
        _isLoading
            ? SizedBox(
                height: 200,
                child: buildLoadingIndicator(text: "Loading users"),
              )
            : users.isEmpty
            ? SizedBox(
                height: 200,
                child: Center(child: Text('No user found.')),
              )
            : Column(
                children: [
                  ...filteredUsers.map((user) {
                    return UserCard(
                      name: user.name,
                      email: user.email,
                      onDeletePress: () async {
                        final isDeleted = await _removeUser(user.id);

                        if (isDeleted) {
                          setState(() {
                            users.remove(user);
                            filteredUsers = users;
                          });
                        }
                      },
                    );
                  }),
                ],
              ),
      ],
    );
  }
}
