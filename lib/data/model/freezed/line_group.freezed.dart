// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'line_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LineGroup _$LineGroupFromJson(Map<String, dynamic> json) {
  return _LineGroup.fromJson(json);
}

/// @nodoc
mixin _$LineGroup {
  String get groupId => throw _privateConstructorUsedError;
  String get groupName =>
      throw _privateConstructorUsedError; // required DateTime fetchedAt, // TODO: 規約対応
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
  $Res call({String groupId, String groupName, List<LineGroupMember> members});
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
  $Res call({String groupId, String groupName, List<LineGroupMember> members});
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
      required final List<LineGroupMember> members})
      : _members = members;

  factory _$LineGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$LineGroupImplFromJson(json);

  @override
  final String groupId;
  @override
  final String groupName;
// required DateTime fetchedAt, // TODO: 規約対応
  final List<LineGroupMember> _members;
// required DateTime fetchedAt, // TODO: 規約対応
  @override
  List<LineGroupMember> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  @override
  String toString() {
    return 'LineGroup(groupId: $groupId, groupName: $groupName, members: $members)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LineGroupImpl &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            const DeepCollectionEquality().equals(other._members, _members));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, groupId, groupName,
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
      required final List<LineGroupMember> members}) = _$LineGroupImpl;

  factory _LineGroup.fromJson(Map<String, dynamic> json) =
      _$LineGroupImpl.fromJson;

  @override
  String get groupId;
  @override
  String get groupName; // required DateTime fetchedAt, // TODO: 規約対応
  @override
  List<LineGroupMember> get members;

  /// Create a copy of LineGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LineGroupImplCopyWith<_$LineGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
