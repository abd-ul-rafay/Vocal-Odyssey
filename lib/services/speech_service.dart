import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/functions.dart';
import 'api_config.dart';

class SpeechService {
  static Future<http.Response> createSpeech({
    required String token,
    required String text,
    required String voiceId,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/speech/create');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'text': text,
        'voiceId': voiceId,
      }),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      print('Speech API failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception(parseError(response));
    }
  }

  static Future<http.Response> evaluateSpeech({
    required String token,
    required String text,
    required File audioFile,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/speech/evaluate');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['text'] = text
      ..fields['question_info'] = 'u1/q1'
      ..fields['no_mc'] = '1'
      ..files.add(await http.MultipartFile.fromPath(
        'user_audio_file',
        audioFile.path,
        contentType: MediaType('audio', 'wav'),
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return response;
    } else {
      print('EvaluateSpeech API failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception(parseError(response));
    }
  }
}