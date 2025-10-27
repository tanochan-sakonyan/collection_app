import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mr_collection/modules/features/data/model/freezed/user.dart';
import 'package:mr_collection/modules/features/data/model/freezed/line_group.dart';
import 'package:mr_collection/modules/features/utils/token_storage.dart';
import 'package:mr_collection/modules/features/utils/authenticated_request.dart';

class UserRepository {
  final String baseUrl;
  final AuthenticatedRequestHelper _authHelper;

  UserRepository({required this.baseUrl})
      : _authHelper = AuthenticatedRequestHelper(baseUrl: baseUrl);

  // ユーザー情報をBEに登録する
  // TODO: 今後アクセストークンを送る必要はない。
  // LINEのアクセストークンはregisterLineUser関数で
  // AppleのアクセストークンはregisterAppleUser関数で送ってユーザー登録する。
  Future<User?> registerUser(String accessToken) async {
    debugPrint('registerUser関数が呼ばれました。アクセストークン: $accessToken');
    final url = Uri.parse('$baseUrl/users/test');

    final response = await _authHelper.sendWithAuth(
      (token) => http.post(
        url,
        headers: _headersWithToken(token, json: true),
        body: jsonEncode({}),
      ),
      requireAuth: false,
    );

    debugPrint('ステータスコード: ${response.statusCode}');
    debugPrint('レスポンスボディ: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        await _persistTokensFromResponse(data);
        final user = User.fromJson(_extractUserData(data));
        return user;
      } catch (e, stackTrace) {
        debugPrint('JSONデコード中にエラー: $e');
        debugPrint('スタックトレース: $stackTrace');
        rethrow;
      }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'ユーザーの登録に失敗しました';
        throw Exception(
            'エラー: $errorMessage (ステータスコード: ${response.statusCode})');
      } catch (e) {
        throw Exception(
            'その他のエラー：ユーザーの登録に失敗しました (ステータスコード: ${response.statusCode})');
      }
    }
  }

  Future<User?> registerLineUser(String accessToken) async {
    final url = Uri.parse('$baseUrl/users');

    final response = await _authHelper.sendWithAuth(
      (token) => http.post(
        url,
        headers: _headersWithToken(token, json: true),
        body: jsonEncode({'line_token': accessToken}),
      ),
      requireAuth: false,
    );

    debugPrint('ステータスコード: ${response.statusCode}');
    debugPrint('レスポンスボディ: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        await _persistTokensFromResponse(data);
        final user = User.fromJson(_extractUserData(data));
        return user;
      } catch (e, stackTrace) {
        debugPrint('JSONデコード中にエラー: $e');
        debugPrint('スタックトレース: $stackTrace');
        rethrow;
      }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'ユーザー情報の登録(LINE利用)に失敗しました';
        throw Exception(
            'エラー: $errorMessage (ステータスコード: ${response.statusCode})');
      } catch (e) {
        throw Exception(
            'その他のエラー：ユーザー情報の登録(LINE利用)に失敗しました (ステータスコード: ${response.statusCode}),エラー：$e');
      }
    }
  }

  // TODO: 今後はfetchLineUserByIdとfetchAppleUserByIdで運用する。
  Future<User?> fetchUserById(String userId) async {
    debugPrint('fetchUserById関数が呼ばれました。');
    final url = Uri.parse('$baseUrl/users/$userId');

    final response = await _authHelper.sendWithAuth(
      (token) => http.get(
        url,
        headers: _headersWithToken(token),
      ),
      requireAuth: false,
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        await _persistTokensFromResponse(data);
        final user = User.fromJson(_extractUserData(data));
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

    final response = await _authHelper.sendWithAuth(
      (token) => http.get(
        url,
        headers: _headersWithToken(token),
      ),
      requireAuth: false,
    );

    debugPrint('ステータスコード: ${response.statusCode}');
    debugPrint('レスポンスボディ: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        await _persistTokensFromResponse(data);
        final user = User.fromJson(_extractUserData(data));
        return user;
      } catch (e, stackTrace) {
        debugPrint('JSONデコード中にエラー: $e');
        debugPrint('スタックトレース: $stackTrace');
        rethrow;
      }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['message'] ?? 'LINE_IDでのユーザー情報の取得に失敗しました';
        throw Exception(
            'エラー: $errorMessage (ステータスコード: ${response.statusCode})');
      } catch (e) {
        throw Exception(
            'その他のエラー：LINE_IDでのユーザー情報の取得に失敗しました (ステータスコード: ${response.statusCode})\n メッセージ：$e');
      }
    }
  }

  Future<User?> deleteUser(String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId');

    final response = await _authHelper.sendWithAuth(
      (token) => http.delete(
        url,
        headers: _headersWithToken(token, json: true),
      ),
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
    final url = Uri.parse('$baseUrl/users/$userId/line-groups');

    final response = await _authHelper.sendWithAuth(
      (token) => http.get(
        url,
        headers: _headersWithToken(token),
      ),
    );

    debugPrint('ステータスコード: ${response.statusCode}');
    debugPrint('レスポンスボディ: ${response.body}');

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

    final response = await _authHelper.sendWithAuth(
      (token) => http.get(
        url,
        headers: _headersWithToken(token),
      ),
    );

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
    final response = await _authHelper.sendWithAuth(
      (token) => http.post(
        url,
        headers: _headersWithToken(token, json: true),
        body: jsonEncode({'paypayLink': paypayLink}),
      ),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('PayPayリンクの送信に失敗しました');
    }
  }

  // Authorizationヘッダーを付与したヘッダーを生成する
  Map<String, String> _headersWithToken(String? accessToken,
      {bool json = false}) {
    final headers = <String, String>{};
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  // ユーザーログイン、登録時に、BEからのレスポンスからaccessTokenとrefreshTokenを見つけて、保存する関数
  Future<void> _persistTokensFromResponse(dynamic data) async {
    if (data is! Map<String, dynamic>) return;

    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;

    if (accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty) {
      await TokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
  }

  Map<String, dynamic> _extractUserData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final events = data['events'];
      return {
        'user_id': data['user_id'],
        'apple_id': data['apple_id'],
        'line_id': data['line_id'],
        'paypay_url': data['paypay_url'],
        'belonging_line_group_ids': data['belonging_line_group_ids'],
        'events': events is List ? events : [],
      };
    }

    throw Exception('ユーザーデータの形式が不正です');
  }
}
