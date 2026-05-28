import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory_apps/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<bool> login(
    String username,
    String password,
  ) async {
    final url = "${ApiConfig.baseUrl}/login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data['data']['token'];
        final name = data['data']['user']['name'];

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          'token',
          'Bearer $token',
        );

        await prefs.setString(
          'name',
          name,
        );

        return true;
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('name');
  }
}