import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/data/repository/member_repository.dart';

class MemberService {
  final MemberRepository memberRepository;

  MemberService({required this.memberRepository});

  Future<Member> addMember(int? eventId, String newMemberName) {
    return memberRepository.addMember(eventId, newMemberName);
  }

  Future<Member> editMemberName(
      int eventId, int memberId, String newMemberName) {
    return memberRepository.editMemberName(eventId, memberId, newMemberName);
  }

  Future<void> deleteMember(int eventId, List<int> memberIdList) async {
    for (int memberId in memberIdList) {
      await memberRepository.deleteMember(eventId, memberId);
    }
  }

  Future<Member> updateMemberStatus(int? eventId, int? memberId, int? status) {
    return memberRepository.updateMemberStatus(eventId, memberId, status);
  }
}
