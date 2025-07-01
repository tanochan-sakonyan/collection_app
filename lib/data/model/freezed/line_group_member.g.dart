// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_group_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LineGroupMemberImpl _$$LineGroupMemberImplFromJson(
        Map<String, dynamic> json) =>
    _$LineGroupMemberImpl(
      memberId: json['user_id'] as String,
      memberName: json['display_name'] as String,
    );

Map<String, dynamic> _$$LineGroupMemberImplToJson(
        _$LineGroupMemberImpl instance) =>
    <String, dynamic>{
      'user_id': instance.memberId,
      'display_name': instance.memberName,
    };
