// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cocina.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RenglonCocina {

 String get nombre; int get cantidad; String? get nota;
/// Create a copy of RenglonCocina
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RenglonCocinaCopyWith<RenglonCocina> get copyWith => _$RenglonCocinaCopyWithImpl<RenglonCocina>(this as RenglonCocina, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RenglonCocina;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RenglonCocina&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.cantidad, _this.cantidad) || other.cantidad == _this.cantidad)&&(identical(other.nota, _this.nota) || other.nota == _this.nota));
}


@override
int get hashCode {
  final _this = this as RenglonCocina;
  return Object.hash(runtimeType,_this.nombre,_this.cantidad,_this.nota);
}

@override
String toString() {
  final _this = this as RenglonCocina;
  return 'RenglonCocina(nombre: ${_this.nombre}, cantidad: ${_this.cantidad}, nota: ${_this.nota})';
}


}

/// @nodoc
abstract mixin class $RenglonCocinaCopyWith<$Res>  {
  factory $RenglonCocinaCopyWith(RenglonCocina value, $Res Function(RenglonCocina) _then) = _$RenglonCocinaCopyWithImpl;
@useResult
$Res call({
 String nombre, int cantidad, String? nota
});




}
/// @nodoc
class _$RenglonCocinaCopyWithImpl<$Res>
    implements $RenglonCocinaCopyWith<$Res> {
  _$RenglonCocinaCopyWithImpl(this._self, this._then);

  final RenglonCocina _self;
  final $Res Function(RenglonCocina) _then;

/// Create a copy of RenglonCocina
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nombre = null,Object? cantidad = null,Object? nota = freezed,}) {
  return _then(RenglonCocina(
nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as int,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RenglonCocina].
extension RenglonCocinaPatterns on RenglonCocina {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RenglonCocina value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RenglonCocina() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RenglonCocina value)  $default,){
final _that = this;
switch (_that) {
case _RenglonCocina():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RenglonCocina value)?  $default,){
final _that = this;
switch (_that) {
case _RenglonCocina() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nombre,  int cantidad,  String? nota)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RenglonCocina() when $default != null:
return $default(_that.nombre,_that.cantidad,_that.nota);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nombre,  int cantidad,  String? nota)  $default,) {final _that = this;
switch (_that) {
case _RenglonCocina():
return $default(_that.nombre,_that.cantidad,_that.nota);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nombre,  int cantidad,  String? nota)?  $default,) {final _that = this;
switch (_that) {
case _RenglonCocina() when $default != null:
return $default(_that.nombre,_that.cantidad,_that.nota);case _:
  return null;

}
}

}

/// @nodoc


class _RenglonCocina implements RenglonCocina {
  const _RenglonCocina({required this.nombre, required this.cantidad, this.nota});
  

@override final  String nombre;
@override final  int cantidad;
@override final  String? nota;

/// Create a copy of RenglonCocina
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RenglonCocinaCopyWith<_RenglonCocina> get copyWith => __$RenglonCocinaCopyWithImpl<_RenglonCocina>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RenglonCocina&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.nota, nota) || other.nota == nota));
}


@override
int get hashCode {
    return Object.hash(runtimeType,nombre,cantidad,nota);
}

@override
String toString() {
    return 'RenglonCocina(nombre: $nombre, cantidad: $cantidad, nota: $nota)';
}


}

/// @nodoc
abstract mixin class _$RenglonCocinaCopyWith<$Res> implements $RenglonCocinaCopyWith<$Res> {
  factory _$RenglonCocinaCopyWith(_RenglonCocina value, $Res Function(_RenglonCocina) _then) = __$RenglonCocinaCopyWithImpl;
@override @useResult
$Res call({
 String nombre, int cantidad, String? nota
});




}
/// @nodoc
class __$RenglonCocinaCopyWithImpl<$Res>
    implements _$RenglonCocinaCopyWith<$Res> {
  __$RenglonCocinaCopyWithImpl(this._self, this._then);

  final _RenglonCocina _self;
  final $Res Function(_RenglonCocina) _then;

/// Create a copy of RenglonCocina
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nombre = null,Object? cantidad = null,Object? nota = freezed,}) {
  return _then(_RenglonCocina(
nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as int,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$PedidoCocina {

 int get folio; int get folioDia; DateTime get horaIngreso; TipoPedido get tipo; EstadoPedido get estado; bool get esEnLinea; int? get numeroMesa; List<RenglonCocina> get renglones;
/// Create a copy of PedidoCocina
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PedidoCocinaCopyWith<PedidoCocina> get copyWith => _$PedidoCocinaCopyWithImpl<PedidoCocina>(this as PedidoCocina, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PedidoCocina;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PedidoCocina&&(identical(other.folio, _this.folio) || other.folio == _this.folio)&&(identical(other.folioDia, _this.folioDia) || other.folioDia == _this.folioDia)&&(identical(other.horaIngreso, _this.horaIngreso) || other.horaIngreso == _this.horaIngreso)&&(identical(other.tipo, _this.tipo) || other.tipo == _this.tipo)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.esEnLinea, _this.esEnLinea) || other.esEnLinea == _this.esEnLinea)&&(identical(other.numeroMesa, _this.numeroMesa) || other.numeroMesa == _this.numeroMesa)&&const DeepCollectionEquality().equals(other.renglones, _this.renglones));
}


@override
int get hashCode {
  final _this = this as PedidoCocina;
  return Object.hash(runtimeType,_this.folio,_this.folioDia,_this.horaIngreso,_this.tipo,_this.estado,_this.esEnLinea,_this.numeroMesa,const DeepCollectionEquality().hash(_this.renglones));
}

@override
String toString() {
  final _this = this as PedidoCocina;
  return 'PedidoCocina(folio: ${_this.folio}, folioDia: ${_this.folioDia}, horaIngreso: ${_this.horaIngreso}, tipo: ${_this.tipo}, estado: ${_this.estado}, esEnLinea: ${_this.esEnLinea}, numeroMesa: ${_this.numeroMesa}, renglones: ${_this.renglones})';
}


}

/// @nodoc
abstract mixin class $PedidoCocinaCopyWith<$Res>  {
  factory $PedidoCocinaCopyWith(PedidoCocina value, $Res Function(PedidoCocina) _then) = _$PedidoCocinaCopyWithImpl;
@useResult
$Res call({
 int folio, int folioDia, DateTime horaIngreso, TipoPedido tipo, EstadoPedido estado, bool esEnLinea, int? numeroMesa, List<RenglonCocina> renglones
});




}
/// @nodoc
class _$PedidoCocinaCopyWithImpl<$Res>
    implements $PedidoCocinaCopyWith<$Res> {
  _$PedidoCocinaCopyWithImpl(this._self, this._then);

  final PedidoCocina _self;
  final $Res Function(PedidoCocina) _then;

/// Create a copy of PedidoCocina
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? folio = null,Object? folioDia = null,Object? horaIngreso = null,Object? tipo = null,Object? estado = null,Object? esEnLinea = null,Object? numeroMesa = freezed,Object? renglones = null,}) {
  return _then(PedidoCocina(
folio: null == folio ? _self.folio : folio // ignore: cast_nullable_to_non_nullable
as int,folioDia: null == folioDia ? _self.folioDia : folioDia // ignore: cast_nullable_to_non_nullable
as int,horaIngreso: null == horaIngreso ? _self.horaIngreso : horaIngreso // ignore: cast_nullable_to_non_nullable
as DateTime,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoPedido,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoPedido,esEnLinea: null == esEnLinea ? _self.esEnLinea : esEnLinea // ignore: cast_nullable_to_non_nullable
as bool,numeroMesa: freezed == numeroMesa ? _self.numeroMesa : numeroMesa // ignore: cast_nullable_to_non_nullable
as int?,renglones: null == renglones ? _self.renglones : renglones // ignore: cast_nullable_to_non_nullable
as List<RenglonCocina>,
  ));
}

}


/// Adds pattern-matching-related methods to [PedidoCocina].
extension PedidoCocinaPatterns on PedidoCocina {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PedidoCocina value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PedidoCocina() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PedidoCocina value)  $default,){
final _that = this;
switch (_that) {
case _PedidoCocina():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PedidoCocina value)?  $default,){
final _that = this;
switch (_that) {
case _PedidoCocina() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int folio,  int folioDia,  DateTime horaIngreso,  TipoPedido tipo,  EstadoPedido estado,  bool esEnLinea,  int? numeroMesa,  List<RenglonCocina> renglones)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PedidoCocina() when $default != null:
return $default(_that.folio,_that.folioDia,_that.horaIngreso,_that.tipo,_that.estado,_that.esEnLinea,_that.numeroMesa,_that.renglones);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int folio,  int folioDia,  DateTime horaIngreso,  TipoPedido tipo,  EstadoPedido estado,  bool esEnLinea,  int? numeroMesa,  List<RenglonCocina> renglones)  $default,) {final _that = this;
switch (_that) {
case _PedidoCocina():
return $default(_that.folio,_that.folioDia,_that.horaIngreso,_that.tipo,_that.estado,_that.esEnLinea,_that.numeroMesa,_that.renglones);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int folio,  int folioDia,  DateTime horaIngreso,  TipoPedido tipo,  EstadoPedido estado,  bool esEnLinea,  int? numeroMesa,  List<RenglonCocina> renglones)?  $default,) {final _that = this;
switch (_that) {
case _PedidoCocina() when $default != null:
return $default(_that.folio,_that.folioDia,_that.horaIngreso,_that.tipo,_that.estado,_that.esEnLinea,_that.numeroMesa,_that.renglones);case _:
  return null;

}
}

}

/// @nodoc


class _PedidoCocina extends PedidoCocina {
  const _PedidoCocina({required this.folio, required this.folioDia, required this.horaIngreso, required this.tipo, required this.estado, required this.esEnLinea, this.numeroMesa,  List<RenglonCocina> renglones = const <RenglonCocina>[]}): _renglones = renglones,super._();
  

@override final  int folio;
@override final  int folioDia;
@override final  DateTime horaIngreso;
@override final  TipoPedido tipo;
@override final  EstadoPedido estado;
@override final  bool esEnLinea;
@override final  int? numeroMesa;
 final  List<RenglonCocina> _renglones;
@override@JsonKey() List<RenglonCocina> get renglones {
  if (_renglones is EqualUnmodifiableListView) return _renglones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_renglones);
}


/// Create a copy of PedidoCocina
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PedidoCocinaCopyWith<_PedidoCocina> get copyWith => __$PedidoCocinaCopyWithImpl<_PedidoCocina>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PedidoCocina&&(identical(other.folio, folio) || other.folio == folio)&&(identical(other.folioDia, folioDia) || other.folioDia == folioDia)&&(identical(other.horaIngreso, horaIngreso) || other.horaIngreso == horaIngreso)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.esEnLinea, esEnLinea) || other.esEnLinea == esEnLinea)&&(identical(other.numeroMesa, numeroMesa) || other.numeroMesa == numeroMesa)&&const DeepCollectionEquality().equals(other.renglones, _renglones));
}


@override
int get hashCode {
    return Object.hash(runtimeType,folio,folioDia,horaIngreso,tipo,estado,esEnLinea,numeroMesa,const DeepCollectionEquality().hash(_renglones));
}

@override
String toString() {
    return 'PedidoCocina(folio: $folio, folioDia: $folioDia, horaIngreso: $horaIngreso, tipo: $tipo, estado: $estado, esEnLinea: $esEnLinea, numeroMesa: $numeroMesa, renglones: $renglones)';
}


}

/// @nodoc
abstract mixin class _$PedidoCocinaCopyWith<$Res> implements $PedidoCocinaCopyWith<$Res> {
  factory _$PedidoCocinaCopyWith(_PedidoCocina value, $Res Function(_PedidoCocina) _then) = __$PedidoCocinaCopyWithImpl;
@override @useResult
$Res call({
 int folio, int folioDia, DateTime horaIngreso, TipoPedido tipo, EstadoPedido estado, bool esEnLinea, int? numeroMesa, List<RenglonCocina> renglones
});




}
/// @nodoc
class __$PedidoCocinaCopyWithImpl<$Res>
    implements _$PedidoCocinaCopyWith<$Res> {
  __$PedidoCocinaCopyWithImpl(this._self, this._then);

  final _PedidoCocina _self;
  final $Res Function(_PedidoCocina) _then;

/// Create a copy of PedidoCocina
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? folio = null,Object? folioDia = null,Object? horaIngreso = null,Object? tipo = null,Object? estado = null,Object? esEnLinea = null,Object? numeroMesa = freezed,Object? renglones = null,}) {
  return _then(_PedidoCocina(
folio: null == folio ? _self.folio : folio // ignore: cast_nullable_to_non_nullable
as int,folioDia: null == folioDia ? _self.folioDia : folioDia // ignore: cast_nullable_to_non_nullable
as int,horaIngreso: null == horaIngreso ? _self.horaIngreso : horaIngreso // ignore: cast_nullable_to_non_nullable
as DateTime,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoPedido,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoPedido,esEnLinea: null == esEnLinea ? _self.esEnLinea : esEnLinea // ignore: cast_nullable_to_non_nullable
as bool,numeroMesa: freezed == numeroMesa ? _self.numeroMesa : numeroMesa // ignore: cast_nullable_to_non_nullable
as int?,renglones: null == renglones ? _self._renglones : renglones // ignore: cast_nullable_to_non_nullable
as List<RenglonCocina>,
  ));
}


}

/// @nodoc
mixin _$AvisoCocina {

 int get idNotificacion; DateTime get hora; String get mensaje; TipoAviso get tipo; int get folio;
/// Create a copy of AvisoCocina
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvisoCocinaCopyWith<AvisoCocina> get copyWith => _$AvisoCocinaCopyWithImpl<AvisoCocina>(this as AvisoCocina, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AvisoCocina;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvisoCocina&&(identical(other.idNotificacion, _this.idNotificacion) || other.idNotificacion == _this.idNotificacion)&&(identical(other.hora, _this.hora) || other.hora == _this.hora)&&(identical(other.mensaje, _this.mensaje) || other.mensaje == _this.mensaje)&&(identical(other.tipo, _this.tipo) || other.tipo == _this.tipo)&&(identical(other.folio, _this.folio) || other.folio == _this.folio));
}


@override
int get hashCode {
  final _this = this as AvisoCocina;
  return Object.hash(runtimeType,_this.idNotificacion,_this.hora,_this.mensaje,_this.tipo,_this.folio);
}

@override
String toString() {
  final _this = this as AvisoCocina;
  return 'AvisoCocina(idNotificacion: ${_this.idNotificacion}, hora: ${_this.hora}, mensaje: ${_this.mensaje}, tipo: ${_this.tipo}, folio: ${_this.folio})';
}


}

/// @nodoc
abstract mixin class $AvisoCocinaCopyWith<$Res>  {
  factory $AvisoCocinaCopyWith(AvisoCocina value, $Res Function(AvisoCocina) _then) = _$AvisoCocinaCopyWithImpl;
@useResult
$Res call({
 int idNotificacion, DateTime hora, String mensaje, TipoAviso tipo, int folio
});




}
/// @nodoc
class _$AvisoCocinaCopyWithImpl<$Res>
    implements $AvisoCocinaCopyWith<$Res> {
  _$AvisoCocinaCopyWithImpl(this._self, this._then);

  final AvisoCocina _self;
  final $Res Function(AvisoCocina) _then;

/// Create a copy of AvisoCocina
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idNotificacion = null,Object? hora = null,Object? mensaje = null,Object? tipo = null,Object? folio = null,}) {
  return _then(AvisoCocina(
idNotificacion: null == idNotificacion ? _self.idNotificacion : idNotificacion // ignore: cast_nullable_to_non_nullable
as int,hora: null == hora ? _self.hora : hora // ignore: cast_nullable_to_non_nullable
as DateTime,mensaje: null == mensaje ? _self.mensaje : mensaje // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoAviso,folio: null == folio ? _self.folio : folio // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AvisoCocina].
extension AvisoCocinaPatterns on AvisoCocina {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvisoCocina value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvisoCocina() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvisoCocina value)  $default,){
final _that = this;
switch (_that) {
case _AvisoCocina():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvisoCocina value)?  $default,){
final _that = this;
switch (_that) {
case _AvisoCocina() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int idNotificacion,  DateTime hora,  String mensaje,  TipoAviso tipo,  int folio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvisoCocina() when $default != null:
return $default(_that.idNotificacion,_that.hora,_that.mensaje,_that.tipo,_that.folio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int idNotificacion,  DateTime hora,  String mensaje,  TipoAviso tipo,  int folio)  $default,) {final _that = this;
switch (_that) {
case _AvisoCocina():
return $default(_that.idNotificacion,_that.hora,_that.mensaje,_that.tipo,_that.folio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int idNotificacion,  DateTime hora,  String mensaje,  TipoAviso tipo,  int folio)?  $default,) {final _that = this;
switch (_that) {
case _AvisoCocina() when $default != null:
return $default(_that.idNotificacion,_that.hora,_that.mensaje,_that.tipo,_that.folio);case _:
  return null;

}
}

}

/// @nodoc


class _AvisoCocina implements AvisoCocina {
  const _AvisoCocina({required this.idNotificacion, required this.hora, required this.mensaje, required this.tipo, required this.folio});
  

@override final  int idNotificacion;
@override final  DateTime hora;
@override final  String mensaje;
@override final  TipoAviso tipo;
@override final  int folio;

/// Create a copy of AvisoCocina
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvisoCocinaCopyWith<_AvisoCocina> get copyWith => __$AvisoCocinaCopyWithImpl<_AvisoCocina>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvisoCocina&&(identical(other.idNotificacion, idNotificacion) || other.idNotificacion == idNotificacion)&&(identical(other.hora, hora) || other.hora == hora)&&(identical(other.mensaje, mensaje) || other.mensaje == mensaje)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.folio, folio) || other.folio == folio));
}


@override
int get hashCode {
    return Object.hash(runtimeType,idNotificacion,hora,mensaje,tipo,folio);
}

@override
String toString() {
    return 'AvisoCocina(idNotificacion: $idNotificacion, hora: $hora, mensaje: $mensaje, tipo: $tipo, folio: $folio)';
}


}

/// @nodoc
abstract mixin class _$AvisoCocinaCopyWith<$Res> implements $AvisoCocinaCopyWith<$Res> {
  factory _$AvisoCocinaCopyWith(_AvisoCocina value, $Res Function(_AvisoCocina) _then) = __$AvisoCocinaCopyWithImpl;
@override @useResult
$Res call({
 int idNotificacion, DateTime hora, String mensaje, TipoAviso tipo, int folio
});




}
/// @nodoc
class __$AvisoCocinaCopyWithImpl<$Res>
    implements _$AvisoCocinaCopyWith<$Res> {
  __$AvisoCocinaCopyWithImpl(this._self, this._then);

  final _AvisoCocina _self;
  final $Res Function(_AvisoCocina) _then;

/// Create a copy of AvisoCocina
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idNotificacion = null,Object? hora = null,Object? mensaje = null,Object? tipo = null,Object? folio = null,}) {
  return _then(_AvisoCocina(
idNotificacion: null == idNotificacion ? _self.idNotificacion : idNotificacion // ignore: cast_nullable_to_non_nullable
as int,hora: null == hora ? _self.hora : hora // ignore: cast_nullable_to_non_nullable
as DateTime,mensaje: null == mensaje ? _self.mensaje : mensaje // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoAviso,folio: null == folio ? _self.folio : folio // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
