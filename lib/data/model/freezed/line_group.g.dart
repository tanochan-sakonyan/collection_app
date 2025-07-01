// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LineGroupImpl _$$LineGroupImplFromJson(Map<String, dynamic> json) =>
    _$LineGroupImpl(
      groupId: json['group_id'] as String,
      groupName: json['group_name'] as String,
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
      members: (json['members'] as List<dynamic>)
          .map((e) => LineGroupMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$LineGroupImplToJson(_$LineGroupImpl instance) =>
    <String, dynamic>{
      'group_id': instance.groupId,
      'group_name': instance.groupName,
      'fetched_at': instance.fetchedAt.toIso8601String(),
      'members': instance.members.map((e) => e.toJson()).toList(),
    };
