import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'https://ti054a02.agussbn.my.id/api';

  /// Melakukan login, mengembalikan map berisi:
  /// - 'data': Map user dan token jika sukses, null jika gagal
  /// - 'message': String
  /// - 'success': bool
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    print('🔔 [AuthService.login] status: ${response.statusCode}');
    print('🔔 [AuthService.login] body:   ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal menghubungi server: ${response.statusCode}');
    }

    final Map<String, dynamic> body = json.decode(response.body);

    // Standarisasi agar selalu return 'data' dan 'message'
    if (body.containsKey('user') && body.containsKey('access_token')) {
      // Format: {user: {...}, access_token: "...}
      return {
        'success': true,
        'message': 'Login berhasil',
        'data': {
          'user': body['user'],
          'token': body['access_token'],
        },
      };
    } else if (body.containsKey('data') && body['data'] is Map) {
      // Format: {data: {user: {...}, token: "..."}, ...}
      return {
        'success': body['success'] ?? true,
        'message': body['message'] ?? 'Login berhasil',
        'data': body['data'],
      };
    } else {
      return {
        'success': false,
        'message': body['message'] as String? ?? 'Login gagal',
        'data': null,
      };
    }
  }
}
