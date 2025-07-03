import 'package:freezed_annotation/freezed_annotation.dart';

part 'line_group_member.freezed.dart';
part 'line_group_member.g.dart';

@freezed
class LineGroupMember with _$LineGroupMember {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory LineGroupMember({
    @JsonKey(name: 'user_id') required String memberId,
    @JsonKey(name: 'display_name') required String memberName,
  }) = _LineGroupMember;

  factory LineGroupMember.fromJson(Map<String, dynamic> json) =>
      _$LineGroupMemberFromJson(json);
}
