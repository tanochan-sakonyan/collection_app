import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mr_collection/data/model/freezed/event.dart';

class EventRepository {
  final String baseUrl;

  EventRepository({required this.baseUrl});

  Future<Event> createEvent(String eventName, int userId) async {
    final url = Uri.parse('$baseUrl/events');
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

  Future<Map<String, bool>> deleteEvent(int eventId) async {
    final url = Uri.parse('$baseUrl/events');
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
}
