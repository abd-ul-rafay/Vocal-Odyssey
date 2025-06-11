import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/level_attempt.dart'; // Make sure this import is correct
import '../utils/functions.dart';
import 'api_config.dart';

class AttemptService {
  static Future<LevelAttempt> createAttempt({
    required String token,
    required String progressId,
    required int score,
    required Map<String, int> mistakesCounts,
    required int stars,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/attempts/by-progress/$progressId');

    final body = json.encode({
      'score': score,
      'mistakes_counts': mistakesCounts,
      'stars': stars,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return LevelAttempt.fromMap(jsonData);
    } else {
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('Headers: ${response.headers}');

    throw Exception(parseError(response));
    }
  }
}
