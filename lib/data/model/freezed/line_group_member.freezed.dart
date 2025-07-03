// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'line_group_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LineGroupMember _$LineGroupMemberFromJson(Map<String, dynamic> json) {
  return _LineGroupMember.fromJson(json);
}

/// @nodoc
mixin _$LineGroupMember {
  @JsonKey(name: 'user_id')
  String get memberId => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String get memberName => throw _privateConstructorUsedError;

  /// Serializes this LineGroupMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LineGroupMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LineGroupMemberCopyWith<LineGroupMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LineGroupMemberCopyWith<$Res> {
  factory $LineGroupMemberCopyWith(
          LineGroupMember value, $Res Function(LineGroupMember) then) =
      _$LineGroupMemberCopyWithImpl<$Res, LineGroupMember>;
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String memberId,
      @JsonKey(name: 'display_name') String memberName});
}

/// @nodoc
class _$LineGroupMemberCopyWithImpl<$Res, $Val extends LineGroupMember>
    implements $LineGroupMemberCopyWith<$Res> {
  _$LineGroupMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LineGroupMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? memberName = null,
  }) {
    return _then(_value.copyWith(
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      memberName: null == memberName
          ? _value.memberName
          : memberName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LineGroupMemberImplCopyWith<$Res>
    implements $LineGroupMemberCopyWith<$Res> {
  factory _$$LineGroupMemberImplCopyWith(_$LineGroupMemberImpl value,
          $Res Function(_$LineGroupMemberImpl) then) =
      __$$LineGroupMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String memberId,
      @JsonKey(name: 'display_name') String memberName});
}

/// @nodoc
class __$$LineGroupMemberImplCopyWithImpl<$Res>
    extends _$LineGroupMemberCopyWithImpl<$Res, _$LineGroupMemberImpl>
    implements _$$LineGroupMemberImplCopyWith<$Res> {
  __$$LineGroupMemberImplCopyWithImpl(
      _$LineGroupMemberImpl _value, $Res Function(_$LineGroupMemberImpl) _then)
      : super(_value, _then);

  /// Create a copy of LineGroupMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? memberName = null,
  }) {
    return _then(_$LineGroupMemberImpl(
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      memberName: null == memberName
          ? _value.memberName
          : memberName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _$LineGroupMemberImpl implements _LineGroupMember {
  const _$LineGroupMemberImpl(
      {@JsonKey(name: 'user_id') required this.memberId,
      @JsonKey(name: 'display_name') required this.memberName});

  factory _$LineGroupMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$LineGroupMemberImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String memberId;
  @override
  @JsonKey(name: 'display_name')
  final String memberName;

  @override
  String toString() {
    return 'LineGroupMember(memberId: $memberId, memberName: $memberName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LineGroupMemberImpl &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.memberName, memberName) ||
                other.memberName == memberName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, memberId, memberName);

  /// Create a copy of LineGroupMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LineGroupMemberImplCopyWith<_$LineGroupMemberImpl> get copyWith =>
      __$$LineGroupMemberImplCopyWithImpl<_$LineGroupMemberImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LineGroupMemberImplToJson(
      this,
    );
  }
}

abstract class _LineGroupMember implements LineGroupMember {
  const factory _LineGroupMember(
          {@JsonKey(name: 'user_id') required final String memberId,
          @JsonKey(name: 'display_name') required final String memberName}) =
      _$LineGroupMemberImpl;

  factory _LineGroupMember.fromJson(Map<String, dynamic> json) =
      _$LineGroupMemberImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get memberId;
  @override
  @JsonKey(name: 'display_name')
  String get memberName;

  /// Create a copy of LineGroupMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LineGroupMemberImplCopyWith<_$LineGroupMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
