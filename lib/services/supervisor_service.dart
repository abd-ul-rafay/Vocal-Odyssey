import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supervisor.dart';
import '../models/user.dart';
import '../utils/functions.dart';
import 'api_config.dart';

class SupervisorService {
  static Future<User> updateSupervisor(String supervisorId, String name, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/supervisor/$supervisorId');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'name': name}),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Supervisor.fromMap(jsonData);
    } else {

      throw Exception(parseError(response));
    }
  }
}
