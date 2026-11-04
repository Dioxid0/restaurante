// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pedido_detalle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ItemPedido {

 int get idPlatillo; int get cantidad;/// null o vacío => sin nota.
 String? get nota;
/// Create a copy of ItemPedido
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemPedidoCopyWith<ItemPedido> get copyWith => _$ItemPedidoCopyWithImpl<ItemPedido>(this as ItemPedido, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ItemPedido;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemPedido&&(identical(other.idPlatillo, _this.idPlatillo) || other.idPlatillo == _this.idPlatillo)&&(identical(other.cantidad, _this.cantidad) || other.cantidad == _this.cantidad)&&(identical(other.nota, _this.nota) || other.nota == _this.nota));
}


@override
int get hashCode {
  final _this = this as ItemPedido;
  return Object.hash(runtimeType,_this.idPlatillo,_this.cantidad,_this.nota);
}

@override
String toString() {
  final _this = this as ItemPedido;
  return 'ItemPedido(idPlatillo: ${_this.idPlatillo}, cantidad: ${_this.cantidad}, nota: ${_this.nota})';
}


}

/// @nodoc
abstract mixin class $ItemPedidoCopyWith<$Res>  {
  factory $ItemPedidoCopyWith(ItemPedido value, $Res Function(ItemPedido) _then) = _$ItemPedidoCopyWithImpl;
@useResult
$Res call({
 int idPlatillo, int cantidad, String? nota
});




}
/// @nodoc
class _$ItemPedidoCopyWithImpl<$Res>
    implements $ItemPedidoCopyWith<$Res> {
  _$ItemPedidoCopyWithImpl(this._self, this._then);

  final ItemPedido _self;
  final $Res Function(ItemPedido) _then;

/// Create a copy of ItemPedido
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idPlatillo = null,Object? cantidad = null,Object? nota = freezed,}) {
  return _then(ItemPedido(
idPlatillo: null == idPlatillo ? _self.idPlatillo : idPlatillo // ignore: cast_nullable_to_non_nullable
as int,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as int,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemPedido].
extension ItemPedidoPatterns on ItemPedido {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemPedido value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemPedido() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemPedido value)  $default,){
final _that = this;
switch (_that) {
case _ItemPedido():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemPedido value)?  $default,){
final _that = this;
switch (_that) {
case _ItemPedido() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int idPlatillo,  int cantidad,  String? nota)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemPedido() when $default != null:
return $default(_that.idPlatillo,_that.cantidad,_that.nota);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int idPlatillo,  int cantidad,  String? nota)  $default,) {final _that = this;
switch (_that) {
case _ItemPedido():
return $default(_that.idPlatillo,_that.cantidad,_that.nota);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int idPlatillo,  int cantidad,  String? nota)?  $default,) {final _that = this;
switch (_that) {
case _ItemPedido() when $default != null:
return $default(_that.idPlatillo,_that.cantidad,_that.nota);case _:
  return null;

}
}

}

/// @nodoc


class _ItemPedido implements ItemPedido {
  const _ItemPedido({required this.idPlatillo, required this.cantidad, this.nota});
  

@override final  int idPlatillo;
@override final  int cantidad;
/// null o vacío => sin nota.
@override final  String? nota;

/// Create a copy of ItemPedido
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemPedidoCopyWith<_ItemPedido> get copyWith => __$ItemPedidoCopyWithImpl<_ItemPedido>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemPedido&&(identical(other.idPlatillo, idPlatillo) || other.idPlatillo == idPlatillo)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.nota, nota) || other.nota == nota));
}


@override
int get hashCode {
    return Object.hash(runtimeType,idPlatillo,cantidad,nota);
}

@override
String toString() {
    return 'ItemPedido(idPlatillo: $idPlatillo, cantidad: $cantidad, nota: $nota)';
}


}

/// @nodoc
abstract mixin class _$ItemPedidoCopyWith<$Res> implements $ItemPedidoCopyWith<$Res> {
  factory _$ItemPedidoCopyWith(_ItemPedido value, $Res Function(_ItemPedido) _then) = __$ItemPedidoCopyWithImpl;
@override @useResult
$Res call({
 int idPlatillo, int cantidad, String? nota
});




}
/// @nodoc
class __$ItemPedidoCopyWithImpl<$Res>
    implements _$ItemPedidoCopyWith<$Res> {
  __$ItemPedidoCopyWithImpl(this._self, this._then);

  final _ItemPedido _self;
  final $Res Function(_ItemPedido) _then;

/// Create a copy of ItemPedido
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idPlatillo = null,Object? cantidad = null,Object? nota = freezed,}) {
  return _then(_ItemPedido(
idPlatillo: null == idPlatillo ? _self.idPlatillo : idPlatillo // ignore: cast_nullable_to_non_nullable
as int,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as int,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$LineaPedido {

 int get idPlatillo; String get nombre; double get precioUnitario; int get cantidad; String? get nota;
/// Create a copy of LineaPedido
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineaPedidoCopyWith<LineaPedido> get copyWith => _$LineaPedidoCopyWithImpl<LineaPedido>(this as LineaPedido, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LineaPedido;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineaPedido&&(identical(other.idPlatillo, _this.idPlatillo) || other.idPlatillo == _this.idPlatillo)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.precioUnitario, _this.precioUnitario) || other.precioUnitario == _this.precioUnitario)&&(identical(other.cantidad, _this.cantidad) || other.cantidad == _this.cantidad)&&(identical(other.nota, _this.nota) || other.nota == _this.nota));
}


@override
int get hashCode {
  final _this = this as LineaPedido;
  return Object.hash(runtimeType,_this.idPlatillo,_this.nombre,_this.precioUnitario,_this.cantidad,_this.nota);
}

@override
String toString() {
  final _this = this as LineaPedido;
  return 'LineaPedido(idPlatillo: ${_this.idPlatillo}, nombre: ${_this.nombre}, precioUnitario: ${_this.precioUnitario}, cantidad: ${_this.cantidad}, nota: ${_this.nota})';
}


}

/// @nodoc
abstract mixin class $LineaPedidoCopyWith<$Res>  {
  factory $LineaPedidoCopyWith(LineaPedido value, $Res Function(LineaPedido) _then) = _$LineaPedidoCopyWithImpl;
@useResult
$Res call({
 int idPlatillo, String nombre, double precioUnitario, int cantidad, String? nota
});




}
/// @nodoc
class _$LineaPedidoCopyWithImpl<$Res>
    implements $LineaPedidoCopyWith<$Res> {
  _$LineaPedidoCopyWithImpl(this._self, this._then);

  final LineaPedido _self;
  final $Res Function(LineaPedido) _then;

/// Create a copy of LineaPedido
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idPlatillo = null,Object? nombre = null,Object? precioUnitario = null,Object? cantidad = null,Object? nota = freezed,}) {
  return _then(LineaPedido(
idPlatillo: null == idPlatillo ? _self.idPlatillo : idPlatillo // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,precioUnitario: null == precioUnitario ? _self.precioUnitario : precioUnitario // ignore: cast_nullable_to_non_nullable
as double,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as int,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LineaPedido].
extension LineaPedidoPatterns on LineaPedido {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineaPedido value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineaPedido() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineaPedido value)  $default,){
final _that = this;
switch (_that) {
case _LineaPedido():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineaPedido value)?  $default,){
final _that = this;
switch (_that) {
case _LineaPedido() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int idPlatillo,  String nombre,  double precioUnitario,  int cantidad,  String? nota)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineaPedido() when $default != null:
return $default(_that.idPlatillo,_that.nombre,_that.precioUnitario,_that.cantidad,_that.nota);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int idPlatillo,  String nombre,  double precioUnitario,  int cantidad,  String? nota)  $default,) {final _that = this;
switch (_that) {
case _LineaPedido():
return $default(_that.idPlatillo,_that.nombre,_that.precioUnitario,_that.cantidad,_that.nota);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int idPlatillo,  String nombre,  double precioUnitario,  int cantidad,  String? nota)?  $default,) {final _that = this;
switch (_that) {
case _LineaPedido() when $default != null:
return $default(_that.idPlatillo,_that.nombre,_that.precioUnitario,_that.cantidad,_that.nota);case _:
  return null;

}
}

}

/// @nodoc


class _LineaPedido implements LineaPedido {
  const _LineaPedido({required this.idPlatillo, required this.nombre, required this.precioUnitario, required this.cantidad, this.nota});
  

@override final  int idPlatillo;
@override final  String nombre;
@override final  double precioUnitario;
@override final  int cantidad;
@override final  String? nota;

/// Create a copy of LineaPedido
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineaPedidoCopyWith<_LineaPedido> get copyWith => __$LineaPedidoCopyWithImpl<_LineaPedido>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineaPedido&&(identical(other.idPlatillo, idPlatillo) || other.idPlatillo == idPlatillo)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.precioUnitario, precioUnitario) || other.precioUnitario == precioUnitario)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.nota, nota) || other.nota == nota));
}


@override
int get hashCode {
    return Object.hash(runtimeType,idPlatillo,nombre,precioUnitario,cantidad,nota);
}

@override
String toString() {
    return 'LineaPedido(idPlatillo: $idPlatillo, nombre: $nombre, precioUnitario: $precioUnitario, cantidad: $cantidad, nota: $nota)';
}


}

/// @nodoc
abstract mixin class _$LineaPedidoCopyWith<$Res> implements $LineaPedidoCopyWith<$Res> {
  factory _$LineaPedidoCopyWith(_LineaPedido value, $Res Function(_LineaPedido) _then) = __$LineaPedidoCopyWithImpl;
@override @useResult
$Res call({
 int idPlatillo, String nombre, double precioUnitario, int cantidad, String? nota
});




}
/// @nodoc
class __$LineaPedidoCopyWithImpl<$Res>
    implements _$LineaPedidoCopyWith<$Res> {
  __$LineaPedidoCopyWithImpl(this._self, this._then);

  final _LineaPedido _self;
  final $Res Function(_LineaPedido) _then;

/// Create a copy of LineaPedido
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idPlatillo = null,Object? nombre = null,Object? precioUnitario = null,Object? cantidad = null,Object? nota = freezed,}) {
  return _then(_LineaPedido(
idPlatillo: null == idPlatillo ? _self.idPlatillo : idPlatillo // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,precioUnitario: null == precioUnitario ? _self.precioUnitario : precioUnitario // ignore: cast_nullable_to_non_nullable
as double,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as int,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$PedidoDetalle {

 int get folio; int get folioDia; TipoPedido get tipo; EstadoPedido get estado; List<LineaPedido> get lineas; int? get idMesa;
/// Create a copy of PedidoDetalle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PedidoDetalleCopyWith<PedidoDetalle> get copyWith => _$PedidoDetalleCopyWithImpl<PedidoDetalle>(this as PedidoDetalle, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PedidoDetalle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PedidoDetalle&&(identical(other.folio, _this.folio) || other.folio == _this.folio)&&(identical(other.folioDia, _this.folioDia) || other.folioDia == _this.folioDia)&&(identical(other.tipo, _this.tipo) || other.tipo == _this.tipo)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&const DeepCollectionEquality().equals(other.lineas, _this.lineas)&&(identical(other.idMesa, _this.idMesa) || other.idMesa == _this.idMesa));
}


@override
int get hashCode {
  final _this = this as PedidoDetalle;
  return Object.hash(runtimeType,_this.folio,_this.folioDia,_this.tipo,_this.estado,const DeepCollectionEquality().hash(_this.lineas),_this.idMesa);
}

@override
String toString() {
  final _this = this as PedidoDetalle;
  return 'PedidoDetalle(folio: ${_this.folio}, folioDia: ${_this.folioDia}, tipo: ${_this.tipo}, estado: ${_this.estado}, lineas: ${_this.lineas}, idMesa: ${_this.idMesa})';
}


}

/// @nodoc
abstract mixin class $PedidoDetalleCopyWith<$Res>  {
  factory $PedidoDetalleCopyWith(PedidoDetalle value, $Res Function(PedidoDetalle) _then) = _$PedidoDetalleCopyWithImpl;
@useResult
$Res call({
 int folio, int folioDia, TipoPedido tipo, EstadoPedido estado, List<LineaPedido> lineas, int? idMesa
});




}
/// @nodoc
class _$PedidoDetalleCopyWithImpl<$Res>
    implements $PedidoDetalleCopyWith<$Res> {
  _$PedidoDetalleCopyWithImpl(this._self, this._then);

  final PedidoDetalle _self;
  final $Res Function(PedidoDetalle) _then;

/// Create a copy of PedidoDetalle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? folio = null,Object? folioDia = null,Object? tipo = null,Object? estado = null,Object? lineas = null,Object? idMesa = freezed,}) {
  return _then(PedidoDetalle(
folio: null == folio ? _self.folio : folio // ignore: cast_nullable_to_non_nullable
as int,folioDia: null == folioDia ? _self.folioDia : folioDia // ignore: cast_nullable_to_non_nullable
as int,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoPedido,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoPedido,lineas: null == lineas ? _self.lineas : lineas // ignore: cast_nullable_to_non_nullable
as List<LineaPedido>,idMesa: freezed == idMesa ? _self.idMesa : idMesa // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PedidoDetalle].
extension PedidoDetallePatterns on PedidoDetalle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PedidoDetalle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PedidoDetalle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PedidoDetalle value)  $default,){
final _that = this;
switch (_that) {
case _PedidoDetalle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PedidoDetalle value)?  $default,){
final _that = this;
switch (_that) {
case _PedidoDetalle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int folio,  int folioDia,  TipoPedido tipo,  EstadoPedido estado,  List<LineaPedido> lineas,  int? idMesa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PedidoDetalle() when $default != null:
return $default(_that.folio,_that.folioDia,_that.tipo,_that.estado,_that.lineas,_that.idMesa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int folio,  int folioDia,  TipoPedido tipo,  EstadoPedido estado,  List<LineaPedido> lineas,  int? idMesa)  $default,) {final _that = this;
switch (_that) {
case _PedidoDetalle():
return $default(_that.folio,_that.folioDia,_that.tipo,_that.estado,_that.lineas,_that.idMesa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int folio,  int folioDia,  TipoPedido tipo,  EstadoPedido estado,  List<LineaPedido> lineas,  int? idMesa)?  $default,) {final _that = this;
switch (_that) {
case _PedidoDetalle() when $default != null:
return $default(_that.folio,_that.folioDia,_that.tipo,_that.estado,_that.lineas,_that.idMesa);case _:
  return null;

}
}

}

/// @nodoc


class _PedidoDetalle implements PedidoDetalle {
  const _PedidoDetalle({required this.folio, required this.folioDia, required this.tipo, required this.estado, required  List<LineaPedido> lineas, this.idMesa}): _lineas = lineas;
  

@override final  int folio;
@override final  int folioDia;
@override final  TipoPedido tipo;
@override final  EstadoPedido estado;
 final  List<LineaPedido> _lineas;
@override List<LineaPedido> get lineas {
  if (_lineas is EqualUnmodifiableListView) return _lineas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lineas);
}

@override final  int? idMesa;

/// Create a copy of PedidoDetalle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PedidoDetalleCopyWith<_PedidoDetalle> get copyWith => __$PedidoDetalleCopyWithImpl<_PedidoDetalle>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PedidoDetalle&&(identical(other.folio, folio) || other.folio == folio)&&(identical(other.folioDia, folioDia) || other.folioDia == folioDia)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.estado, estado) || other.estado == estado)&&const DeepCollectionEquality().equals(other.lineas, _lineas)&&(identical(other.idMesa, idMesa) || other.idMesa == idMesa));
}


@override
int get hashCode {
    return Object.hash(runtimeType,folio,folioDia,tipo,estado,const DeepCollectionEquality().hash(_lineas),idMesa);
}

@override
String toString() {
    return 'PedidoDetalle(folio: $folio, folioDia: $folioDia, tipo: $tipo, estado: $estado, lineas: $lineas, idMesa: $idMesa)';
}


}

/// @nodoc
abstract mixin class _$PedidoDetalleCopyWith<$Res> implements $PedidoDetalleCopyWith<$Res> {
  factory _$PedidoDetalleCopyWith(_PedidoDetalle value, $Res Function(_PedidoDetalle) _then) = __$PedidoDetalleCopyWithImpl;
@override @useResult
$Res call({
 int folio, int folioDia, TipoPedido tipo, EstadoPedido estado, List<LineaPedido> lineas, int? idMesa
});




}
/// @nodoc
class __$PedidoDetalleCopyWithImpl<$Res>
    implements _$PedidoDetalleCopyWith<$Res> {
  __$PedidoDetalleCopyWithImpl(this._self, this._then);

  final _PedidoDetalle _self;
  final $Res Function(_PedidoDetalle) _then;

/// Create a copy of PedidoDetalle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? folio = null,Object? folioDia = null,Object? tipo = null,Object? estado = null,Object? lineas = null,Object? idMesa = freezed,}) {
  return _then(_PedidoDetalle(
folio: null == folio ? _self.folio : folio // ignore: cast_nullable_to_non_nullable
as int,folioDia: null == folioDia ? _self.folioDia : folioDia // ignore: cast_nullable_to_non_nullable
as int,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoPedido,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoPedido,lineas: null == lineas ? _self._lineas : lineas // ignore: cast_nullable_to_non_nullable
as List<LineaPedido>,idMesa: freezed == idMesa ? _self.idMesa : idMesa // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
