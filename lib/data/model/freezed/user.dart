import 'package:freezed_annotation/freezed_annotation.dart';
import 'event.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory User({
    required String userId,
    required String? appleId,
    required String? lineUserId,
    required String? paypayUrl,
    required List<String>? belongingLineGroupIds,
    required List<Event> events,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
