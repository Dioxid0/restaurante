// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comanda_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LineaComanda {

/// Identificador local (solo para la UI).
 int get id; int get idPlatillo; String get nombre; double get precio; int get cantidad; String get nota;
/// Create a copy of LineaComanda
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineaComandaCopyWith<LineaComanda> get copyWith => _$LineaComandaCopyWithImpl<LineaComanda>(this as LineaComanda, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LineaComanda;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineaComanda&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.idPlatillo, _this.idPlatillo) || other.idPlatillo == _this.idPlatillo)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.precio, _this.precio) || other.precio == _this.precio)&&(identical(other.cantidad, _this.cantidad) || other.cantidad == _this.cantidad)&&(identical(other.nota, _this.nota) || other.nota == _this.nota));
}


@override
int get hashCode {
  final _this = this as LineaComanda;
  return Object.hash(runtimeType,_this.id,_this.idPlatillo,_this.nombre,_this.precio,_this.cantidad,_this.nota);
}

@override
String toString() {
  final _this = this as LineaComanda;
  return 'LineaComanda(id: ${_this.id}, idPlatillo: ${_this.idPlatillo}, nombre: ${_this.nombre}, precio: ${_this.precio}, cantidad: ${_this.cantidad}, nota: ${_this.nota})';
}


}

/// @nodoc
abstract mixin class $LineaComandaCopyWith<$Res>  {
  factory $LineaComandaCopyWith(LineaComanda value, $Res Function(LineaComanda) _then) = _$LineaComandaCopyWithImpl;
@useResult
$Res call({
 int id, int idPlatillo, String nombre, double precio, int cantidad, String nota
});




}
/// @nodoc
class _$LineaComandaCopyWithImpl<$Res>
    implements $LineaComandaCopyWith<$Res> {
  _$LineaComandaCopyWithImpl(this._self, this._then);

  final LineaComanda _self;
  final $Res Function(LineaComanda) _then;

/// Create a copy of LineaComanda
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? idPlatillo = null,Object? nombre = null,Object? precio = null,Object? cantidad = null,Object? nota = null,}) {
  return _then(LineaComanda(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,idPlatillo: null == idPlatillo ? _self.idPlatillo : idPlatillo // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,precio: null == precio ? _self.precio : precio // ignore: cast_nullable_to_non_nullable
as double,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as int,nota: null == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LineaComanda].
extension LineaComandaPatterns on LineaComanda {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineaComanda value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineaComanda() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineaComanda value)  $default,){
final _that = this;
switch (_that) {
case _LineaComanda():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineaComanda value)?  $default,){
final _that = this;
switch (_that) {
case _LineaComanda() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int idPlatillo,  String nombre,  double precio,  int cantidad,  String nota)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineaComanda() when $default != null:
return $default(_that.id,_that.idPlatillo,_that.nombre,_that.precio,_that.cantidad,_that.nota);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int idPlatillo,  String nombre,  double precio,  int cantidad,  String nota)  $default,) {final _that = this;
switch (_that) {
case _LineaComanda():
return $default(_that.id,_that.idPlatillo,_that.nombre,_that.precio,_that.cantidad,_that.nota);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int idPlatillo,  String nombre,  double precio,  int cantidad,  String nota)?  $default,) {final _that = this;
switch (_that) {
case _LineaComanda() when $default != null:
return $default(_that.id,_that.idPlatillo,_that.nombre,_that.precio,_that.cantidad,_that.nota);case _:
  return null;

}
}

}

/// @nodoc


class _LineaComanda extends LineaComanda {
  const _LineaComanda({required this.id, required this.idPlatillo, required this.nombre, required this.precio, required this.cantidad, this.nota = ''}): super._();
  

/// Identificador local (solo para la UI).
@override final  int id;
@override final  int idPlatillo;
@override final  String nombre;
@override final  double precio;
@override final  int cantidad;
@override@JsonKey() final  String nota;

/// Create a copy of LineaComanda
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineaComandaCopyWith<_LineaComanda> get copyWith => __$LineaComandaCopyWithImpl<_LineaComanda>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineaComanda&&(identical(other.id, id) || other.id == id)&&(identical(other.idPlatillo, idPlatillo) || other.idPlatillo == idPlatillo)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.precio, precio) || other.precio == precio)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.nota, nota) || other.nota == nota));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,idPlatillo,nombre,precio,cantidad,nota);
}

@override
String toString() {
    return 'LineaComanda(id: $id, idPlatillo: $idPlatillo, nombre: $nombre, precio: $precio, cantidad: $cantidad, nota: $nota)';
}


}

/// @nodoc
abstract mixin class _$LineaComandaCopyWith<$Res> implements $LineaComandaCopyWith<$Res> {
  factory _$LineaComandaCopyWith(_LineaComanda value, $Res Function(_LineaComanda) _then) = __$LineaComandaCopyWithImpl;
@override @useResult
$Res call({
 int id, int idPlatillo, String nombre, double precio, int cantidad, String nota
});




}
/// @nodoc
class __$LineaComandaCopyWithImpl<$Res>
    implements _$LineaComandaCopyWith<$Res> {
  __$LineaComandaCopyWithImpl(this._self, this._then);

  final _LineaComanda _self;
  final $Res Function(_LineaComanda) _then;

/// Create a copy of LineaComanda
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? idPlatillo = null,Object? nombre = null,Object? precio = null,Object? cantidad = null,Object? nota = null,}) {
  return _then(_LineaComanda(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,idPlatillo: null == idPlatillo ? _self.idPlatillo : idPlatillo // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,precio: null == precio ? _self.precio : precio // ignore: cast_nullable_to_non_nullable
as double,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as int,nota: null == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ComandaState {

 TipoPedido get tipo; int? get idMesa;/// Solo aplica a "Para llevar": el pedido no se asocia a ninguna mesa.
 bool get sinMesa; List<LineaComanda> get lineas; int get siguienteId; bool get enviando;/// Firma del pedido tal como se cargó (modo edición). null en modo crear.
 String? get firmaBase;
/// Create a copy of ComandaState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComandaStateCopyWith<ComandaState> get copyWith => _$ComandaStateCopyWithImpl<ComandaState>(this as ComandaState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ComandaState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComandaState&&(identical(other.tipo, _this.tipo) || other.tipo == _this.tipo)&&(identical(other.idMesa, _this.idMesa) || other.idMesa == _this.idMesa)&&(identical(other.sinMesa, _this.sinMesa) || other.sinMesa == _this.sinMesa)&&const DeepCollectionEquality().equals(other.lineas, _this.lineas)&&(identical(other.siguienteId, _this.siguienteId) || other.siguienteId == _this.siguienteId)&&(identical(other.enviando, _this.enviando) || other.enviando == _this.enviando)&&(identical(other.firmaBase, _this.firmaBase) || other.firmaBase == _this.firmaBase));
}


@override
int get hashCode {
  final _this = this as ComandaState;
  return Object.hash(runtimeType,_this.tipo,_this.idMesa,_this.sinMesa,const DeepCollectionEquality().hash(_this.lineas),_this.siguienteId,_this.enviando,_this.firmaBase);
}

@override
String toString() {
  final _this = this as ComandaState;
  return 'ComandaState(tipo: ${_this.tipo}, idMesa: ${_this.idMesa}, sinMesa: ${_this.sinMesa}, lineas: ${_this.lineas}, siguienteId: ${_this.siguienteId}, enviando: ${_this.enviando}, firmaBase: ${_this.firmaBase})';
}


}

/// @nodoc
abstract mixin class $ComandaStateCopyWith<$Res>  {
  factory $ComandaStateCopyWith(ComandaState value, $Res Function(ComandaState) _then) = _$ComandaStateCopyWithImpl;
@useResult
$Res call({
 TipoPedido tipo, int? idMesa, bool sinMesa, List<LineaComanda> lineas, int siguienteId, bool enviando, String? firmaBase
});




}
/// @nodoc
class _$ComandaStateCopyWithImpl<$Res>
    implements $ComandaStateCopyWith<$Res> {
  _$ComandaStateCopyWithImpl(this._self, this._then);

  final ComandaState _self;
  final $Res Function(ComandaState) _then;

/// Create a copy of ComandaState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tipo = null,Object? idMesa = freezed,Object? sinMesa = null,Object? lineas = null,Object? siguienteId = null,Object? enviando = null,Object? firmaBase = freezed,}) {
  return _then(ComandaState(
tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoPedido,idMesa: freezed == idMesa ? _self.idMesa : idMesa // ignore: cast_nullable_to_non_nullable
as int?,sinMesa: null == sinMesa ? _self.sinMesa : sinMesa // ignore: cast_nullable_to_non_nullable
as bool,lineas: null == lineas ? _self.lineas : lineas // ignore: cast_nullable_to_non_nullable
as List<LineaComanda>,siguienteId: null == siguienteId ? _self.siguienteId : siguienteId // ignore: cast_nullable_to_non_nullable
as int,enviando: null == enviando ? _self.enviando : enviando // ignore: cast_nullable_to_non_nullable
as bool,firmaBase: freezed == firmaBase ? _self.firmaBase : firmaBase // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ComandaState].
extension ComandaStatePatterns on ComandaState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComandaState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComandaState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComandaState value)  $default,){
final _that = this;
switch (_that) {
case _ComandaState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComandaState value)?  $default,){
final _that = this;
switch (_that) {
case _ComandaState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TipoPedido tipo,  int? idMesa,  bool sinMesa,  List<LineaComanda> lineas,  int siguienteId,  bool enviando,  String? firmaBase)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComandaState() when $default != null:
return $default(_that.tipo,_that.idMesa,_that.sinMesa,_that.lineas,_that.siguienteId,_that.enviando,_that.firmaBase);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TipoPedido tipo,  int? idMesa,  bool sinMesa,  List<LineaComanda> lineas,  int siguienteId,  bool enviando,  String? firmaBase)  $default,) {final _that = this;
switch (_that) {
case _ComandaState():
return $default(_that.tipo,_that.idMesa,_that.sinMesa,_that.lineas,_that.siguienteId,_that.enviando,_that.firmaBase);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TipoPedido tipo,  int? idMesa,  bool sinMesa,  List<LineaComanda> lineas,  int siguienteId,  bool enviando,  String? firmaBase)?  $default,) {final _that = this;
switch (_that) {
case _ComandaState() when $default != null:
return $default(_that.tipo,_that.idMesa,_that.sinMesa,_that.lineas,_that.siguienteId,_that.enviando,_that.firmaBase);case _:
  return null;

}
}

}

/// @nodoc


class _ComandaState extends ComandaState {
  const _ComandaState({this.tipo = TipoPedido.enMesa, this.idMesa, this.sinMesa = false,  List<LineaComanda> lineas = const [], this.siguienteId = 1, this.enviando = false, this.firmaBase}): _lineas = lineas,super._();
  

@override@JsonKey() final  TipoPedido tipo;
@override final  int? idMesa;
/// Solo aplica a "Para llevar": el pedido no se asocia a ninguna mesa.
@override@JsonKey() final  bool sinMesa;
 final  List<LineaComanda> _lineas;
@override@JsonKey() List<LineaComanda> get lineas {
  if (_lineas is EqualUnmodifiableListView) return _lineas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lineas);
}

@override@JsonKey() final  int siguienteId;
@override@JsonKey() final  bool enviando;
/// Firma del pedido tal como se cargó (modo edición). null en modo crear.
@override final  String? firmaBase;

/// Create a copy of ComandaState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComandaStateCopyWith<_ComandaState> get copyWith => __$ComandaStateCopyWithImpl<_ComandaState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComandaState&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.idMesa, idMesa) || other.idMesa == idMesa)&&(identical(other.sinMesa, sinMesa) || other.sinMesa == sinMesa)&&const DeepCollectionEquality().equals(other.lineas, _lineas)&&(identical(other.siguienteId, siguienteId) || other.siguienteId == siguienteId)&&(identical(other.enviando, enviando) || other.enviando == enviando)&&(identical(other.firmaBase, firmaBase) || other.firmaBase == firmaBase));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tipo,idMesa,sinMesa,const DeepCollectionEquality().hash(_lineas),siguienteId,enviando,firmaBase);
}

@override
String toString() {
    return 'ComandaState(tipo: $tipo, idMesa: $idMesa, sinMesa: $sinMesa, lineas: $lineas, siguienteId: $siguienteId, enviando: $enviando, firmaBase: $firmaBase)';
}


}

/// @nodoc
abstract mixin class _$ComandaStateCopyWith<$Res> implements $ComandaStateCopyWith<$Res> {
  factory _$ComandaStateCopyWith(_ComandaState value, $Res Function(_ComandaState) _then) = __$ComandaStateCopyWithImpl;
@override @useResult
$Res call({
 TipoPedido tipo, int? idMesa, bool sinMesa, List<LineaComanda> lineas, int siguienteId, bool enviando, String? firmaBase
});




}
/// @nodoc
class __$ComandaStateCopyWithImpl<$Res>
    implements _$ComandaStateCopyWith<$Res> {
  __$ComandaStateCopyWithImpl(this._self, this._then);

  final _ComandaState _self;
  final $Res Function(_ComandaState) _then;

/// Create a copy of ComandaState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tipo = null,Object? idMesa = freezed,Object? sinMesa = null,Object? lineas = null,Object? siguienteId = null,Object? enviando = null,Object? firmaBase = freezed,}) {
  return _then(_ComandaState(
tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoPedido,idMesa: freezed == idMesa ? _self.idMesa : idMesa // ignore: cast_nullable_to_non_nullable
as int?,sinMesa: null == sinMesa ? _self.sinMesa : sinMesa // ignore: cast_nullable_to_non_nullable
as bool,lineas: null == lineas ? _self._lineas : lineas // ignore: cast_nullable_to_non_nullable
as List<LineaComanda>,siguienteId: null == siguienteId ? _self.siguienteId : siguienteId // ignore: cast_nullable_to_non_nullable
as int,enviando: null == enviando ? _self.enviando : enviando // ignore: cast_nullable_to_non_nullable
as bool,firmaBase: freezed == firmaBase ? _self.firmaBase : firmaBase // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
