import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/empleado_repository.dart';
import '../domain/repositories/menu_repository.dart';
import 'supabase_menu_repository.dart';
import '../domain/repositories/pedido_repository.dart';
import 'supabase_auth_repository.dart';
import 'supabase_empleado_repository.dart';
import 'supabase_pedido_repository.dart';
import '../domain/repositories/reservacion_repository.dart';
import 'supabase_reservacion_repository.dart';
import '../domain/repositories/cocina_repository.dart';
import 'supabase_cocina_repository.dart';

part 'repository_providers.g.dart';

// Los widgets nunca usan Supabase directamente: pasan por estos repositorios.
// En pruebas se sustituyen con `overrideWithValue`.

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    SupabaseAuthRepository(Supabase.instance.client);

@Riverpod(keepAlive: true)
PedidoRepository pedidoRepository(Ref ref) =>
    SupabasePedidoRepository(Supabase.instance.client);

@Riverpod(keepAlive: true)
EmpleadoRepository empleadoRepository(Ref ref) =>
    SupabaseEmpleadoRepository(Supabase.instance.client);

@Riverpod(keepAlive: true)
MenuRepository menuRepository(Ref ref) => SupabaseMenuRepository(Supabase.instance.client);

@Riverpod(keepAlive: true)
MesaRepository mesaRepository(Ref ref) => SupabaseMesaRepository(Supabase.instance.client);

@Riverpod(keepAlive: true)
ReservacionRepository reservacionRepository(Ref ref) => SupabaseReservacionRepository(Supabase.instance.client);

@Riverpod(keepAlive: true)
CocinaRepository cocinaRepository(Ref ref) => SupabaseCocinaRepository(Supabase.instance.client);