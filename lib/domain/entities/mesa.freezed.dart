// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mesa.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Mesa {

 int get idMesa; int get numeroMesa; int get capacidad; EstadoMesa get estado;
/// Create a copy of Mesa
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MesaCopyWith<Mesa> get copyWith => _$MesaCopyWithImpl<Mesa>(this as Mesa, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Mesa;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Mesa&&(identical(other.idMesa, _this.idMesa) || other.idMesa == _this.idMesa)&&(identical(other.numeroMesa, _this.numeroMesa) || other.numeroMesa == _this.numeroMesa)&&(identical(other.capacidad, _this.capacidad) || other.capacidad == _this.capacidad)&&(identical(other.estado, _this.estado) || other.estado == _this.estado));
}


@override
int get hashCode {
  final _this = this as Mesa;
  return Object.hash(runtimeType,_this.idMesa,_this.numeroMesa,_this.capacidad,_this.estado);
}

@override
String toString() {
  final _this = this as Mesa;
  return 'Mesa(idMesa: ${_this.idMesa}, numeroMesa: ${_this.numeroMesa}, capacidad: ${_this.capacidad}, estado: ${_this.estado})';
}


}

/// @nodoc
abstract mixin class $MesaCopyWith<$Res>  {
  factory $MesaCopyWith(Mesa value, $Res Function(Mesa) _then) = _$MesaCopyWithImpl;
@useResult
$Res call({
 int idMesa, int numeroMesa, int capacidad, EstadoMesa estado
});




}
/// @nodoc
class _$MesaCopyWithImpl<$Res>
    implements $MesaCopyWith<$Res> {
  _$MesaCopyWithImpl(this._self, this._then);

  final Mesa _self;
  final $Res Function(Mesa) _then;

/// Create a copy of Mesa
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idMesa = null,Object? numeroMesa = null,Object? capacidad = null,Object? estado = null,}) {
  return _then(Mesa(
idMesa: null == idMesa ? _self.idMesa : idMesa // ignore: cast_nullable_to_non_nullable
as int,numeroMesa: null == numeroMesa ? _self.numeroMesa : numeroMesa // ignore: cast_nullable_to_non_nullable
as int,capacidad: null == capacidad ? _self.capacidad : capacidad // ignore: cast_nullable_to_non_nullable
as int,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoMesa,
  ));
}

}


/// Adds pattern-matching-related methods to [Mesa].
extension MesaPatterns on Mesa {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Mesa value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Mesa() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Mesa value)  $default,){
final _that = this;
switch (_that) {
case _Mesa():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Mesa value)?  $default,){
final _that = this;
switch (_that) {
case _Mesa() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int idMesa,  int numeroMesa,  int capacidad,  EstadoMesa estado)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Mesa() when $default != null:
return $default(_that.idMesa,_that.numeroMesa,_that.capacidad,_that.estado);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int idMesa,  int numeroMesa,  int capacidad,  EstadoMesa estado)  $default,) {final _that = this;
switch (_that) {
case _Mesa():
return $default(_that.idMesa,_that.numeroMesa,_that.capacidad,_that.estado);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int idMesa,  int numeroMesa,  int capacidad,  EstadoMesa estado)?  $default,) {final _that = this;
switch (_that) {
case _Mesa() when $default != null:
return $default(_that.idMesa,_that.numeroMesa,_that.capacidad,_that.estado);case _:
  return null;

}
}

}

/// @nodoc


class _Mesa extends Mesa {
  const _Mesa({required this.idMesa, required this.numeroMesa, required this.capacidad, required this.estado}): super._();
  

@override final  int idMesa;
@override final  int numeroMesa;
@override final  int capacidad;
@override final  EstadoMesa estado;

/// Create a copy of Mesa
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MesaCopyWith<_Mesa> get copyWith => __$MesaCopyWithImpl<_Mesa>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Mesa&&(identical(other.idMesa, idMesa) || other.idMesa == idMesa)&&(identical(other.numeroMesa, numeroMesa) || other.numeroMesa == numeroMesa)&&(identical(other.capacidad, capacidad) || other.capacidad == capacidad)&&(identical(other.estado, estado) || other.estado == estado));
}


@override
int get hashCode {
    return Object.hash(runtimeType,idMesa,numeroMesa,capacidad,estado);
}

@override
String toString() {
    return 'Mesa(idMesa: $idMesa, numeroMesa: $numeroMesa, capacidad: $capacidad, estado: $estado)';
}


}

/// @nodoc
abstract mixin class _$MesaCopyWith<$Res> implements $MesaCopyWith<$Res> {
  factory _$MesaCopyWith(_Mesa value, $Res Function(_Mesa) _then) = __$MesaCopyWithImpl;
@override @useResult
$Res call({
 int idMesa, int numeroMesa, int capacidad, EstadoMesa estado
});




}
/// @nodoc
class __$MesaCopyWithImpl<$Res>
    implements _$MesaCopyWith<$Res> {
  __$MesaCopyWithImpl(this._self, this._then);

  final _Mesa _self;
  final $Res Function(_Mesa) _then;

/// Create a copy of Mesa
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idMesa = null,Object? numeroMesa = null,Object? capacidad = null,Object? estado = null,}) {
  return _then(_Mesa(
idMesa: null == idMesa ? _self.idMesa : idMesa // ignore: cast_nullable_to_non_nullable
as int,numeroMesa: null == numeroMesa ? _self.numeroMesa : numeroMesa // ignore: cast_nullable_to_non_nullable
as int,capacidad: null == capacidad ? _self.capacidad : capacidad // ignore: cast_nullable_to_non_nullable
as int,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoMesa,
  ));
}


}

// dart format on
