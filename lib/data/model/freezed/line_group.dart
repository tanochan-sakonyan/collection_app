import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mr_collection/data/model/freezed/line_group_member.dart';

part 'line_group.freezed.dart';
part 'line_group.g.dart';

@freezed
class LineGroup with _$LineGroup {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory LineGroup({
    required String groupId,
    required String groupName,
    // required DateTime fetchedAt, // TOD: 規約対応
    required List<LineGroupMember> members,
  }) = _LineGroup;

  factory LineGroup.fromJson(Map<String, dynamic> json) =>
      _$LineGroupFromJson(json);
}
