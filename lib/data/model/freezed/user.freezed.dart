// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get userId => throw _privateConstructorUsedError;
  String? get appleId => throw _privateConstructorUsedError;
  String? get lineUserId => throw _privateConstructorUsedError;
  String? get paypayUrl => throw _privateConstructorUsedError;
  List<String>? get belongingLineGroupIds => throw _privateConstructorUsedError;
  List<Event> get events => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String userId,
      String? appleId,
      String? lineUserId,
      String? paypayUrl,
      List<String>? belongingLineGroupIds,
      List<Event> events});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? appleId = freezed,
    Object? lineUserId = freezed,
    Object? paypayUrl = freezed,
    Object? belongingLineGroupIds = freezed,
    Object? events = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      appleId: freezed == appleId
          ? _value.appleId
          : appleId // ignore: cast_nullable_to_non_nullable
              as String?,
      lineUserId: freezed == lineUserId
          ? _value.lineUserId
          : lineUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      paypayUrl: freezed == paypayUrl
          ? _value.paypayUrl
          : paypayUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      belongingLineGroupIds: freezed == belongingLineGroupIds
          ? _value.belongingLineGroupIds
          : belongingLineGroupIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as List<Event>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String? appleId,
      String? lineUserId,
      String? paypayUrl,
      List<String>? belongingLineGroupIds,
      List<Event> events});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? appleId = freezed,
    Object? lineUserId = freezed,
    Object? paypayUrl = freezed,
    Object? belongingLineGroupIds = freezed,
    Object? events = null,
  }) {
    return _then(_$UserImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      appleId: freezed == appleId
          ? _value.appleId
          : appleId // ignore: cast_nullable_to_non_nullable
              as String?,
      lineUserId: freezed == lineUserId
          ? _value.lineUserId
          : lineUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      paypayUrl: freezed == paypayUrl
          ? _value.paypayUrl
          : paypayUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      belongingLineGroupIds: freezed == belongingLineGroupIds
          ? _value._belongingLineGroupIds
          : belongingLineGroupIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      events: null == events
          ? _value._events
          : events // ignore: cast_nullable_to_non_nullable
              as List<Event>,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.userId,
      required this.appleId,
      required this.lineUserId,
      required this.paypayUrl,
      required final List<String>? belongingLineGroupIds,
      required final List<Event> events})
      : _belongingLineGroupIds = belongingLineGroupIds,
        _events = events;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String userId;
  @override
  final String? appleId;
  @override
  final String? lineUserId;
  @override
  final String? paypayUrl;
  final List<String>? _belongingLineGroupIds;
  @override
  List<String>? get belongingLineGroupIds {
    final value = _belongingLineGroupIds;
    if (value == null) return null;
    if (_belongingLineGroupIds is EqualUnmodifiableListView)
      return _belongingLineGroupIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Event> _events;
  @override
  List<Event> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  @override
  String toString() {
    return 'User(userId: $userId, appleId: $appleId, lineUserId: $lineUserId, paypayUrl: $paypayUrl, belongingLineGroupIds: $belongingLineGroupIds, events: $events)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.appleId, appleId) || other.appleId == appleId) &&
            (identical(other.lineUserId, lineUserId) ||
                other.lineUserId == lineUserId) &&
            (identical(other.paypayUrl, paypayUrl) ||
                other.paypayUrl == paypayUrl) &&
            const DeepCollectionEquality()
                .equals(other._belongingLineGroupIds, _belongingLineGroupIds) &&
            const DeepCollectionEquality().equals(other._events, _events));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      appleId,
      lineUserId,
      paypayUrl,
      const DeepCollectionEquality().hash(_belongingLineGroupIds),
      const DeepCollectionEquality().hash(_events));

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final String userId,
      required final String? appleId,
      required final String? lineUserId,
      required final String? paypayUrl,
      required final List<String>? belongingLineGroupIds,
      required final List<Event> events}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get userId;
  @override
  String? get appleId;
  @override
  String? get lineUserId;
  @override
  String? get paypayUrl;
  @override
  List<String>? get belongingLineGroupIds;
  @override
  List<Event> get events;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
