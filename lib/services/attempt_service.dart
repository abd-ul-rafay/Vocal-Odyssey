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

    // Mongodb don't accept dot as key in map
    Map<String, int> cleanedMistakes = mistakesCounts.map((key, value) {
      String cleanedKey = key.replaceAll('.', '');
      return MapEntry(cleanedKey, value);
    });

    final body = json.encode({
      'score': score,
      'mistakes_counts': cleanedMistakes,
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
