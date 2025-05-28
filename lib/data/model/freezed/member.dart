import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mr_collection/data/model/payment_status.dart';

part 'member.freezed.dart';
part 'member.g.dart';

@freezed
class Member with _$Member {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Member({
    required String memberId,
    required String memberName,
    String? lineUserId,
    required PaymentStatus status,
    int? memberMoney,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}
