import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/utils/authenticated_request.dart';

class MemberRepository {
  final String baseUrl;
  final AuthenticatedRequestHelper _authHelper;

  MemberRepository({required this.baseUrl})
      : _authHelper = AuthenticatedRequestHelper(
          baseUrl: baseUrl,
          contextLabel: 'MemberRepository',
        );

  Future<List<Member>> createMembers(
      String userId, String eventId, List<String> newMemberNames) async {
    final url =
        Uri.parse('$baseUrl/users/$userId/events/$eventId/members/bulk');
    final response = await _authHelper.sendWithAuth(
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
    final response = await _authHelper.sendWithAuth((token) {
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
    final response = await _authHelper.sendWithAuth(
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
    return deleteMembers(userId, eventId, [memberId]);
  }

  Future<bool> deleteMembers(
      String userId, String eventId, List<String> memberIds) async {
    final url = Uri.parse('$baseUrl/users/$userId/events/$eventId/members');
    final response = await _authHelper.sendWithAuth(
      (token) => http.delete(
        url,
        headers: _headersWithToken(token, json: true),
        body: jsonEncode({
          'memberIdList': memberIds,
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
    final response = await _authHelper.sendWithAuth(
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
}
