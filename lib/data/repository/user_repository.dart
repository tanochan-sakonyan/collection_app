import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mr_collection/data/model/freezed/user.dart';

class UserRepository {
  final String baseUrl;

  UserRepository({required this.baseUrl});

  Future<User> registerUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return User.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<User> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('ログインに失敗しました');
    }
  }

  Future<User> sendPaypayLink(String userId, String paypayLink) async {
    final url = Uri.parse('$baseUrl/users/$userId/paypay-link');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'paypayLink': paypayLink}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('PayPayリンクの送信に失敗しました');
    }
  }

  Future<User> changeStatus(String eventId, String memberId, int status) async {
    final url = Uri.parse('$baseUrl/events/$eventId/members/$memberId/status');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('ステータスの更新に失敗しました');
    }
  }
}
