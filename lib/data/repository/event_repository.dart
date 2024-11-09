import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mr_collection/data/model/freezed/event.dart';

class EventRepository {
  final String baseUrl;

  EventRepository({required this.baseUrl});

  Future<Event> createEvent(String eventName) async {
    final url = Uri.parse('$baseUrl/events');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'eventName': eventName}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Event.fromJson(data);
    } else {
      throw Exception('イベントの作成に失敗しました');
    }
  }

  Future<Event> editEventName(int eventId, String newEventName) async {
    final url = Uri.parse('$baseUrl/events/$eventId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newEventName': newEventName}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Event.fromJson(data);
    } else {
      throw Exception('イベント名の編集に失敗しました');
    }
  }

  Future<void> deleteEvent(List<int> eventIdList) async {
    final url = Uri.parse('$baseUrl/events');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'eventIdList': eventIdList}),
    );

    if (response.statusCode != 200) {
      throw Exception('イベントの削除に失敗しました');
    }
  }
}
