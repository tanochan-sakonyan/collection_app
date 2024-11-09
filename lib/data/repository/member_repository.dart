import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mr_collection/data/model/freezed/member.dart';

class MemberRepository {
  final String baseUrl;

  MemberRepository({required this.baseUrl});

  Future<Member> addMember(int eventId, String newMemberName) async {
    final url = Uri.parse('$baseUrl/events/$eventId/members');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newMemberName': newMemberName}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Member.fromJson(data);
    } else {
      throw Exception('メンバーの追加に失敗しました');
    }
  }

  Future<Member> editMemberName(
      int eventId, int memberId, String newMemberName) async {
    final url = Uri.parse('$baseUrl/events/$eventId/members/$memberId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newMemberName': newMemberName}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Member.fromJson(data);
    } else {
      throw Exception('メンバー名の編集に失敗しました');
    }
  }

  Future<void> deleteMember(int eventId, int memberId) async {
    final url = Uri.parse('$baseUrl/events/$eventId/members/$memberId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('メンバーの削除に失敗しました');
    }
  }

  Future<Member> updateMemberStatus(
      int eventId, int memberId, int status) async {
    final url = Uri.parse('$baseUrl/events/$eventId/members/$memberId/status');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Member.fromJson(data);
    } else {
      throw Exception('メンバーのステータス更新に失敗しました');
    }
  }
}
