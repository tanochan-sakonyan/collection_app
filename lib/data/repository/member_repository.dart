import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/exception/auth_exception.dart';
import 'package:mr_collection/utils/token_storage.dart';

class MemberRepository {
  final String baseUrl;

  MemberRepository({required this.baseUrl});

  Future<List<Member>> createMembers(
      String userId, String eventId, List<String> newMemberNames) async {
    final url =
        Uri.parse('$baseUrl/users/$userId/events/$eventId/members/bulk');
    final response = await _sendWithAuth(
      (token) => http.post(
        url,
        headers: _headersWithToken(token, json: true),
        body: jsonEncode({'newMemberNames': newMemberNames}),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['isSuccessful'] != true) {
        throw Exception('一括メンバー追加に失敗しました');
      }

      final List<dynamic> membersJson = data['members'] as List<dynamic>;
      return membersJson
          .map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('メンバーの追加に失敗しました');
    }
  }

  Future<Member> updateMemberStatus(
      String userId, String eventId, String memberId, int status) async {
    final url = Uri.parse(
        '$baseUrl/users/$userId/events/$eventId/members/$memberId/status');

    final requestBody = jsonEncode({'status': status});
    final response = await _sendWithAuth((token) {
      final headers = _headersWithToken(token, json: true);
      debugPrint('リクエストURL: $url');
      debugPrint('リクエストヘッダー: $headers');
      debugPrint('リクエストボディ: $requestBody');

      return http.put(
        url,
        headers: headers,
        body: requestBody,
      );
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Member.fromJson(data);
    } else {
      final errorBody = response.body;
      throw Exception(
        'メンバーのステータス更新に失敗しました: '
        'ステータスコード: ${response.statusCode}, '
        'レスポンス: $errorBody',
      );
    }
  }

  Future<List<Member>> inputMembersMoney(String userId, String eventId,
      List<Map<String, dynamic>> membersMoneyList) async {
    debugPrint("Repository内でinputMembersMoney関数が呼ばれました");
    final url =
        Uri.parse('$baseUrl/users/$userId/events/$eventId/members/money-bulk');
    final response = await _sendWithAuth(
      (token) => http.put(
        url,
        headers: _headersWithToken(token, json: true),
        body: jsonEncode({'members': membersMoneyList}),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> membersJson = data['members'] as List<dynamic>;
      return membersJson
          .map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('メンバーの金額入力に失敗しました');
    }
  }

  // メンバーを単体で削除する場合
  Future<bool> deleteMember(
      String userId, String eventId, String memberId) async {
    final url = Uri.parse('$baseUrl/users/$userId/events/$eventId/members');
    final response = await _sendWithAuth(
      (token) => http.delete(
        url,
        headers: _headersWithToken(token, json: true),
        body: jsonEncode({
          'memberIdList': [memberId]
        }),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['isSuccessful'] as bool;
    } else {
      throw Exception(
        'メンバーの削除に失敗しました: '
        'ステータスコード: ${response.statusCode}, ',
      );
    }
  }

  Future<Member> editMemberName(String userId, String eventId, String memberId,
      String newMemberName) async {
    final url =
        Uri.parse('$baseUrl/users/$userId/events/$eventId/members/$memberId');
    final response = await _sendWithAuth(
      (token) => http.put(
        url,
        headers: _headersWithToken(token, json: true),
        body: jsonEncode({'newMemberName': newMemberName}),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Member.fromJson(data);
    } else {
      throw Exception('メンバーの追加に失敗しました');
    }
  }

  // Authorizationヘッダーを付与したヘッダーを組み立てる
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

  // トークン付きでAPIを呼び、期限切れ時はリフレッシュして再送する
  Future<http.Response> _sendWithAuth(
      Future<http.Response> Function(String? accessToken) request) async {
    final refreshToken = await TokenStorage.getRefreshToken();
    var accessToken = await TokenStorage.getAccessToken();

    if (accessToken == null && refreshToken != null) {
      debugPrint('MemberRepository: アクセストークンが未取得のためリフレッシュします。');
      accessToken = await _refreshAccessToken(refreshToken);
    }

    if (accessToken == null) {
      throw const RefreshTokenExpiredException('認証情報が見つかりません');
    }

    final response = await request(accessToken);
    if (response.statusCode != 401 || refreshToken == null) {
      return response;
    }

    final message = _extractMessage(response.body);
    if (message != 'Token has expired!') {
      return response;
    }

    debugPrint('MemberRepository: アクセストークン期限切れを検知。リフレッシュします。');
    final newAccessToken = await _refreshAccessToken(refreshToken);
    if (newAccessToken == null) {
      throw const RefreshTokenExpiredException('リフレッシュトークンが失効しています');
    }

    return request(newAccessToken);
  }

  // リフレッシュトークンからアクセストークンを更新する
  Future<String?> _refreshAccessToken(String refreshToken) async {
    final url = Uri.parse('$baseUrl/auth/refresh');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode != 200) {
      debugPrint('MemberRepository: アクセストークン更新失敗 ${response.statusCode}');
      return null;
    }

    try {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        debugPrint('MemberRepository: 更新レスポンス形式が不正: ${response.body}');
        return null;
      }

      final newAccessToken =
          (data['access_token'] ?? data['accessToken']) as String?;
      final newRefreshToken =
          (data['refresh_token'] ?? data['refreshToken']) as String? ??
              refreshToken;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        debugPrint('MemberRepository: 新しいアクセストークン取得に失敗しました');
        return null;
      }

      await TokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      debugPrint('MemberRepository: リフレッシュトークンでアクセストークンを更新しました。');

      return newAccessToken;
    } catch (e) {
      debugPrint('MemberRepository: 更新レスポンス解析に失敗: $e');
      return null;
    }
  }

  // レスポンスからメッセージを取り出す
  String? _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String) {
          return message;
        }
      }
    } catch (_) {
      // no-op
    }
    return null;
  }
}
