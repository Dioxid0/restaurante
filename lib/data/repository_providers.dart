import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/pedido_repository.dart';
import 'supabase_auth_repository.dart';
import 'supabase_pedido_repository.dart';

part 'repository_providers.g.dart';

// Los widgets nunca usan Supabase directamente: pasan por estos repositorios.
// En pruebas se sustituyen con `overrideWithValue`.

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    SupabaseAuthRepository(Supabase.instance.client);

@Riverpod(keepAlive: true)
PedidoRepository pedidoRepository(Ref ref) =>
    SupabasePedidoRepository(Supabase.instance.client);
