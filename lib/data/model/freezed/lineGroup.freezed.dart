// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lineGroup.dart';

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
  String get memberId => throw _privateConstructorUsedError;
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
  $Res call({String memberId, String memberName});
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
  $Res call({String memberId, String memberName});
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
      {required this.memberId, required this.memberName});

  factory _$LineGroupMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$LineGroupMemberImplFromJson(json);

  @override
  final String memberId;
  @override
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
      {required final String memberId,
      required final String memberName}) = _$LineGroupMemberImpl;

  factory _LineGroupMember.fromJson(Map<String, dynamic> json) =
      _$LineGroupMemberImpl.fromJson;

  @override
  String get memberId;
  @override
  String get memberName;

  /// Create a copy of LineGroupMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LineGroupMemberImplCopyWith<_$LineGroupMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LineGroup _$LineGroupFromJson(Map<String, dynamic> json) {
  return _LineGroup.fromJson(json);
}

/// @nodoc
mixin _$LineGroup {
  String get groupId => throw _privateConstructorUsedError;
  String get groupName => throw _privateConstructorUsedError;
  DateTime get fetchedAt => throw _privateConstructorUsedError;
  List<LineGroupMember> get members => throw _privateConstructorUsedError;

  /// Serializes this LineGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LineGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LineGroupCopyWith<LineGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LineGroupCopyWith<$Res> {
  factory $LineGroupCopyWith(LineGroup value, $Res Function(LineGroup) then) =
      _$LineGroupCopyWithImpl<$Res, LineGroup>;
  @useResult
  $Res call(
      {String groupId,
      String groupName,
      DateTime fetchedAt,
      List<LineGroupMember> members});
}

/// @nodoc
class _$LineGroupCopyWithImpl<$Res, $Val extends LineGroup>
    implements $LineGroupCopyWith<$Res> {
  _$LineGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LineGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? groupName = null,
    Object? fetchedAt = null,
    Object? members = null,
  }) {
    return _then(_value.copyWith(
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      groupName: null == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String,
      fetchedAt: null == fetchedAt
          ? _value.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      members: null == members
          ? _value.members
          : members // ignore: cast_nullable_to_non_nullable
              as List<LineGroupMember>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LineGroupImplCopyWith<$Res>
    implements $LineGroupCopyWith<$Res> {
  factory _$$LineGroupImplCopyWith(
          _$LineGroupImpl value, $Res Function(_$LineGroupImpl) then) =
      __$$LineGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String groupId,
      String groupName,
      DateTime fetchedAt,
      List<LineGroupMember> members});
}

/// @nodoc
class __$$LineGroupImplCopyWithImpl<$Res>
    extends _$LineGroupCopyWithImpl<$Res, _$LineGroupImpl>
    implements _$$LineGroupImplCopyWith<$Res> {
  __$$LineGroupImplCopyWithImpl(
      _$LineGroupImpl _value, $Res Function(_$LineGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of LineGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? groupName = null,
    Object? fetchedAt = null,
    Object? members = null,
  }) {
    return _then(_$LineGroupImpl(
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      groupName: null == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String,
      fetchedAt: null == fetchedAt
          ? _value.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      members: null == members
          ? _value._members
          : members // ignore: cast_nullable_to_non_nullable
              as List<LineGroupMember>,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _$LineGroupImpl implements _LineGroup {
  const _$LineGroupImpl(
      {required this.groupId,
      required this.groupName,
      required this.fetchedAt,
      required final List<LineGroupMember> members})
      : _members = members;

  factory _$LineGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$LineGroupImplFromJson(json);

  @override
  final String groupId;
  @override
  final String groupName;
  @override
  final DateTime fetchedAt;
  final List<LineGroupMember> _members;
  @override
  List<LineGroupMember> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  @override
  String toString() {
    return 'LineGroup(groupId: $groupId, groupName: $groupName, fetchedAt: $fetchedAt, members: $members)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LineGroupImpl &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt) &&
            const DeepCollectionEquality().equals(other._members, _members));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, groupId, groupName, fetchedAt,
      const DeepCollectionEquality().hash(_members));

  /// Create a copy of LineGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LineGroupImplCopyWith<_$LineGroupImpl> get copyWith =>
      __$$LineGroupImplCopyWithImpl<_$LineGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LineGroupImplToJson(
      this,
    );
  }
}

abstract class _LineGroup implements LineGroup {
  const factory _LineGroup(
      {required final String groupId,
      required final String groupName,
      required final DateTime fetchedAt,
      required final List<LineGroupMember> members}) = _$LineGroupImpl;

  factory _LineGroup.fromJson(Map<String, dynamic> json) =
      _$LineGroupImpl.fromJson;

  @override
  String get groupId;
  @override
  String get groupName;
  @override
  DateTime get fetchedAt;
  @override
  List<LineGroupMember> get members;

  /// Create a copy of LineGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LineGroupImplCopyWith<_$LineGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
