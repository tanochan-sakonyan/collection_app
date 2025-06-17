import 'package:freezed_annotation/freezed_annotation.dart';
import 'member.dart';

part 'lineGroup.freezed.dart';
part 'lineGroup.g.dart';

@freezed
class LineGroupMember with _$LineGroupMember {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory LineGroupMember({
    required String member_Id,
    required String member_name,
  }) = _LineGroupMember;

  factory LineGroupMember.fromJson(Map<String, dynamic> json) => _$LineGroupMemberFromJson(json);
}

@freezed
class LineGroup with _$LineGroup {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory LineGroup({
    required String groupId,
    required String groupName,
    required List<LineGroupMember> members,
  }) = _LineGroup;

  factory LineGroup.fromJson(Map<String, dynamic> json) => _$LineGroupFromJson(json);
}
