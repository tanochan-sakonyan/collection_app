import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:mr_collection/data/model/freezed/line_group_member.dart';

part 'line_group.freezed.dart';
part 'line_group.g.dart';

@freezed
class LineGroup with _$LineGroup {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory LineGroup({
    required String groupId,
    required String groupName,
    @JsonKey(
      name: 'fetched_at',
      fromJson: _parseHttpDateToJST,
      toJson: _dateToHttpString,)required DateTime? fetchedAt,
    required List<LineGroupMember> members,
  }) = _LineGroup;

  factory LineGroup.fromJson(Map<String, dynamic> json) =>
      _$LineGroupFromJson(json);
}

// HTTP日付（RFC 1123）からDateTimeへの変換
DateTime? _parseHttpDateToJST(String? httpDate) {
  if (httpDate == null) return null;
  try {
    return DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US')
        .parseUtc(httpDate)
        .toLocal();
  } catch (e) {
    debugPrint('日付変換失敗: $httpDate $e');
    return null;
  }
}

// DateTimeからHTTP日付形式
String? _dateToHttpString(DateTime? date) {
  if (date == null) return null;
  return DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US').format(date) + ' GMT';
}