// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventImpl _$$EventImplFromJson(Map<String, dynamic> json) => _$EventImpl(
      eventId: json['event_id'] as String,
      eventName: json['event_name'] as String,
      lineGroupId: json['line_group_id'] as String?,
      lineMembersFetchedAt: json['line_members_fetched_at'] == null
          ? null
          : DateTime.parse(json['line_members_fetched_at'] as String),
      members: (json['members'] as List<dynamic>)
          .map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList(),
      memo: json['memo'] as String?,
      totalMoney: (json['total_money'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$EventImplToJson(_$EventImpl instance) =>
    <String, dynamic>{
      'event_id': instance.eventId,
      'event_name': instance.eventName,
      'line_group_id': instance.lineGroupId,
      'line_members_fetched_at':
          instance.lineMembersFetchedAt?.toIso8601String(),
      'members': instance.members.map((e) => e.toJson()).toList(),
      'memo': instance.memo,
      'total_money': instance.totalMoney,
    };
