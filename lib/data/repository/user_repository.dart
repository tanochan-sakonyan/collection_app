import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mr_collection/data/model/freezed/user.dart';
import 'package:mr_collection/data/model/freezed/line_group.dart';

class UserRepository {
  final String baseUrl;

  UserRepository({required this.baseUrl});

  // アクセストークンを送って、ユーザー情報を取得する
  Future<User?> registerUser(String accessToken) async {
    debugPrint('registerUser関数が呼ばれました。');
    debugPrint('アクセストークン: $accessToken');
    final url = Uri.parse('$baseUrl/users/test');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
      // body: jsonEncode({'line_token': accessToken}),
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
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

  Future<User?> registerLineUser(String accessToken) async {
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
        final user = User.fromJson(data);
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

  Future<User?> fetchUserById(String userId) async {
    debugPrint('fetchUserById関数が呼ばれました。');
    final url = Uri.parse('$baseUrl/users/$userId');

    final response = await http.get(
      url,
      // headers: {'Content-Type': 'application/json'},
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        final user = User.fromJson(data);
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

  Future<User?> fetchLineUserById(String userId, String lineAccessToken) async {
    debugPrint('fetchLineUserById関数が呼ばれました。');
    final url = Uri.parse('$baseUrl/users/$userId?lineToken=$lineAccessToken');

    final response = await http.get(
      url,
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        final user = User.fromJson(data);
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

  Future<User?> deleteUser(String userId) async {
    debugPrint('deleteUser関数が呼ばれました。ユーザーID: $userId : user_repository.dart');
    final url = Uri.parse('$baseUrl/users/$userId');

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['isSuccessful'] == true) {
        debugPrint('ユーザー削除成功: $data : user_repository.dart');
        return null;
      } else {
        throw Exception('Unexpected response: $data');
      }
    } else if (response.statusCode == 404) {
      final data = jsonDecode(response.body);
      final message = data['message'] ?? 'User not found';
      throw Exception('User not found: $message');
    } else {
      final data = jsonDecode(response.body);
      final message = data['message'] ?? 'Internal Server Error';
      throw Exception(
          'Error deleting user: $message (status code: ${response.statusCode})');
    }
  }

  Future<List<LineGroup>> getLineGroups(String userId) async {
    debugPrint('getLineGroups関数が呼ばれました。');
    final url = Uri.parse('$baseUrl/users/$userId/line-groups');

    final response = await http.get(url);

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final lineGroups = (data['line_groups'] as List)
            .map((g) => LineGroup.fromJson(g))
            .toList();
        return lineGroups;
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

  Future<LineGroup> refreshLineGroupMember(
      String userId, String groupId) async {
    debugPrint('refreshLineGroupMember関数が呼ばれました。');
    final url = Uri.parse('$baseUrl/users/$userId/line-groups/$groupId');

    final response = await http.get(url);

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data['isSuccessful'] != true) {
          throw Exception('API returned isSuccessful = false');
        }
        return LineGroup.fromJson(data);
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
}
