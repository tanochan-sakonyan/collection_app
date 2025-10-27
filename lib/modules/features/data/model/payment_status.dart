import 'package:freezed_annotation/freezed_annotation.dart';

enum PaymentStatus {
  @JsonValue(1)
  paid,
  @JsonValue(2)
  unpaid,
  @JsonValue(3)
  absence,
  @JsonValue(4)
  paypay,
}
