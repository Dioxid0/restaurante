// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservacion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Reservacion {

 int get idReservacion; DateTime get inicio; int get comensales; EstadoReservacion get estado; int get idCliente; String? get nombreCliente; int? get numeroMesa;
/// Create a copy of Reservacion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservacionCopyWith<Reservacion> get copyWith => _$ReservacionCopyWithImpl<Reservacion>(this as Reservacion, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Reservacion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reservacion&&(identical(other.idReservacion, _this.idReservacion) || other.idReservacion == _this.idReservacion)&&(identical(other.inicio, _this.inicio) || other.inicio == _this.inicio)&&(identical(other.comensales, _this.comensales) || other.comensales == _this.comensales)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.idCliente, _this.idCliente) || other.idCliente == _this.idCliente)&&(identical(other.nombreCliente, _this.nombreCliente) || other.nombreCliente == _this.nombreCliente)&&(identical(other.numeroMesa, _this.numeroMesa) || other.numeroMesa == _this.numeroMesa));
}


@override
int get hashCode {
  final _this = this as Reservacion;
  return Object.hash(runtimeType,_this.idReservacion,_this.inicio,_this.comensales,_this.estado,_this.idCliente,_this.nombreCliente,_this.numeroMesa);
}

@override
String toString() {
  final _this = this as Reservacion;
  return 'Reservacion(idReservacion: ${_this.idReservacion}, inicio: ${_this.inicio}, comensales: ${_this.comensales}, estado: ${_this.estado}, idCliente: ${_this.idCliente}, nombreCliente: ${_this.nombreCliente}, numeroMesa: ${_this.numeroMesa})';
}


}

/// @nodoc
abstract mixin class $ReservacionCopyWith<$Res>  {
  factory $ReservacionCopyWith(Reservacion value, $Res Function(Reservacion) _then) = _$ReservacionCopyWithImpl;
@useResult
$Res call({
 int idReservacion, DateTime inicio, int comensales, EstadoReservacion estado, int idCliente, String? nombreCliente, int? numeroMesa
});




}
/// @nodoc
class _$ReservacionCopyWithImpl<$Res>
    implements $ReservacionCopyWith<$Res> {
  _$ReservacionCopyWithImpl(this._self, this._then);

  final Reservacion _self;
  final $Res Function(Reservacion) _then;

/// Create a copy of Reservacion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idReservacion = null,Object? inicio = null,Object? comensales = null,Object? estado = null,Object? idCliente = null,Object? nombreCliente = freezed,Object? numeroMesa = freezed,}) {
  return _then(Reservacion(
idReservacion: null == idReservacion ? _self.idReservacion : idReservacion // ignore: cast_nullable_to_non_nullable
as int,inicio: null == inicio ? _self.inicio : inicio // ignore: cast_nullable_to_non_nullable
as DateTime,comensales: null == comensales ? _self.comensales : comensales // ignore: cast_nullable_to_non_nullable
as int,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoReservacion,idCliente: null == idCliente ? _self.idCliente : idCliente // ignore: cast_nullable_to_non_nullable
as int,nombreCliente: freezed == nombreCliente ? _self.nombreCliente : nombreCliente // ignore: cast_nullable_to_non_nullable
as String?,numeroMesa: freezed == numeroMesa ? _self.numeroMesa : numeroMesa // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Reservacion].
extension ReservacionPatterns on Reservacion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reservacion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reservacion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reservacion value)  $default,){
final _that = this;
switch (_that) {
case _Reservacion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reservacion value)?  $default,){
final _that = this;
switch (_that) {
case _Reservacion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int idReservacion,  DateTime inicio,  int comensales,  EstadoReservacion estado,  int idCliente,  String? nombreCliente,  int? numeroMesa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reservacion() when $default != null:
return $default(_that.idReservacion,_that.inicio,_that.comensales,_that.estado,_that.idCliente,_that.nombreCliente,_that.numeroMesa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int idReservacion,  DateTime inicio,  int comensales,  EstadoReservacion estado,  int idCliente,  String? nombreCliente,  int? numeroMesa)  $default,) {final _that = this;
switch (_that) {
case _Reservacion():
return $default(_that.idReservacion,_that.inicio,_that.comensales,_that.estado,_that.idCliente,_that.nombreCliente,_that.numeroMesa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int idReservacion,  DateTime inicio,  int comensales,  EstadoReservacion estado,  int idCliente,  String? nombreCliente,  int? numeroMesa)?  $default,) {final _that = this;
switch (_that) {
case _Reservacion() when $default != null:
return $default(_that.idReservacion,_that.inicio,_that.comensales,_that.estado,_that.idCliente,_that.nombreCliente,_that.numeroMesa);case _:
  return null;

}
}

}

/// @nodoc


class _Reservacion extends Reservacion {
  const _Reservacion({required this.idReservacion, required this.inicio, required this.comensales, required this.estado, required this.idCliente, this.nombreCliente, this.numeroMesa}): super._();
  

@override final  int idReservacion;
@override final  DateTime inicio;
@override final  int comensales;
@override final  EstadoReservacion estado;
@override final  int idCliente;
@override final  String? nombreCliente;
@override final  int? numeroMesa;

/// Create a copy of Reservacion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservacionCopyWith<_Reservacion> get copyWith => __$ReservacionCopyWithImpl<_Reservacion>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reservacion&&(identical(other.idReservacion, idReservacion) || other.idReservacion == idReservacion)&&(identical(other.inicio, inicio) || other.inicio == inicio)&&(identical(other.comensales, comensales) || other.comensales == comensales)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.idCliente, idCliente) || other.idCliente == idCliente)&&(identical(other.nombreCliente, nombreCliente) || other.nombreCliente == nombreCliente)&&(identical(other.numeroMesa, numeroMesa) || other.numeroMesa == numeroMesa));
}


@override
int get hashCode {
    return Object.hash(runtimeType,idReservacion,inicio,comensales,estado,idCliente,nombreCliente,numeroMesa);
}

@override
String toString() {
    return 'Reservacion(idReservacion: $idReservacion, inicio: $inicio, comensales: $comensales, estado: $estado, idCliente: $idCliente, nombreCliente: $nombreCliente, numeroMesa: $numeroMesa)';
}


}

/// @nodoc
abstract mixin class _$ReservacionCopyWith<$Res> implements $ReservacionCopyWith<$Res> {
  factory _$ReservacionCopyWith(_Reservacion value, $Res Function(_Reservacion) _then) = __$ReservacionCopyWithImpl;
@override @useResult
$Res call({
 int idReservacion, DateTime inicio, int comensales, EstadoReservacion estado, int idCliente, String? nombreCliente, int? numeroMesa
});




}
/// @nodoc
class __$ReservacionCopyWithImpl<$Res>
    implements _$ReservacionCopyWith<$Res> {
  __$ReservacionCopyWithImpl(this._self, this._then);

  final _Reservacion _self;
  final $Res Function(_Reservacion) _then;

/// Create a copy of Reservacion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idReservacion = null,Object? inicio = null,Object? comensales = null,Object? estado = null,Object? idCliente = null,Object? nombreCliente = freezed,Object? numeroMesa = freezed,}) {
  return _then(_Reservacion(
idReservacion: null == idReservacion ? _self.idReservacion : idReservacion // ignore: cast_nullable_to_non_nullable
as int,inicio: null == inicio ? _self.inicio : inicio // ignore: cast_nullable_to_non_nullable
as DateTime,comensales: null == comensales ? _self.comensales : comensales // ignore: cast_nullable_to_non_nullable
as int,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoReservacion,idCliente: null == idCliente ? _self.idCliente : idCliente // ignore: cast_nullable_to_non_nullable
as int,nombreCliente: freezed == nombreCliente ? _self.nombreCliente : nombreCliente // ignore: cast_nullable_to_non_nullable
as String?,numeroMesa: freezed == numeroMesa ? _self.numeroMesa : numeroMesa // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$ClienteReserva {

 int get idCliente; String get nombre; String? get telefono;
/// Create a copy of ClienteReserva
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClienteReservaCopyWith<ClienteReserva> get copyWith => _$ClienteReservaCopyWithImpl<ClienteReserva>(this as ClienteReserva, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ClienteReserva;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClienteReserva&&(identical(other.idCliente, _this.idCliente) || other.idCliente == _this.idCliente)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.telefono, _this.telefono) || other.telefono == _this.telefono));
}


@override
int get hashCode {
  final _this = this as ClienteReserva;
  return Object.hash(runtimeType,_this.idCliente,_this.nombre,_this.telefono);
}

@override
String toString() {
  final _this = this as ClienteReserva;
  return 'ClienteReserva(idCliente: ${_this.idCliente}, nombre: ${_this.nombre}, telefono: ${_this.telefono})';
}


}

/// @nodoc
abstract mixin class $ClienteReservaCopyWith<$Res>  {
  factory $ClienteReservaCopyWith(ClienteReserva value, $Res Function(ClienteReserva) _then) = _$ClienteReservaCopyWithImpl;
@useResult
$Res call({
 int idCliente, String nombre, String? telefono
});




}
/// @nodoc
class _$ClienteReservaCopyWithImpl<$Res>
    implements $ClienteReservaCopyWith<$Res> {
  _$ClienteReservaCopyWithImpl(this._self, this._then);

  final ClienteReserva _self;
  final $Res Function(ClienteReserva) _then;

/// Create a copy of ClienteReserva
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idCliente = null,Object? nombre = null,Object? telefono = freezed,}) {
  return _then(ClienteReserva(
idCliente: null == idCliente ? _self.idCliente : idCliente // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClienteReserva].
extension ClienteReservaPatterns on ClienteReserva {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClienteReserva value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClienteReserva() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClienteReserva value)  $default,){
final _that = this;
switch (_that) {
case _ClienteReserva():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClienteReserva value)?  $default,){
final _that = this;
switch (_that) {
case _ClienteReserva() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int idCliente,  String nombre,  String? telefono)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClienteReserva() when $default != null:
return $default(_that.idCliente,_that.nombre,_that.telefono);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int idCliente,  String nombre,  String? telefono)  $default,) {final _that = this;
switch (_that) {
case _ClienteReserva():
return $default(_that.idCliente,_that.nombre,_that.telefono);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int idCliente,  String nombre,  String? telefono)?  $default,) {final _that = this;
switch (_that) {
case _ClienteReserva() when $default != null:
return $default(_that.idCliente,_that.nombre,_that.telefono);case _:
  return null;

}
}

}

/// @nodoc


class _ClienteReserva implements ClienteReserva {
  const _ClienteReserva({required this.idCliente, required this.nombre, this.telefono});
  

@override final  int idCliente;
@override final  String nombre;
@override final  String? telefono;

/// Create a copy of ClienteReserva
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClienteReservaCopyWith<_ClienteReserva> get copyWith => __$ClienteReservaCopyWithImpl<_ClienteReserva>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClienteReserva&&(identical(other.idCliente, idCliente) || other.idCliente == idCliente)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.telefono, telefono) || other.telefono == telefono));
}


@override
int get hashCode {
    return Object.hash(runtimeType,idCliente,nombre,telefono);
}

@override
String toString() {
    return 'ClienteReserva(idCliente: $idCliente, nombre: $nombre, telefono: $telefono)';
}


}

/// @nodoc
abstract mixin class _$ClienteReservaCopyWith<$Res> implements $ClienteReservaCopyWith<$Res> {
  factory _$ClienteReservaCopyWith(_ClienteReserva value, $Res Function(_ClienteReserva) _then) = __$ClienteReservaCopyWithImpl;
@override @useResult
$Res call({
 int idCliente, String nombre, String? telefono
});




}
/// @nodoc
class __$ClienteReservaCopyWithImpl<$Res>
    implements _$ClienteReservaCopyWith<$Res> {
  __$ClienteReservaCopyWithImpl(this._self, this._then);

  final _ClienteReserva _self;
  final $Res Function(_ClienteReserva) _then;

/// Create a copy of ClienteReserva
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idCliente = null,Object? nombre = null,Object? telefono = freezed,}) {
  return _then(_ClienteReserva(
idCliente: null == idCliente ? _self.idCliente : idCliente // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
