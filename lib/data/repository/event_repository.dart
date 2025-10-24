import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mr_collection/data/exception/auth_exception.dart';
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/line_group_member.dart';
import 'package:mr_collection/utils/token_storage.dart';

class EventRepository {
  final String baseUrl;

  EventRepository({required this.baseUrl});

  Future<Event> createEvent(String eventName, String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/events');
    final refreshToken = await TokenStorage.getRefreshToken();
    var accessToken = await TokenStorage.getAccessToken();

    if (accessToken == null && refreshToken != null) {
      accessToken = await _refreshAccessToken(refreshToken);
    }

    if (accessToken == null) {
      throw const RefreshTokenExpiredException('認証情報が見つかりません');
    }

    final response = await _postEvent(
      url: url,
      accessToken: accessToken,
      eventName: eventName,
      userId: userId,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('イベントの作成に成功しました。');
      final data = jsonDecode(response.body);
      return Event.fromJson(data);
    }

    if (response.statusCode == 401) {
      final message = _extractMessage(response.body);
      if (message == 'Token has expired!') {
        if (refreshToken == null) {
          throw const RefreshTokenExpiredException('リフレッシュトークンが存在しません');
        }

        final newAccessToken = await _refreshAccessToken(refreshToken);
        if (newAccessToken == null) {
          throw const RefreshTokenExpiredException('リフレッシュトークンが失効しています');
        }

        final retryResponse = await _postEvent(
          url: url,
          accessToken: newAccessToken,
          eventName: eventName,
          userId: userId,
        );

        if (retryResponse.statusCode == 200 ||
            retryResponse.statusCode == 201) {
          final retryData = jsonDecode(retryResponse.body);
          return Event.fromJson(retryData);
        }
      }
    }

    throw Exception('イベントの作成に失敗しました');
  }

  Future<Event> editEventName(
      String userId, String eventId, String newEventName) async {
    final url = Uri.parse('$baseUrl/users/$userId/events/$eventId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newEventName': newEventName}),
    );

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
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fromEventId': eventId, 'eventName': eventName}),
    );

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
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'groupId': groupId,
        'eventName': eventName,
        'members': membersJson,
      }),
    );

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
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'totalMoney': totalMoney}),
    );

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
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'eventIdList': [eventId]
      }),
    );

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

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

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
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'memo': memo}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('noteの追加に成功しました。 : event_repository');
      final data = jsonDecode(response.body);
      return Event.fromJson(data);
    } else {
      throw Exception('noteの追加に失敗しました');
    }
  }

  Future<http.Response> _postEvent({
    required Uri url,
    required String accessToken,
    required String eventName,
    required String userId,
  }) {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final body = jsonEncode({'eventName': eventName, 'userId': userId});

    return http.post(url, headers: headers, body: body);
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    final url = Uri.parse('$baseUrl/auth/refresh');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode != 200) {
      debugPrint('アクセストークンの更新に失敗しました: ${response.statusCode}');
      return null;
    }

    try {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        debugPrint('アクセストークン更新レスポンスの形式が不正です: ${response.body}');
        return null;
      }

      final newAccessToken =
          _readToken(data, 'access_token') ?? _readToken(data, 'accessToken');
      final newRefreshToken = _readToken(data, 'refresh_token') ??
          _readToken(data, 'refreshToken') ??
          refreshToken;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        debugPrint('新しいアクセストークンが取得できませんでした');
        return null;
      }

      await TokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      return newAccessToken;
    } catch (e) {
      debugPrint('アクセストークン更新のレスポンス解析に失敗しました: $e');
      return null;
    }
  }

  // BEから401が返ってきたときに、accessTokenが期限切れなのかどうかを、メッセージを切り分けて分析するための関数
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

  String? _readToken(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return null;
  }
}
