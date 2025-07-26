// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberImpl _$$MemberImplFromJson(Map<String, dynamic> json) => _$MemberImpl(
      memberId: json['member_id'] as String,
      memberName: json['member_name'] as String,
      lineUserId: json['line_user_id'] as String?,
      status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
      memberMoney: (json['member_money'] as num?)?.toInt(),
      role: json['role'] as String?,
    );

Map<String, dynamic> _$$MemberImplToJson(_$MemberImpl instance) =>
    <String, dynamic>{
      'member_id': instance.memberId,
      'member_name': instance.memberName,
      'line_user_id': instance.lineUserId,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'member_money': instance.memberMoney,
      'role': instance.role,
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 1,
  PaymentStatus.unpaid: 2,
  PaymentStatus.absence: 3,
};
