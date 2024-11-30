// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      userId: (json['userId'] as num).toInt(),
      lineToken: json['lineToken'] as String,
      paypayUrl: json['paypayUrl'] as String?,
      belongingLineGroupIds: (json['belongingLineGroupIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      events: (json['events'] as List<dynamic>)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'lineToken': instance.lineToken,
      'paypayUrl': instance.paypayUrl,
      'belongingLineGroupIds': instance.belongingLineGroupIds,
      'events': instance.events,
    };
