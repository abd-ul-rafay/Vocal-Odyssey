import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vocal_odyssey/models/level.dart';
import 'package:vocal_odyssey/models/supervisor.dart';
import '../utils/functions.dart';
import 'api_config.dart';
import '../utils/enums.dart';

class AdminService {
  static Future<List<Supervisor>> getUsers(String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/admin/users');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((sup) => Supervisor.fromMap(sup)).toList();
    } else {
      throw Exception(parseError(response));
    }
  }

  static Future<void> deleteUser(String userId, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId');

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

  static Future<List<Level>> getLevels(String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/levels');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((level) => Level.fromMap(level)).toList();
    } else {
      throw Exception(parseError(response));
    }
  }

  static Future<Level> createLevel({
    required String name,
    required String description,
    required int idealTime,
    required ContentType type,
    required List<String> content,
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/levels');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'description': description,
        'ideal_time': idealTime,
        'level_type': type.name,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return Level.fromMap(jsonData);
    } else {
      print('-----------');
      print(response.statusCode);
      throw Exception(parseError(response));
    }
  }

  static Future<Level> updateLevel({
    required String levelId,
    required String name,
    required String description,
    required int idealTime,
    required ContentType type,
    required List<String> content,
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/levels/$levelId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'description': description,
        'ideal_time': idealTime,
        'level_type': type.name,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Level.fromMap(jsonData);
    } else {
      print('-----------');
      print(response.statusCode);
      throw Exception(parseError(response));
    }
  }

  static Future<void> deleteLevel(String levelId, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/levels/$levelId');

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
