// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      userId: (json['userId'] as num).toInt(),
      lineUserId: json['lineUserId'] as String,
      email: json['email'] as String,
      isConnected: json['isConnected'] as bool,
      events: (json['events'] as List<dynamic>)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'lineUserId': instance.lineUserId,
      'email': instance.email,
      'isConnected': instance.isConnected,
      'events': instance.events,
    };
