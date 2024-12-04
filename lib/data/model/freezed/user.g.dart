// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      userId: (json['user_id'] as num).toInt(),
      lineUserId: json['line_user_id'] as String,
      paypayUrl: json['paypay_url'] as String?,
      belongingLineGroupIds:
          (json['belonging_line_group_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      events: (json['events'] as List<dynamic>)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'line_user_id': instance.lineUserId,
      'paypay_url': instance.paypayUrl,
      'belonging_line_group_ids': instance.belongingLineGroupIds,
      'events': instance.events.map((e) => e.toJson()).toList(),
    };
