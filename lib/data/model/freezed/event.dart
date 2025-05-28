import 'package:freezed_annotation/freezed_annotation.dart';
import 'member.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
class Event with _$Event {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Event({
    required String eventId,
    required String eventName,
    required List<Member> members,
    required int totalMoney,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
