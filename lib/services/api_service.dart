import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL for your API
  final String baseUrl = 'http://192.168.114.192:3000'; // Use this for Android Emulator
  // For iOS simulator, use: 'http://localhost:3000'
  // For real device testing, use your computer's actual IP address

  // Register a new user
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required String phone,
    required String village,
    required String district,
    required String province,
    int? rankId, // Optional, could be set to a default value on server
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'User_Name': username,
          'User_Password': password,
          'User_Phone': phone,
          'User_Village': village,
          'User_District': district,
          'User_Province': province,
          'Rank_ID': 1, // Default to regular user rank (assuming 2 is regular user)
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Login a user
  Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
}
