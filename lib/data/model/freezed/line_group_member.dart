import 'package:freezed_annotation/freezed_annotation.dart';
import 'member.dart';

part 'line_group_member.freezed.dart';
part 'line_group_member.g.dart';

@freezed
class LineGroupMember with _$LineGroupMember {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory LineGroupMember({
    required String memberId,
    required String memberName,
  }) = _LineGroupMember;

  factory LineGroupMember.fromJson(Map<String, dynamic> json) =>
      _$LineGroupMemberFromJson(json);
}
