// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cuenta_personal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CuentaPersonal {

 int get idEmpleado; String get nombre; String get usuario; RolUsuario get rol; bool get activo; String? get turno;
/// Create a copy of CuentaPersonal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CuentaPersonalCopyWith<CuentaPersonal> get copyWith => _$CuentaPersonalCopyWithImpl<CuentaPersonal>(this as CuentaPersonal, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CuentaPersonal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CuentaPersonal&&(identical(other.idEmpleado, _this.idEmpleado) || other.idEmpleado == _this.idEmpleado)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.usuario, _this.usuario) || other.usuario == _this.usuario)&&(identical(other.rol, _this.rol) || other.rol == _this.rol)&&(identical(other.activo, _this.activo) || other.activo == _this.activo)&&(identical(other.turno, _this.turno) || other.turno == _this.turno));
}


@override
int get hashCode {
  final _this = this as CuentaPersonal;
  return Object.hash(runtimeType,_this.idEmpleado,_this.nombre,_this.usuario,_this.rol,_this.activo,_this.turno);
}

@override
String toString() {
  final _this = this as CuentaPersonal;
  return 'CuentaPersonal(idEmpleado: ${_this.idEmpleado}, nombre: ${_this.nombre}, usuario: ${_this.usuario}, rol: ${_this.rol}, activo: ${_this.activo}, turno: ${_this.turno})';
}


}

/// @nodoc
abstract mixin class $CuentaPersonalCopyWith<$Res>  {
  factory $CuentaPersonalCopyWith(CuentaPersonal value, $Res Function(CuentaPersonal) _then) = _$CuentaPersonalCopyWithImpl;
@useResult
$Res call({
 int idEmpleado, String nombre, String usuario, RolUsuario rol, bool activo, String? turno
});




}
/// @nodoc
class _$CuentaPersonalCopyWithImpl<$Res>
    implements $CuentaPersonalCopyWith<$Res> {
  _$CuentaPersonalCopyWithImpl(this._self, this._then);

  final CuentaPersonal _self;
  final $Res Function(CuentaPersonal) _then;

/// Create a copy of CuentaPersonal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idEmpleado = null,Object? nombre = null,Object? usuario = null,Object? rol = null,Object? activo = null,Object? turno = freezed,}) {
  return _then(CuentaPersonal(
idEmpleado: null == idEmpleado ? _self.idEmpleado : idEmpleado // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,usuario: null == usuario ? _self.usuario : usuario // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as RolUsuario,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,turno: freezed == turno ? _self.turno : turno // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CuentaPersonal].
extension CuentaPersonalPatterns on CuentaPersonal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CuentaPersonal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CuentaPersonal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CuentaPersonal value)  $default,){
final _that = this;
switch (_that) {
case _CuentaPersonal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CuentaPersonal value)?  $default,){
final _that = this;
switch (_that) {
case _CuentaPersonal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int idEmpleado,  String nombre,  String usuario,  RolUsuario rol,  bool activo,  String? turno)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CuentaPersonal() when $default != null:
return $default(_that.idEmpleado,_that.nombre,_that.usuario,_that.rol,_that.activo,_that.turno);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int idEmpleado,  String nombre,  String usuario,  RolUsuario rol,  bool activo,  String? turno)  $default,) {final _that = this;
switch (_that) {
case _CuentaPersonal():
return $default(_that.idEmpleado,_that.nombre,_that.usuario,_that.rol,_that.activo,_that.turno);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int idEmpleado,  String nombre,  String usuario,  RolUsuario rol,  bool activo,  String? turno)?  $default,) {final _that = this;
switch (_that) {
case _CuentaPersonal() when $default != null:
return $default(_that.idEmpleado,_that.nombre,_that.usuario,_that.rol,_that.activo,_that.turno);case _:
  return null;

}
}

}

/// @nodoc


class _CuentaPersonal implements CuentaPersonal {
  const _CuentaPersonal({required this.idEmpleado, required this.nombre, required this.usuario, required this.rol, required this.activo, this.turno});
  

@override final  int idEmpleado;
@override final  String nombre;
@override final  String usuario;
@override final  RolUsuario rol;
@override final  bool activo;
@override final  String? turno;

/// Create a copy of CuentaPersonal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CuentaPersonalCopyWith<_CuentaPersonal> get copyWith => __$CuentaPersonalCopyWithImpl<_CuentaPersonal>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CuentaPersonal&&(identical(other.idEmpleado, idEmpleado) || other.idEmpleado == idEmpleado)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.usuario, usuario) || other.usuario == usuario)&&(identical(other.rol, rol) || other.rol == rol)&&(identical(other.activo, activo) || other.activo == activo)&&(identical(other.turno, turno) || other.turno == turno));
}


@override
int get hashCode {
    return Object.hash(runtimeType,idEmpleado,nombre,usuario,rol,activo,turno);
}

@override
String toString() {
    return 'CuentaPersonal(idEmpleado: $idEmpleado, nombre: $nombre, usuario: $usuario, rol: $rol, activo: $activo, turno: $turno)';
}


}

/// @nodoc
abstract mixin class _$CuentaPersonalCopyWith<$Res> implements $CuentaPersonalCopyWith<$Res> {
  factory _$CuentaPersonalCopyWith(_CuentaPersonal value, $Res Function(_CuentaPersonal) _then) = __$CuentaPersonalCopyWithImpl;
@override @useResult
$Res call({
 int idEmpleado, String nombre, String usuario, RolUsuario rol, bool activo, String? turno
});




}
/// @nodoc
class __$CuentaPersonalCopyWithImpl<$Res>
    implements _$CuentaPersonalCopyWith<$Res> {
  __$CuentaPersonalCopyWithImpl(this._self, this._then);

  final _CuentaPersonal _self;
  final $Res Function(_CuentaPersonal) _then;

/// Create a copy of CuentaPersonal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idEmpleado = null,Object? nombre = null,Object? usuario = null,Object? rol = null,Object? activo = null,Object? turno = freezed,}) {
  return _then(_CuentaPersonal(
idEmpleado: null == idEmpleado ? _self.idEmpleado : idEmpleado // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,usuario: null == usuario ? _self.usuario : usuario // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as RolUsuario,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,turno: freezed == turno ? _self.turno : turno // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
