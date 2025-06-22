import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'https://ti054a01.agussbn.my.id/api';

  /// Melakukan login, mengembalikan map berisi:
  /// - 'role'   : int? (null jika gagal)
  /// - 'token'  : String? (access token, null jika gagal)
  /// - 'message': String
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    // Debug: lihat status & body
    print('🔔 [AuthService.login] status: ${response.statusCode}');
    print('🔔 [AuthService.login] body:   ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal menghubungi server: ${response.statusCode}');
    }

    final Map<String, dynamic> body = json.decode(response.body);

    // Jika ada field 'user' dan 'access_token', anggap login sukses
    if (body.containsKey('user') && body.containsKey('access_token')) {
      final user = body['user'] as Map<String, dynamic>;
      final int role = user['role'] as int;
      final String token = body['access_token'] as String;

      return {
        'role': role,
        'token': token,
        'message': 'Login berhasil',
      };
    } else {
      // Kalau formatnya tidak sesuai atau user/token tidak ada
      return {
        'role': null,
        'token': null,
        'message': body['message'] as String? ?? 'Login gagal',
      };
    }
  }
}
