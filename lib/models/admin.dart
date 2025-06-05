import 'package:vocal_odyssey/models/user.dart';

class Admin extends User {
  final String email;

  Admin({
    required String id,
    required String name,
    required this.email,
  }) : super(id, name: name);

  @override
  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
    };
  }
}
