import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mr_collection/data/model/freezed/event.dart';
import 'package:mr_collection/data/model/freezed/lineGroup.dart';
import 'package:mr_collection/data/model/freezed/member.dart';

class EventRepository {
  final String baseUrl;

  EventRepository({required this.baseUrl});

  Future<Event> createEvent(String eventName, String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/events');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'eventName': eventName, 'userId': userId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('イベントの作成に成功しました。');
      final data = jsonDecode(response.body);
      return Event.fromJson(data);
    } else {
      throw Exception('イベントの作成に失敗しました');
    }
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
  Future<Event> createEventAndGetMembersFromLine(
      String groupId, String eventName, List<LineGroupMember> members,String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/line-groups');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'groupId': groupId, 'eventName': eventName, 'members': members}),
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

  Future<Event> addNote(String userId, String eventId, String memo) async {
    final url = Uri.parse('$baseUrl/users/$userId/events/$eventId/memo');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'memo': memo}),
    );

    debugPrint("APIから返ってきたbody: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('noteの追加に成功しました。 : event_repository');
      final data = jsonDecode(response.body);
      return Event.fromJson(data);
    } else {
      throw Exception('イベントの作成に失敗しました');
    }
  }

}
