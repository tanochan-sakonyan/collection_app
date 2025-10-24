import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/line_group_member.dart';
import 'package:mr_collection/utils/authenticated_request.dart';

class EventRepository {
  final String baseUrl;
  final AuthenticatedRequestHelper _authHelper;

  EventRepository({required this.baseUrl})
      : _authHelper = AuthenticatedRequestHelper(
          baseUrl: baseUrl,
          contextLabel: 'EventRepository',
        );

  Future<Event> createEvent(String eventName, String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/events');
    final response = await _authHelper.sendWithAuth((token) {
      return _postEvent(
        url: url,
        accessToken: token,
        eventName: eventName,
        userId: userId,
      );
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('イベントの作成に成功しました。');
      final data = jsonDecode(response.body);
      return Event.fromJson(data);
    }

    throw Exception('イベントの作成に失敗しました');
  }

  Future<Event> editEventName(
      String userId, String eventId, String newEventName) async {
    final url = Uri.parse('$baseUrl/users/$userId/events/$eventId');
    final response = await _authHelper.sendWithAuth((token) {
      return http.put(
        url,
        headers: _headersWithToken(token),
        body: jsonEncode({'newEventName': newEventName}),
      );
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('イベント名の更新に成功しました。');
      final data = jsonDecode(response.body);
      return Event.fromJson(data);
    } else {
      throw Exception('イベント名の更新に失敗しました');
    }
  }

  Future<Event> createEventAndTransferMembers(
      String eventId, String eventName, String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/events/clone');
    final response = await _authHelper.sendWithAuth((token) {
      return http.post(
        url,
        headers: _headersWithToken(token),
        body: jsonEncode({'fromEventId': eventId, 'eventName': eventName}),
      );
    });

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      final msg = data['message'] as String? ?? 'Unknown error';
      throw Exception('イベント作成に失敗しました (HTTP ${response.statusCode}): $msg');
    }

    if (data['isSuccessful'] != true) {
      final msg = data['message'] as String? ?? 'Unknown error';
      throw Exception('イベント作成に失敗しました: $msg');
    }

    return Event.fromJson(data);
  }

  //LINEからメンバー取得した際に使うイベント作成API
  Future<Event> createEventAndGetMembersFromLine(String userId, String groupId,
      String eventName, List<LineGroupMember> members) async {
    final List<Map<String, dynamic>> membersJson = members
        .map((m) => {
              'memberId': m.memberId,
              'memberName': m.memberName,
            })
        .toList();

    final url = Uri.parse('$baseUrl/users/$userId/line-groups');
    final response = await _authHelper.sendWithAuth((token) {
      return http.post(
        url,
        headers: _headersWithToken(token),
        body: jsonEncode({
          'groupId': groupId,
          'eventName': eventName,
          'members': membersJson,
        }),
      );
    });

    debugPrint('createEventAndGetMembersFromLine レスポンス: ${response.body}');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 && response.statusCode != 201) {
      final msg = data['message'] as String? ?? 'Unknown error';
      throw Exception(
          'LINEグループからのメンバー自動追加に失敗しました (HTTP ${response.statusCode}): $msg');
    }

    if (data['isSuccessful'] != true) {
      final msg = data['message'] as String? ?? 'Unknown error';
      throw Exception('LINEグループからのメンバー自動追加に失敗しました: $msg');
    }

    return Event.fromJson(data);
  }

  Future<Event> inputTotalMoney(
      String userId, String eventId, int totalMoney) async {
    debugPrint("Repository内でinputTotalMoney関数が呼ばれました。");
    final url = Uri.parse('$baseUrl/users/$userId/events/$eventId/money');
    final response = await _authHelper.sendWithAuth((token) {
      return http.put(
        url,
        headers: _headersWithToken(token),
        body: jsonEncode({'totalMoney': totalMoney}),
      );
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('イベントの合計金額の入力に成功しました。');
      final data = jsonDecode(response.body);
      return Event.fromJson(data);
    } else {
      throw Exception('イベントの合計金額の入力に失敗しました');
    }
  }

  Future<Map<String, bool>> deleteEvent(String userId, String eventId) async {
    final url = Uri.parse('$baseUrl/users/$userId/events');
    final response = await _authHelper.sendWithAuth((token) {
      return http.delete(
        url,
        headers: _headersWithToken(token),
        body: jsonEncode({
          'eventIdList': [eventId]
        }),
      );
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('イベントの削除に成功しました。');
      final data = jsonDecode(response.body);
      debugPrint('data: $data');
      return Map<String, bool>.from(data);
    } else {
      throw Exception('イベントの削除に失敗しました');
    }
  }

  Future<bool> sendMessage(
      String userId, String eventId, String message) async {
    final url = Uri.parse('$baseUrl/users/$userId/events/$eventId/message');
    final response = await _authHelper.sendWithAuth((token) {
      return http.post(
        url,
        headers: _headersWithToken(token),
        body: jsonEncode({'message': message}),
      );
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['isSuccessful'] as bool? ?? false;
    } else {
      debugPrint('メッセージ送信に失敗しました: ${response.statusCode}');
      throw Exception('メッセージ送信に失敗しました');
    }
  }

  Future<Event> addNote(String userId, String eventId, String memo) async {
    final url = Uri.parse('$baseUrl/users/$userId/events/$eventId/memo');
    final response = await _authHelper.sendWithAuth((token) {
      return http.put(
        url,
        headers: _headersWithToken(token),
        body: jsonEncode({'memo': memo}),
      );
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('noteの追加に成功しました。 : event_repository');
      final data = jsonDecode(response.body);
      return Event.fromJson(data);
    } else {
      throw Exception('noteの追加に失敗しました');
    }
  }

  // トークンを付けてイベント作成リクエストを投げる
  Future<http.Response> _postEvent({
    required Uri url,
    required String? accessToken,
    required String eventName,
    required String userId,
  }) {
    final headers = _headersWithToken(accessToken);
    final body = jsonEncode({'eventName': eventName, 'userId': userId});

    return http.post(url, headers: headers, body: body);
  }

  Map<String, String> _headersWithToken(String? accessToken) {
    final headers = {'Content-Type': 'application/json'};
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }
}
