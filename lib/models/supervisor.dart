import 'package:vocal_odyssey/models/user.dart';
import 'package:vocal_odyssey/models/child.dart';

class Supervisor extends User {
  final String email;
  List<Child> children;

  Supervisor({
    required String id,
    required String name,
    required this.email,
    this.children = const [],
  }) : super(id, name: name);

  @override
  factory Supervisor.fromMap(Map<String, dynamic> map) {
    return Supervisor(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      children: map['children'] != null
          ? List<Child>.from(map['children'].map((child) => Child.fromMap(child)))
          : [],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'children': children.map((child) => child.toMap()).toList(),
    };
  }
}
