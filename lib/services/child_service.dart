import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/child.dart';
import '../utils/functions.dart';
import 'api_config.dart';

class ChildService {
  static Future<List<Child>> getChildren(String supervisorId, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/children?supervisorId=$supervisorId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((child) => Child.fromMap(child)).toList();
    } else {
      throw Exception(parseError(response));
    }
  }

  static Future<Child> createChild({
    required String name,
    required String gender,
    required String dob,
    required String imagePath,
    required String supervisorId,
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/children');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'gender': gender,
        'dob': dob,
        'image_path': imagePath,
        'supervisor_id': supervisorId,
      }),
    );

    if (response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return Child.fromMap(jsonData);
    } else {
      throw Exception(parseError(response));
    }
  }

  static Future<Child> updateChild({
    required String childId,
    required String name,
    required String gender,
    required String dob,
    required String imagePath,
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/children/$childId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'gender': gender,
        'dob': dob,
        'image_path': imagePath,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Child.fromMap(jsonData);
    } else {
      throw Exception(parseError(response));
    }
  }

  static Future<void> deleteChild(String childId, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/children/$childId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(parseError(response));
    }
  }
}
