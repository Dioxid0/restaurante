// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'empleado.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Empleado {

 int get idEmpleado; String get nombre; RolEmpleado get rol; String get usuario; String? get turno;
/// Create a copy of Empleado
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmpleadoCopyWith<Empleado> get copyWith => _$EmpleadoCopyWithImpl<Empleado>(this as Empleado, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Empleado;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Empleado&&(identical(other.idEmpleado, _this.idEmpleado) || other.idEmpleado == _this.idEmpleado)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.rol, _this.rol) || other.rol == _this.rol)&&(identical(other.usuario, _this.usuario) || other.usuario == _this.usuario)&&(identical(other.turno, _this.turno) || other.turno == _this.turno));
}


@override
int get hashCode {
  final _this = this as Empleado;
  return Object.hash(runtimeType,_this.idEmpleado,_this.nombre,_this.rol,_this.usuario,_this.turno);
}

@override
String toString() {
  final _this = this as Empleado;
  return 'Empleado(idEmpleado: ${_this.idEmpleado}, nombre: ${_this.nombre}, rol: ${_this.rol}, usuario: ${_this.usuario}, turno: ${_this.turno})';
}


}

/// @nodoc
abstract mixin class $EmpleadoCopyWith<$Res>  {
  factory $EmpleadoCopyWith(Empleado value, $Res Function(Empleado) _then) = _$EmpleadoCopyWithImpl;
@useResult
$Res call({
 int idEmpleado, String nombre, RolEmpleado rol, String usuario, String? turno
});




}
/// @nodoc
class _$EmpleadoCopyWithImpl<$Res>
    implements $EmpleadoCopyWith<$Res> {
  _$EmpleadoCopyWithImpl(this._self, this._then);

  final Empleado _self;
  final $Res Function(Empleado) _then;

/// Create a copy of Empleado
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idEmpleado = null,Object? nombre = null,Object? rol = null,Object? usuario = null,Object? turno = freezed,}) {
  return _then(Empleado(
idEmpleado: null == idEmpleado ? _self.idEmpleado : idEmpleado // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as RolEmpleado,usuario: null == usuario ? _self.usuario : usuario // ignore: cast_nullable_to_non_nullable
as String,turno: freezed == turno ? _self.turno : turno // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Empleado].
extension EmpleadoPatterns on Empleado {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Empleado value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Empleado() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Empleado value)  $default,){
final _that = this;
switch (_that) {
case _Empleado():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Empleado value)?  $default,){
final _that = this;
switch (_that) {
case _Empleado() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int idEmpleado,  String nombre,  RolEmpleado rol,  String usuario,  String? turno)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Empleado() when $default != null:
return $default(_that.idEmpleado,_that.nombre,_that.rol,_that.usuario,_that.turno);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int idEmpleado,  String nombre,  RolEmpleado rol,  String usuario,  String? turno)  $default,) {final _that = this;
switch (_that) {
case _Empleado():
return $default(_that.idEmpleado,_that.nombre,_that.rol,_that.usuario,_that.turno);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int idEmpleado,  String nombre,  RolEmpleado rol,  String usuario,  String? turno)?  $default,) {final _that = this;
switch (_that) {
case _Empleado() when $default != null:
return $default(_that.idEmpleado,_that.nombre,_that.rol,_that.usuario,_that.turno);case _:
  return null;

}
}

}

/// @nodoc


class _Empleado implements Empleado {
  const _Empleado({required this.idEmpleado, required this.nombre, required this.rol, required this.usuario, this.turno});
  

@override final  int idEmpleado;
@override final  String nombre;
@override final  RolEmpleado rol;
@override final  String usuario;
@override final  String? turno;

/// Create a copy of Empleado
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmpleadoCopyWith<_Empleado> get copyWith => __$EmpleadoCopyWithImpl<_Empleado>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Empleado&&(identical(other.idEmpleado, idEmpleado) || other.idEmpleado == idEmpleado)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.rol, rol) || other.rol == rol)&&(identical(other.usuario, usuario) || other.usuario == usuario)&&(identical(other.turno, turno) || other.turno == turno));
}


@override
int get hashCode {
    return Object.hash(runtimeType,idEmpleado,nombre,rol,usuario,turno);
}

@override
String toString() {
    return 'Empleado(idEmpleado: $idEmpleado, nombre: $nombre, rol: $rol, usuario: $usuario, turno: $turno)';
}


}

/// @nodoc
abstract mixin class _$EmpleadoCopyWith<$Res> implements $EmpleadoCopyWith<$Res> {
  factory _$EmpleadoCopyWith(_Empleado value, $Res Function(_Empleado) _then) = __$EmpleadoCopyWithImpl;
@override @useResult
$Res call({
 int idEmpleado, String nombre, RolEmpleado rol, String usuario, String? turno
});




}
/// @nodoc
class __$EmpleadoCopyWithImpl<$Res>
    implements _$EmpleadoCopyWith<$Res> {
  __$EmpleadoCopyWithImpl(this._self, this._then);

  final _Empleado _self;
  final $Res Function(_Empleado) _then;

/// Create a copy of Empleado
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idEmpleado = null,Object? nombre = null,Object? rol = null,Object? usuario = null,Object? turno = freezed,}) {
  return _then(_Empleado(
idEmpleado: null == idEmpleado ? _self.idEmpleado : idEmpleado // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as RolEmpleado,usuario: null == usuario ? _self.usuario : usuario // ignore: cast_nullable_to_non_nullable
as String,turno: freezed == turno ? _self.turno : turno // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
