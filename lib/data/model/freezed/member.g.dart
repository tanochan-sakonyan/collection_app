// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberImpl _$$MemberImplFromJson(Map<String, dynamic> json) => _$MemberImpl(
      memberId: (json['memberId'] as num).toInt(),
      memberName: json['memberName'] as String,
      lineUserId: (json['lineUserId'] as num?)?.toInt(),
      status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$$MemberImplToJson(_$MemberImpl instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'memberName': instance.memberName,
      'lineUserId': instance.lineUserId,
      'status': _$PaymentStatusEnumMap[instance.status]!,
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 'paid',
  PaymentStatus.unpaid: 'unpaid',
  PaymentStatus.absence: 'absence',
};
