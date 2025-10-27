import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'member.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
class Event with _$Event {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Event({
    required String eventId,
    required String eventName,
    required String? lineGroupId,
    @JsonKey(name: 'fetched_at',
      fromJson: _parseHttpDateToJST,
      toJson: _dateToHttpString,) DateTime? lineMembersFetchedAt,
    required List<Member> members,
    required String? memo,
    int? totalMoney,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
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
