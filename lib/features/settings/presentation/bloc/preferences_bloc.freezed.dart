// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preferences_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PreferencesEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreferencesEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PreferencesEvent()';
}


}

/// @nodoc
class $PreferencesEventCopyWith<$Res>  {
$PreferencesEventCopyWith(PreferencesEvent _, $Res Function(PreferencesEvent) __);
}


/// @nodoc


class PreferencesFetched implements PreferencesEvent {
  const PreferencesFetched();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreferencesFetched);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PreferencesEvent.fetch()';
}


}




/// @nodoc


class PreferencesUpdateRequested implements PreferencesEvent {
  const PreferencesUpdateRequested({required final  List<String> dietaryPreferences, required final  List<String> cookingGoals}): _dietaryPreferences = dietaryPreferences,_cookingGoals = cookingGoals;
  

 final  List<String> _dietaryPreferences;
 List<String> get dietaryPreferences {
  if (_dietaryPreferences is EqualUnmodifiableListView) return _dietaryPreferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dietaryPreferences);
}

 final  List<String> _cookingGoals;
 List<String> get cookingGoals {
  if (_cookingGoals is EqualUnmodifiableListView) return _cookingGoals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cookingGoals);
}


/// Create a copy of PreferencesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreferencesUpdateRequestedCopyWith<PreferencesUpdateRequested> get copyWith => _$PreferencesUpdateRequestedCopyWithImpl<PreferencesUpdateRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreferencesUpdateRequested&&const DeepCollectionEquality().equals(other._dietaryPreferences, _dietaryPreferences)&&const DeepCollectionEquality().equals(other._cookingGoals, _cookingGoals));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dietaryPreferences),const DeepCollectionEquality().hash(_cookingGoals));

@override
String toString() {
  return 'PreferencesEvent.updatePreferences(dietaryPreferences: $dietaryPreferences, cookingGoals: $cookingGoals)';
}


}

/// @nodoc
abstract mixin class $PreferencesUpdateRequestedCopyWith<$Res> implements $PreferencesEventCopyWith<$Res> {
  factory $PreferencesUpdateRequestedCopyWith(PreferencesUpdateRequested value, $Res Function(PreferencesUpdateRequested) _then) = _$PreferencesUpdateRequestedCopyWithImpl;
@useResult
$Res call({
 List<String> dietaryPreferences, List<String> cookingGoals
});




}
/// @nodoc
class _$PreferencesUpdateRequestedCopyWithImpl<$Res>
    implements $PreferencesUpdateRequestedCopyWith<$Res> {
  _$PreferencesUpdateRequestedCopyWithImpl(this._self, this._then);

  final PreferencesUpdateRequested _self;
  final $Res Function(PreferencesUpdateRequested) _then;

/// Create a copy of PreferencesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? dietaryPreferences = null,Object? cookingGoals = null,}) {
  return _then(PreferencesUpdateRequested(
dietaryPreferences: null == dietaryPreferences ? _self._dietaryPreferences : dietaryPreferences // ignore: cast_nullable_to_non_nullable
as List<String>,cookingGoals: null == cookingGoals ? _self._cookingGoals : cookingGoals // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$PreferencesState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreferencesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PreferencesState()';
}


}

/// @nodoc
class $PreferencesStateCopyWith<$Res>  {
$PreferencesStateCopyWith(PreferencesState _, $Res Function(PreferencesState) __);
}


/// @nodoc


class _Initial implements PreferencesState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PreferencesState.initial()';
}


}




/// @nodoc


class _Loading implements PreferencesState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PreferencesState.loading()';
}


}




/// @nodoc


class _Loaded implements PreferencesState {
  const _Loaded({required final  List<String> dietaryPreferences, required final  List<String> cookingGoals}): _dietaryPreferences = dietaryPreferences,_cookingGoals = cookingGoals;
  

 final  List<String> _dietaryPreferences;
 List<String> get dietaryPreferences {
  if (_dietaryPreferences is EqualUnmodifiableListView) return _dietaryPreferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dietaryPreferences);
}

 final  List<String> _cookingGoals;
 List<String> get cookingGoals {
  if (_cookingGoals is EqualUnmodifiableListView) return _cookingGoals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cookingGoals);
}


/// Create a copy of PreferencesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._dietaryPreferences, _dietaryPreferences)&&const DeepCollectionEquality().equals(other._cookingGoals, _cookingGoals));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dietaryPreferences),const DeepCollectionEquality().hash(_cookingGoals));

@override
String toString() {
  return 'PreferencesState.loaded(dietaryPreferences: $dietaryPreferences, cookingGoals: $cookingGoals)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $PreferencesStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<String> dietaryPreferences, List<String> cookingGoals
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of PreferencesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? dietaryPreferences = null,Object? cookingGoals = null,}) {
  return _then(_Loaded(
dietaryPreferences: null == dietaryPreferences ? _self._dietaryPreferences : dietaryPreferences // ignore: cast_nullable_to_non_nullable
as List<String>,cookingGoals: null == cookingGoals ? _self._cookingGoals : cookingGoals // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class _Updating implements PreferencesState {
  const _Updating({required final  List<String> dietaryPreferences, required final  List<String> cookingGoals}): _dietaryPreferences = dietaryPreferences,_cookingGoals = cookingGoals;
  

 final  List<String> _dietaryPreferences;
 List<String> get dietaryPreferences {
  if (_dietaryPreferences is EqualUnmodifiableListView) return _dietaryPreferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dietaryPreferences);
}

 final  List<String> _cookingGoals;
 List<String> get cookingGoals {
  if (_cookingGoals is EqualUnmodifiableListView) return _cookingGoals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cookingGoals);
}


/// Create a copy of PreferencesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatingCopyWith<_Updating> get copyWith => __$UpdatingCopyWithImpl<_Updating>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Updating&&const DeepCollectionEquality().equals(other._dietaryPreferences, _dietaryPreferences)&&const DeepCollectionEquality().equals(other._cookingGoals, _cookingGoals));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dietaryPreferences),const DeepCollectionEquality().hash(_cookingGoals));

@override
String toString() {
  return 'PreferencesState.updating(dietaryPreferences: $dietaryPreferences, cookingGoals: $cookingGoals)';
}


}

/// @nodoc
abstract mixin class _$UpdatingCopyWith<$Res> implements $PreferencesStateCopyWith<$Res> {
  factory _$UpdatingCopyWith(_Updating value, $Res Function(_Updating) _then) = __$UpdatingCopyWithImpl;
@useResult
$Res call({
 List<String> dietaryPreferences, List<String> cookingGoals
});




}
/// @nodoc
class __$UpdatingCopyWithImpl<$Res>
    implements _$UpdatingCopyWith<$Res> {
  __$UpdatingCopyWithImpl(this._self, this._then);

  final _Updating _self;
  final $Res Function(_Updating) _then;

/// Create a copy of PreferencesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? dietaryPreferences = null,Object? cookingGoals = null,}) {
  return _then(_Updating(
dietaryPreferences: null == dietaryPreferences ? _self._dietaryPreferences : dietaryPreferences // ignore: cast_nullable_to_non_nullable
as List<String>,cookingGoals: null == cookingGoals ? _self._cookingGoals : cookingGoals // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class _Error implements PreferencesState {
  const _Error({required this.message, final  List<String>? dietaryPreferences, final  List<String>? cookingGoals}): _dietaryPreferences = dietaryPreferences,_cookingGoals = cookingGoals;
  

 final  String message;
 final  List<String>? _dietaryPreferences;
 List<String>? get dietaryPreferences {
  final value = _dietaryPreferences;
  if (value == null) return null;
  if (_dietaryPreferences is EqualUnmodifiableListView) return _dietaryPreferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _cookingGoals;
 List<String>? get cookingGoals {
  final value = _cookingGoals;
  if (value == null) return null;
  if (_cookingGoals is EqualUnmodifiableListView) return _cookingGoals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of PreferencesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._dietaryPreferences, _dietaryPreferences)&&const DeepCollectionEquality().equals(other._cookingGoals, _cookingGoals));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(_dietaryPreferences),const DeepCollectionEquality().hash(_cookingGoals));

@override
String toString() {
  return 'PreferencesState.error(message: $message, dietaryPreferences: $dietaryPreferences, cookingGoals: $cookingGoals)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $PreferencesStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message, List<String>? dietaryPreferences, List<String>? cookingGoals
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of PreferencesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? dietaryPreferences = freezed,Object? cookingGoals = freezed,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,dietaryPreferences: freezed == dietaryPreferences ? _self._dietaryPreferences : dietaryPreferences // ignore: cast_nullable_to_non_nullable
as List<String>?,cookingGoals: freezed == cookingGoals ? _self._cookingGoals : cookingGoals // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
