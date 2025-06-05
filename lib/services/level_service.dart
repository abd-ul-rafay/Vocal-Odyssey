import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/level_with_progress.dart';
import '../utils/functions.dart';
import 'api_config.dart';

class LevelService {
  static Future<List<LevelWithProgress>> getLevelsWithProgress(String token, String childId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/levels?childId=$childId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> levelsList = jsonData['levels'] ?? [];

      return levelsList.map((item) => LevelWithProgress.fromMap(item)).toList();
    } else {
      throw Exception(parseError(response));
    }
  }
}