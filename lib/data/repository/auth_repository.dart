import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String baseUrl;

  AuthRepository({required this.baseUrl});

  Future<bool> verifyAccessToken(String accessToken) async {
    final url = Uri.parse('$baseUrl/auth/token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'accessToken': accessToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isAuthenticated'] as bool;
    } else {
      throw Exception('トークンの検証に失敗しました');
    }
  }
}
