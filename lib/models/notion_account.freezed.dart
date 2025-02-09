// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notion_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotionAccount _$NotionAccountFromJson(Map<String, dynamic> json) {
  return _NotionAccount.fromJson(json);
}

/// @nodoc
mixin _$NotionAccount {
// Notion API アクセストークン
  String get accessToken =>
      throw _privateConstructorUsedError; // ユーザー専用のNotionデータベースID
  String get databaseId => throw _privateConstructorUsedError;

  /// Serializes this NotionAccount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotionAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotionAccountCopyWith<NotionAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotionAccountCopyWith<$Res> {
  factory $NotionAccountCopyWith(
          NotionAccount value, $Res Function(NotionAccount) then) =
      _$NotionAccountCopyWithImpl<$Res, NotionAccount>;
  @useResult
  $Res call({String accessToken, String databaseId});
}

/// @nodoc
class _$NotionAccountCopyWithImpl<$Res, $Val extends NotionAccount>
    implements $NotionAccountCopyWith<$Res> {
  _$NotionAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotionAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? databaseId = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      databaseId: null == databaseId
          ? _value.databaseId
          : databaseId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotionAccountImplCopyWith<$Res>
    implements $NotionAccountCopyWith<$Res> {
  factory _$$NotionAccountImplCopyWith(
          _$NotionAccountImpl value, $Res Function(_$NotionAccountImpl) then) =
      __$$NotionAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String accessToken, String databaseId});
}

/// @nodoc
class __$$NotionAccountImplCopyWithImpl<$Res>
    extends _$NotionAccountCopyWithImpl<$Res, _$NotionAccountImpl>
    implements _$$NotionAccountImplCopyWith<$Res> {
  __$$NotionAccountImplCopyWithImpl(
      _$NotionAccountImpl _value, $Res Function(_$NotionAccountImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotionAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? databaseId = null,
  }) {
    return _then(_$NotionAccountImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      databaseId: null == databaseId
          ? _value.databaseId
          : databaseId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotionAccountImpl implements _NotionAccount {
  _$NotionAccountImpl({required this.accessToken, required this.databaseId});

  factory _$NotionAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotionAccountImplFromJson(json);

// Notion API アクセストークン
  @override
  final String accessToken;
// ユーザー専用のNotionデータベースID
  @override
  final String databaseId;

  @override
  String toString() {
    return 'NotionAccount(accessToken: $accessToken, databaseId: $databaseId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotionAccountImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.databaseId, databaseId) ||
                other.databaseId == databaseId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accessToken, databaseId);

  /// Create a copy of NotionAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotionAccountImplCopyWith<_$NotionAccountImpl> get copyWith =>
      __$$NotionAccountImplCopyWithImpl<_$NotionAccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotionAccountImplToJson(
      this,
    );
  }
}

abstract class _NotionAccount implements NotionAccount {
  factory _NotionAccount(
      {required final String accessToken,
      required final String databaseId}) = _$NotionAccountImpl;

  factory _NotionAccount.fromJson(Map<String, dynamic> json) =
      _$NotionAccountImpl.fromJson;

// Notion API アクセストークン
  @override
  String get accessToken; // ユーザー専用のNotionデータベースID
  @override
  String get databaseId;

  /// Create a copy of NotionAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotionAccountImplCopyWith<_$NotionAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
