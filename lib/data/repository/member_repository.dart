import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mr_collection/data/model/freezed/member.dart';

class MemberRepository {
  final String baseUrl;

  MemberRepository({required this.baseUrl});

  Future<Member> createMember(
      String userId, String eventId, String newMemberName) async {
    final url = Uri.parse('$baseUrl/users/$userId/events/$eventId/members');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newMemberName': newMemberName}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Member.fromJson(data);
    } else {
      throw Exception('メンバーの追加に失敗しました');
    }
  }

  Future<Member> updateMemberStatus(
      String userId, String eventId, String memberId, int status) async {
    final url = Uri.parse(
        '$baseUrl/users/$userId/events/$eventId/members/$memberId/status');

    final requestBody = jsonEncode({'status': status});
    debugPrint('リクエストURL: $url');
    debugPrint('リクエストヘッダー: ${{'Content-Type': 'application/json'}}');
    debugPrint('リクエストボディ: $requestBody');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

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

  // メンバーを単体で削除する場合
  Future<bool> deleteMember(
      String userId, String eventId, String memberId) async {
    final url = Uri.parse('$baseUrl/users/$userId/events/$eventId/members');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'memberIdList': memberId}),
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
}
