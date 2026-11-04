// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hello_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lee el mensaje de prueba desde Supabase (tabla `hello_check`).

@ProviderFor(helloMessage)
final helloMessageProvider = HelloMessageProvider._();

/// Lee el mensaje de prueba desde Supabase (tabla `hello_check`).

final class HelloMessageProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Lee el mensaje de prueba desde Supabase (tabla `hello_check`).
  HelloMessageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'helloMessageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$helloMessageHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return helloMessage(ref);
  }
}

String _$helloMessageHash() => r'9a93804f4569546b94d31c016f089a150f2beec5';
