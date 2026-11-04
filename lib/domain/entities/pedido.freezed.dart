// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pedido.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PedidoResumen {

 int get folio; int get folioDia; DateTime get horaIngreso; TipoPedido get tipo; EstadoPedido get estado; double get total; bool get esEnLinea; int? get numeroMesa; String? get nombreMesero;
/// Create a copy of PedidoResumen
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PedidoResumenCopyWith<PedidoResumen> get copyWith => _$PedidoResumenCopyWithImpl<PedidoResumen>(this as PedidoResumen, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PedidoResumen;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PedidoResumen&&(identical(other.folio, _this.folio) || other.folio == _this.folio)&&(identical(other.folioDia, _this.folioDia) || other.folioDia == _this.folioDia)&&(identical(other.horaIngreso, _this.horaIngreso) || other.horaIngreso == _this.horaIngreso)&&(identical(other.tipo, _this.tipo) || other.tipo == _this.tipo)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.esEnLinea, _this.esEnLinea) || other.esEnLinea == _this.esEnLinea)&&(identical(other.numeroMesa, _this.numeroMesa) || other.numeroMesa == _this.numeroMesa)&&(identical(other.nombreMesero, _this.nombreMesero) || other.nombreMesero == _this.nombreMesero));
}


@override
int get hashCode {
  final _this = this as PedidoResumen;
  return Object.hash(runtimeType,_this.folio,_this.folioDia,_this.horaIngreso,_this.tipo,_this.estado,_this.total,_this.esEnLinea,_this.numeroMesa,_this.nombreMesero);
}

@override
String toString() {
  final _this = this as PedidoResumen;
  return 'PedidoResumen(folio: ${_this.folio}, folioDia: ${_this.folioDia}, horaIngreso: ${_this.horaIngreso}, tipo: ${_this.tipo}, estado: ${_this.estado}, total: ${_this.total}, esEnLinea: ${_this.esEnLinea}, numeroMesa: ${_this.numeroMesa}, nombreMesero: ${_this.nombreMesero})';
}


}

/// @nodoc
abstract mixin class $PedidoResumenCopyWith<$Res>  {
  factory $PedidoResumenCopyWith(PedidoResumen value, $Res Function(PedidoResumen) _then) = _$PedidoResumenCopyWithImpl;
@useResult
$Res call({
 int folio, int folioDia, DateTime horaIngreso, TipoPedido tipo, EstadoPedido estado, double total, bool esEnLinea, int? numeroMesa, String? nombreMesero
});




}
/// @nodoc
class _$PedidoResumenCopyWithImpl<$Res>
    implements $PedidoResumenCopyWith<$Res> {
  _$PedidoResumenCopyWithImpl(this._self, this._then);

  final PedidoResumen _self;
  final $Res Function(PedidoResumen) _then;

/// Create a copy of PedidoResumen
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? folio = null,Object? folioDia = null,Object? horaIngreso = null,Object? tipo = null,Object? estado = null,Object? total = null,Object? esEnLinea = null,Object? numeroMesa = freezed,Object? nombreMesero = freezed,}) {
  return _then(PedidoResumen(
folio: null == folio ? _self.folio : folio // ignore: cast_nullable_to_non_nullable
as int,folioDia: null == folioDia ? _self.folioDia : folioDia // ignore: cast_nullable_to_non_nullable
as int,horaIngreso: null == horaIngreso ? _self.horaIngreso : horaIngreso // ignore: cast_nullable_to_non_nullable
as DateTime,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoPedido,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoPedido,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,esEnLinea: null == esEnLinea ? _self.esEnLinea : esEnLinea // ignore: cast_nullable_to_non_nullable
as bool,numeroMesa: freezed == numeroMesa ? _self.numeroMesa : numeroMesa // ignore: cast_nullable_to_non_nullable
as int?,nombreMesero: freezed == nombreMesero ? _self.nombreMesero : nombreMesero // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PedidoResumen].
extension PedidoResumenPatterns on PedidoResumen {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PedidoResumen value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PedidoResumen() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PedidoResumen value)  $default,){
final _that = this;
switch (_that) {
case _PedidoResumen():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PedidoResumen value)?  $default,){
final _that = this;
switch (_that) {
case _PedidoResumen() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int folio,  int folioDia,  DateTime horaIngreso,  TipoPedido tipo,  EstadoPedido estado,  double total,  bool esEnLinea,  int? numeroMesa,  String? nombreMesero)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PedidoResumen() when $default != null:
return $default(_that.folio,_that.folioDia,_that.horaIngreso,_that.tipo,_that.estado,_that.total,_that.esEnLinea,_that.numeroMesa,_that.nombreMesero);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int folio,  int folioDia,  DateTime horaIngreso,  TipoPedido tipo,  EstadoPedido estado,  double total,  bool esEnLinea,  int? numeroMesa,  String? nombreMesero)  $default,) {final _that = this;
switch (_that) {
case _PedidoResumen():
return $default(_that.folio,_that.folioDia,_that.horaIngreso,_that.tipo,_that.estado,_that.total,_that.esEnLinea,_that.numeroMesa,_that.nombreMesero);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int folio,  int folioDia,  DateTime horaIngreso,  TipoPedido tipo,  EstadoPedido estado,  double total,  bool esEnLinea,  int? numeroMesa,  String? nombreMesero)?  $default,) {final _that = this;
switch (_that) {
case _PedidoResumen() when $default != null:
return $default(_that.folio,_that.folioDia,_that.horaIngreso,_that.tipo,_that.estado,_that.total,_that.esEnLinea,_that.numeroMesa,_that.nombreMesero);case _:
  return null;

}
}

}

/// @nodoc


class _PedidoResumen extends PedidoResumen {
  const _PedidoResumen({required this.folio, required this.folioDia, required this.horaIngreso, required this.tipo, required this.estado, required this.total, required this.esEnLinea, this.numeroMesa, this.nombreMesero}): super._();
  

@override final  int folio;
@override final  int folioDia;
@override final  DateTime horaIngreso;
@override final  TipoPedido tipo;
@override final  EstadoPedido estado;
@override final  double total;
@override final  bool esEnLinea;
@override final  int? numeroMesa;
@override final  String? nombreMesero;

/// Create a copy of PedidoResumen
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PedidoResumenCopyWith<_PedidoResumen> get copyWith => __$PedidoResumenCopyWithImpl<_PedidoResumen>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PedidoResumen&&(identical(other.folio, folio) || other.folio == folio)&&(identical(other.folioDia, folioDia) || other.folioDia == folioDia)&&(identical(other.horaIngreso, horaIngreso) || other.horaIngreso == horaIngreso)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.total, total) || other.total == total)&&(identical(other.esEnLinea, esEnLinea) || other.esEnLinea == esEnLinea)&&(identical(other.numeroMesa, numeroMesa) || other.numeroMesa == numeroMesa)&&(identical(other.nombreMesero, nombreMesero) || other.nombreMesero == nombreMesero));
}


@override
int get hashCode {
    return Object.hash(runtimeType,folio,folioDia,horaIngreso,tipo,estado,total,esEnLinea,numeroMesa,nombreMesero);
}

@override
String toString() {
    return 'PedidoResumen(folio: $folio, folioDia: $folioDia, horaIngreso: $horaIngreso, tipo: $tipo, estado: $estado, total: $total, esEnLinea: $esEnLinea, numeroMesa: $numeroMesa, nombreMesero: $nombreMesero)';
}


}

/// @nodoc
abstract mixin class _$PedidoResumenCopyWith<$Res> implements $PedidoResumenCopyWith<$Res> {
  factory _$PedidoResumenCopyWith(_PedidoResumen value, $Res Function(_PedidoResumen) _then) = __$PedidoResumenCopyWithImpl;
@override @useResult
$Res call({
 int folio, int folioDia, DateTime horaIngreso, TipoPedido tipo, EstadoPedido estado, double total, bool esEnLinea, int? numeroMesa, String? nombreMesero
});




}
/// @nodoc
class __$PedidoResumenCopyWithImpl<$Res>
    implements _$PedidoResumenCopyWith<$Res> {
  __$PedidoResumenCopyWithImpl(this._self, this._then);

  final _PedidoResumen _self;
  final $Res Function(_PedidoResumen) _then;

/// Create a copy of PedidoResumen
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? folio = null,Object? folioDia = null,Object? horaIngreso = null,Object? tipo = null,Object? estado = null,Object? total = null,Object? esEnLinea = null,Object? numeroMesa = freezed,Object? nombreMesero = freezed,}) {
  return _then(_PedidoResumen(
folio: null == folio ? _self.folio : folio // ignore: cast_nullable_to_non_nullable
as int,folioDia: null == folioDia ? _self.folioDia : folioDia // ignore: cast_nullable_to_non_nullable
as int,horaIngreso: null == horaIngreso ? _self.horaIngreso : horaIngreso // ignore: cast_nullable_to_non_nullable
as DateTime,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoPedido,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoPedido,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,esEnLinea: null == esEnLinea ? _self.esEnLinea : esEnLinea // ignore: cast_nullable_to_non_nullable
as bool,numeroMesa: freezed == numeroMesa ? _self.numeroMesa : numeroMesa // ignore: cast_nullable_to_non_nullable
as int?,nombreMesero: freezed == nombreMesero ? _self.nombreMesero : nombreMesero // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
