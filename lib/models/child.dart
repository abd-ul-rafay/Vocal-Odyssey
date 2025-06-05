import 'package:vocal_odyssey/models/user.dart';

class Child extends User {
  final DateTime dob;
  final String gender;
  final String imagePath;

  Child({
    required String id,
    required String name,
    required this.dob,
    required this.gender,
    required this.imagePath,
  }) : super(id, name: name);

  @override
  factory Child.fromMap(Map<String, dynamic> map) {
    String capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}' : '';

    return Child(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      dob: DateTime.parse(map['dob']),
      gender: capitalize(map['gender'] ?? ''),
      imagePath: map['image_path'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'dob': dob.toIso8601String(),
      'gender': gender,
      'image_path': imagePath,
    };
  }
}
