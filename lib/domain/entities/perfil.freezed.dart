// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'perfil.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Perfil {

/// id_empleado (personal) o id_cliente (cliente).
 int get id; String get nombre; RolUsuario get rol; String? get usuario; String? get correo; String? get turno;
/// Create a copy of Perfil
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerfilCopyWith<Perfil> get copyWith => _$PerfilCopyWithImpl<Perfil>(this as Perfil, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Perfil;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Perfil&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.rol, _this.rol) || other.rol == _this.rol)&&(identical(other.usuario, _this.usuario) || other.usuario == _this.usuario)&&(identical(other.correo, _this.correo) || other.correo == _this.correo)&&(identical(other.turno, _this.turno) || other.turno == _this.turno));
}


@override
int get hashCode {
  final _this = this as Perfil;
  return Object.hash(runtimeType,_this.id,_this.nombre,_this.rol,_this.usuario,_this.correo,_this.turno);
}

@override
String toString() {
  final _this = this as Perfil;
  return 'Perfil(id: ${_this.id}, nombre: ${_this.nombre}, rol: ${_this.rol}, usuario: ${_this.usuario}, correo: ${_this.correo}, turno: ${_this.turno})';
}


}

/// @nodoc
abstract mixin class $PerfilCopyWith<$Res>  {
  factory $PerfilCopyWith(Perfil value, $Res Function(Perfil) _then) = _$PerfilCopyWithImpl;
@useResult
$Res call({
 int id, String nombre, RolUsuario rol, String? usuario, String? correo, String? turno
});




}
/// @nodoc
class _$PerfilCopyWithImpl<$Res>
    implements $PerfilCopyWith<$Res> {
  _$PerfilCopyWithImpl(this._self, this._then);

  final Perfil _self;
  final $Res Function(Perfil) _then;

/// Create a copy of Perfil
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? rol = null,Object? usuario = freezed,Object? correo = freezed,Object? turno = freezed,}) {
  return _then(Perfil(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as RolUsuario,usuario: freezed == usuario ? _self.usuario : usuario // ignore: cast_nullable_to_non_nullable
as String?,correo: freezed == correo ? _self.correo : correo // ignore: cast_nullable_to_non_nullable
as String?,turno: freezed == turno ? _self.turno : turno // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Perfil].
extension PerfilPatterns on Perfil {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Perfil value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Perfil() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Perfil value)  $default,){
final _that = this;
switch (_that) {
case _Perfil():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Perfil value)?  $default,){
final _that = this;
switch (_that) {
case _Perfil() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String nombre,  RolUsuario rol,  String? usuario,  String? correo,  String? turno)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Perfil() when $default != null:
return $default(_that.id,_that.nombre,_that.rol,_that.usuario,_that.correo,_that.turno);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String nombre,  RolUsuario rol,  String? usuario,  String? correo,  String? turno)  $default,) {final _that = this;
switch (_that) {
case _Perfil():
return $default(_that.id,_that.nombre,_that.rol,_that.usuario,_that.correo,_that.turno);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String nombre,  RolUsuario rol,  String? usuario,  String? correo,  String? turno)?  $default,) {final _that = this;
switch (_that) {
case _Perfil() when $default != null:
return $default(_that.id,_that.nombre,_that.rol,_that.usuario,_that.correo,_that.turno);case _:
  return null;

}
}

}

/// @nodoc


class _Perfil implements Perfil {
  const _Perfil({required this.id, required this.nombre, required this.rol, this.usuario, this.correo, this.turno});
  

/// id_empleado (personal) o id_cliente (cliente).
@override final  int id;
@override final  String nombre;
@override final  RolUsuario rol;
@override final  String? usuario;
@override final  String? correo;
@override final  String? turno;

/// Create a copy of Perfil
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerfilCopyWith<_Perfil> get copyWith => __$PerfilCopyWithImpl<_Perfil>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Perfil&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.rol, rol) || other.rol == rol)&&(identical(other.usuario, usuario) || other.usuario == usuario)&&(identical(other.correo, correo) || other.correo == correo)&&(identical(other.turno, turno) || other.turno == turno));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,nombre,rol,usuario,correo,turno);
}

@override
String toString() {
    return 'Perfil(id: $id, nombre: $nombre, rol: $rol, usuario: $usuario, correo: $correo, turno: $turno)';
}


}

/// @nodoc
abstract mixin class _$PerfilCopyWith<$Res> implements $PerfilCopyWith<$Res> {
  factory _$PerfilCopyWith(_Perfil value, $Res Function(_Perfil) _then) = __$PerfilCopyWithImpl;
@override @useResult
$Res call({
 int id, String nombre, RolUsuario rol, String? usuario, String? correo, String? turno
});




}
/// @nodoc
class __$PerfilCopyWithImpl<$Res>
    implements _$PerfilCopyWith<$Res> {
  __$PerfilCopyWithImpl(this._self, this._then);

  final _Perfil _self;
  final $Res Function(_Perfil) _then;

/// Create a copy of Perfil
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? rol = null,Object? usuario = freezed,Object? correo = freezed,Object? turno = freezed,}) {
  return _then(_Perfil(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as RolUsuario,usuario: freezed == usuario ? _self.usuario : usuario // ignore: cast_nullable_to_non_nullable
as String?,correo: freezed == correo ? _self.correo : correo // ignore: cast_nullable_to_non_nullable
as String?,turno: freezed == turno ? _self.turno : turno // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
