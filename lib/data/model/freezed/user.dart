import 'package:freezed_annotation/freezed_annotation.dart';
import 'event.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int userId,
    required String lineUserId,
    required String email,
    required bool isConnected,
    required List<Event> events,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
