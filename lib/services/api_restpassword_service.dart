import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL for your API - replace with your actual server address
  static const String baseUrl =
      'http://192.168.114.192:3000'; // For Android emulator
  // Use 'http://localhost:3000' for iOS simulator or update with your server IP

  // Request verification code
  static Future<Map<String, dynamic>> requestVerificationCode(
      String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/request-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Verify code
  static Future<Map<String, dynamic>> verifyCode(
      String phoneNumber, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phoneNumber,
          'code': code,
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

  // Reset password
  static Future<Map<String, dynamic>> resetPassword(
      String phoneNumber, String newPassword, String resetToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phoneNumber,
          'newPassword': newPassword,
          'resetToken': resetToken,
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
