import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin.dart';
import '../models/supervisor.dart';
import '../models/user.dart';
import '../utils/functions.dart';
import 'api_config.dart';

class AuthService {
  static const _userKey = 'LOGGED_USER';
  static const _userTypeKey = 'USER_TYPE';
  static const _tokenKey = 'AUTH_TOKEN';

  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<void> saveUser(User user, String token) async {
    final prefs = await _prefs;

    if (user is Supervisor) {
      prefs.setString(_userTypeKey, 'supervisor');
    } else if (user is Admin) {
      prefs.setString(_userTypeKey, 'admin');
    } else {
      throw Exception('Unknown user type');
    }

    prefs.setString(_userKey, jsonEncode(user.toMap()));
    prefs.setString(_tokenKey, token);
  }

  static Future<void> updateUser(User user) async {
    final prefs = await _prefs;
    prefs.setString(_userKey, jsonEncode(user.toMap()));
  }

  static Future<User?> getUser() async {
    final prefs = await _prefs;
    final userJson = prefs.getString(_userKey);
    final userType = prefs.getString(_userTypeKey);
    if (userJson == null || userType == null) return null;

    final map = jsonDecode(userJson);
    switch (userType) {
      case 'supervisor':
        return Supervisor.fromMap(map);
      case 'admin':
        return Admin.fromMap(map);
      default:
        return null;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_userKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final role = data['user']['role'];

      final user = role == 'admin'
          ? Admin.fromMap(data['user'])
          : Supervisor.fromMap(data['user']);

      return {
        'user': user,
        'token': data['token'],
      };
    } else {
      throw Exception(parseError(response));
    }
  }

  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'user': Supervisor.fromMap(data['user']),
        'token': data['token'],
      };
    } else {
      throw Exception(parseError(response));
    }
  }

  static Future<Map<String, dynamic>> googleSignIn() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email'],
      serverClientId: '386631079585-gtcihm7nn123261ais99d1372n3qb9ga.apps.googleusercontent.com',
    );

    try {
      // Sign out first to force account picker dialog
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Google sign-in aborted');

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) throw Exception('Failed to get ID token');

      final url = Uri.parse('${ApiConfig.baseUrl}/auth/google-signin');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = Supervisor.fromMap(data['user']);
        final token = data['token'];

        await saveUser(user, token);
        return {'user': user, 'token': token};
      } else {
        throw Exception(parseError(response));
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> requestPasswordRecovery(String email) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/request-password-recovery');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception(parseError(response));
    }
  }

  static Future<void> recoverPassword(String email, String otp, String newPassword) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/recover-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception(parseError(response));
    }
  }
}
