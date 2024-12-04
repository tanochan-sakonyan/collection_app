import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/constants/base_url.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/repository/member_repository.dart';
import 'package:mr_collection/services/member_service.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(baseUrl: baseUrl);
});

final memberProvider =
    StateNotifierProvider<MemberNotifier, List<Member>>((ref) {
  final memberService = ref.read(memberServiceProvider);
  return MemberNotifier(memberService);
});

final memberServiceProvider = Provider<MemberService>((ref) {
  final memberRepository = ref.read(memberRepositoryProvider);
  return MemberService(memberRepository: memberRepository);
});

class MemberNotifier extends StateNotifier<List<Member>> {
  MemberNotifier(this._memberService) : super([]);

  final MemberService _memberService;

  Future<void> addMember(int? eventId, String newMemberName) async {
    try {
      final newMember = await _memberService.addMember(eventId, newMemberName);
      state = [...state, newMember];
    } catch (e) {
      debugPrint('Error adding member: $e');
    }
  }

  Future<void> editMemberName(
      int eventId, int memberId, String newMemberName) async {
    try {
      final updatedMember =
          await _memberService.editMemberName(eventId, memberId, newMemberName);
      state = state
          .map((member) => member.memberId == memberId ? updatedMember : member)
          .toList();
    } catch (e) {
      debugPrint('Error editing member name: $e');
    }
  }

  Future<void> deleteMember(int eventId, List<int> memberIdList) async {
    try {
      await _memberService.deleteMember(eventId, memberIdList);
      state = state.where((member) => member.memberId != memberIdList).toList();
    } catch (e) {
      debugPrint('Error deleting member: $e');
    }
  }

  Future<void> updateMemberStatus(
      int? eventId, int? memberId, int? newStatus) async {
    try {
      final updatedMember =
          await _memberService.updateMemberStatus(eventId, memberId, newStatus);
      state = state
          .map((member) => member.memberId == memberId ? updatedMember : member)
          .toList();
    } catch (e) {
      debugPrint('Error updating member status: $e');
    }
  }
}
