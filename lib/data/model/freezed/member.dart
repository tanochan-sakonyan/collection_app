import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mr_collection/data/model/payment_status.dart';

part 'member.freezed.dart';
part 'member.g.dart';

@freezed
class Member with _$Member {
  const factory Member({
    required int memberId,
    required String memberName,
    int? lineUserId,
    required PaymentStatus status,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}
