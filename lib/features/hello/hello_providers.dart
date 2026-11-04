import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'hello_providers.g.dart';

/// Lee el mensaje de prueba desde Supabase (tabla `hello_check`).
@riverpod
Future<String> helloMessage(Ref ref) async {
  final row = await Supabase.instance.client
      .from('hello_check')
      .select('message')
      .limit(1)
      .single();
  return row['message'] as String;
}
