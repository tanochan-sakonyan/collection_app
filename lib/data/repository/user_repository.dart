import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mr_collection/data/model/freezed/user.dart';

class UserRepository {
  final String baseUrl;

  UserRepository({required this.baseUrl});

  // アクセストークンを送って、ユーザー情報を取得する
  Future<User?> registerUser(String accessToken) async {
    debugPrint('fetchUser関数が呼ばれました。');
    final url = Uri.parse('$baseUrl/users');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'line_token': accessToken}),
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        debugPrint('デコード成功: $data');

        final user = User.fromJson(data);
        debugPrint('User.fromJson成功: $user');
        return user;
      } catch (e, stackTrace) {
        debugPrint('JSONデコード中にエラー: $e');
        debugPrint('スタックトレース: $stackTrace');
        rethrow;
      }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'ユーザー情報の取得に失敗しました';
        throw Exception(
            'エラー: $errorMessage (ステータスコード: ${response.statusCode})');
      } catch (e) {
        throw Exception(
            'その他のエラー：ユーザー情報の取得に失敗しました (ステータスコード: ${response.statusCode})');
      }
    }
  }

  Future<User> sendPaypayLink(String? userId, String paypayLink) async {
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

  Future<User> changeStatus(int? eventId, String memberId, int? status) async {
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
