// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platillo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Platillo {

 int get idPlatillo; String get nombre; double get precio; CategoriaPlatillo get categoria; bool get disponible;/// null => la app muestra un ícono de la categoría.
 String? get imagenUrl;
/// Create a copy of Platillo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatilloCopyWith<Platillo> get copyWith => _$PlatilloCopyWithImpl<Platillo>(this as Platillo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Platillo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Platillo&&(identical(other.idPlatillo, _this.idPlatillo) || other.idPlatillo == _this.idPlatillo)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.precio, _this.precio) || other.precio == _this.precio)&&(identical(other.categoria, _this.categoria) || other.categoria == _this.categoria)&&(identical(other.disponible, _this.disponible) || other.disponible == _this.disponible)&&(identical(other.imagenUrl, _this.imagenUrl) || other.imagenUrl == _this.imagenUrl));
}


@override
int get hashCode {
  final _this = this as Platillo;
  return Object.hash(runtimeType,_this.idPlatillo,_this.nombre,_this.precio,_this.categoria,_this.disponible,_this.imagenUrl);
}

@override
String toString() {
  final _this = this as Platillo;
  return 'Platillo(idPlatillo: ${_this.idPlatillo}, nombre: ${_this.nombre}, precio: ${_this.precio}, categoria: ${_this.categoria}, disponible: ${_this.disponible}, imagenUrl: ${_this.imagenUrl})';
}


}

/// @nodoc
abstract mixin class $PlatilloCopyWith<$Res>  {
  factory $PlatilloCopyWith(Platillo value, $Res Function(Platillo) _then) = _$PlatilloCopyWithImpl;
@useResult
$Res call({
 int idPlatillo, String nombre, double precio, CategoriaPlatillo categoria, bool disponible, String? imagenUrl
});




}
/// @nodoc
class _$PlatilloCopyWithImpl<$Res>
    implements $PlatilloCopyWith<$Res> {
  _$PlatilloCopyWithImpl(this._self, this._then);

  final Platillo _self;
  final $Res Function(Platillo) _then;

/// Create a copy of Platillo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idPlatillo = null,Object? nombre = null,Object? precio = null,Object? categoria = null,Object? disponible = null,Object? imagenUrl = freezed,}) {
  return _then(Platillo(
idPlatillo: null == idPlatillo ? _self.idPlatillo : idPlatillo // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,precio: null == precio ? _self.precio : precio // ignore: cast_nullable_to_non_nullable
as double,categoria: null == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as CategoriaPlatillo,disponible: null == disponible ? _self.disponible : disponible // ignore: cast_nullable_to_non_nullable
as bool,imagenUrl: freezed == imagenUrl ? _self.imagenUrl : imagenUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Platillo].
extension PlatilloPatterns on Platillo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Platillo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Platillo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Platillo value)  $default,){
final _that = this;
switch (_that) {
case _Platillo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Platillo value)?  $default,){
final _that = this;
switch (_that) {
case _Platillo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int idPlatillo,  String nombre,  double precio,  CategoriaPlatillo categoria,  bool disponible,  String? imagenUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Platillo() when $default != null:
return $default(_that.idPlatillo,_that.nombre,_that.precio,_that.categoria,_that.disponible,_that.imagenUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int idPlatillo,  String nombre,  double precio,  CategoriaPlatillo categoria,  bool disponible,  String? imagenUrl)  $default,) {final _that = this;
switch (_that) {
case _Platillo():
return $default(_that.idPlatillo,_that.nombre,_that.precio,_that.categoria,_that.disponible,_that.imagenUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int idPlatillo,  String nombre,  double precio,  CategoriaPlatillo categoria,  bool disponible,  String? imagenUrl)?  $default,) {final _that = this;
switch (_that) {
case _Platillo() when $default != null:
return $default(_that.idPlatillo,_that.nombre,_that.precio,_that.categoria,_that.disponible,_that.imagenUrl);case _:
  return null;

}
}

}

/// @nodoc


class _Platillo implements Platillo {
  const _Platillo({required this.idPlatillo, required this.nombre, required this.precio, required this.categoria, required this.disponible, this.imagenUrl});
  

@override final  int idPlatillo;
@override final  String nombre;
@override final  double precio;
@override final  CategoriaPlatillo categoria;
@override final  bool disponible;
/// null => la app muestra un ícono de la categoría.
@override final  String? imagenUrl;

/// Create a copy of Platillo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatilloCopyWith<_Platillo> get copyWith => __$PlatilloCopyWithImpl<_Platillo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Platillo&&(identical(other.idPlatillo, idPlatillo) || other.idPlatillo == idPlatillo)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.precio, precio) || other.precio == precio)&&(identical(other.categoria, categoria) || other.categoria == categoria)&&(identical(other.disponible, disponible) || other.disponible == disponible)&&(identical(other.imagenUrl, imagenUrl) || other.imagenUrl == imagenUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,idPlatillo,nombre,precio,categoria,disponible,imagenUrl);
}

@override
String toString() {
    return 'Platillo(idPlatillo: $idPlatillo, nombre: $nombre, precio: $precio, categoria: $categoria, disponible: $disponible, imagenUrl: $imagenUrl)';
}


}

/// @nodoc
abstract mixin class _$PlatilloCopyWith<$Res> implements $PlatilloCopyWith<$Res> {
  factory _$PlatilloCopyWith(_Platillo value, $Res Function(_Platillo) _then) = __$PlatilloCopyWithImpl;
@override @useResult
$Res call({
 int idPlatillo, String nombre, double precio, CategoriaPlatillo categoria, bool disponible, String? imagenUrl
});




}
/// @nodoc
class __$PlatilloCopyWithImpl<$Res>
    implements _$PlatilloCopyWith<$Res> {
  __$PlatilloCopyWithImpl(this._self, this._then);

  final _Platillo _self;
  final $Res Function(_Platillo) _then;

/// Create a copy of Platillo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idPlatillo = null,Object? nombre = null,Object? precio = null,Object? categoria = null,Object? disponible = null,Object? imagenUrl = freezed,}) {
  return _then(_Platillo(
idPlatillo: null == idPlatillo ? _self.idPlatillo : idPlatillo // ignore: cast_nullable_to_non_nullable
as int,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,precio: null == precio ? _self.precio : precio // ignore: cast_nullable_to_non_nullable
as double,categoria: null == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as CategoriaPlatillo,disponible: null == disponible ? _self.disponible : disponible // ignore: cast_nullable_to_non_nullable
as bool,imagenUrl: freezed == imagenUrl ? _self.imagenUrl : imagenUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
