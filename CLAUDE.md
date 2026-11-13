# Sistema de restaurante (proyecto escolar)

## Stack y decisiones
- Flutter (Dart) + Supabase. Paquete `restaurant_app`, org `com.escuela`.
- Estado: Riverpod (`flutter_riverpod`, `riverpod_annotation` + `riverpod_generator`).
- Navegación: `go_router`. Modelos: `freezed` + `json_serializable`.
- Código generado con `dart run build_runner build`.
- `custom_lint`/`riverpod_lint` omitidos: incompatibles con Riverpod 3 / freezed 3 (revisar más adelante).
- El proyecto Flutter vive en la raíz del repo (sin subcarpeta).

## Enfoque
- Escritorio (Windows) primero; móvil (Android) después.
- Las interfaces están en Figma; el usuario pasará las pantallas por etapas.

## Supabase
- Desarrollo con Supabase **local** (Docker Desktop + CLI vía `npx supabase`). Aún sin proyecto en la nube.
- Cambios de esquema solo mediante migraciones en `supabase/migrations/`.
- **RLS activado en todas las tablas** (`alter table ... enable row level security` + políticas).
- Nunca usar `service_role`/secret key en el cliente. Solo URL + anon/publishable key.

## Secretos
- No escribir URL/keys en código ni archivos versionados. `.env*` está en `.gitignore`.
- Se leen con `String.fromEnvironment('SUPABASE_URL')` y `SUPABASE_ANON_KEY` en `lib/main.dart`.
- Ejecutar:
  `flutter run -d windows --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<anon_key>`
- Obtener valores locales: `npx supabase status`.

## Dominio y base de datos
- Contexto completo, estados, reglas (RN-03, RN-07, RNF-04) y contrato con la app: `docs/dominio.md`.
  Diagramas originales: `docs/modelo-er.webp` y `docs/casos-de-uso.webp`. Mantener los nombres del E-R.
- Esquema en `supabase/migrations/` (tablas → reglas y RLS). Datos de desarrollo y usuarios de prueba en `supabase/seed.sql` (se aplican con `npx supabase db reset`).
- Roles: cliente, mesero, chef, gerente. La lógica sensible vive en la base (triggers + RPC), no en Flutter.
- Los pedidos se crean con la RPC `crear_pedido`; no hay INSERT directo en `pedido`.
- Fuera de alcance por indicación de la docente: cobros/caja e inventario.
- Al cambiar el esquema: nueva migración (no editar las ya subidas a `main`) y actualizar `docs/dominio.md`.

## Estado de la app (lo ya construido)
- **Un solo login y una sola app para todos** (`features/auth`): campo "Usuario o correo electrónico". Si lleva `@` es el correo de un cliente; si no, es un usuario de personal ("Juan Perez" → `juan.perez@restaurante.local`, ver `core/utils/usuario.dart`, que debe coincidir con `normalizar_usuario()` en SQL). Sin selector de rol: el rol sale de la base (`rol_actual()`).
- **Registro** (`/registro`): solo crea clientes (correo + contraseña). Nunca se envía un rol; el servidor siempre crea "cliente". El dominio `@restaurante.local` está reservado al personal y bloqueado en el registro.
- **Cuentas de personal**: solo el gerente las crea, desde Gerencia → "Nueva cuenta", con la RPC `crear_empleado` (SECURITY DEFINER; escribe en `auth.users` como lo hace el seed). No existe forma de crear empleados desde el registro público.
- **Navegación por rol** (`core/router/destinos.dart`): mesero = Inicio + Reservaciones; chef = Inicio + Cocina; gerente = Inicio + Reservaciones + Cocina + Gerencia; cliente = Inicio + Reservaciones. Tabs bajo el encabezado (se ocultan si hay una sola). Cada ruta está protegida con `AccesoPorRol`, pero eso es solo UX: la seguridad real es RLS/triggers.
- **Inicio**: el personal ve la Comandería (chef y gerente la ven igual; mesero y gerente operan pedidos, pero **solo el mesero y el cliente crean**: el gerente edita/cancela, incluso en preparación o listo). El cliente ve "Mis pedidos" (`features/pedidos/mis_pedidos_screen.dart`, CU-08): la Comandería simplificada, con Folio, Hora, Estado, Total y Acciones de sus pedidos de hoy (sin filtros, buscador ni Mesa/Tipo; usa `PedidosTabla.seguimiento`). Las acciones son "Editar" y "Cancelar", solo en pedidos `pendiente` (RN-03): Editar abre `/pedido/:folio/editar` (la misma comanda, siempre para llevar; ahí también puede cancelar con motivo); Cancelar pide el motivo en `DialogoMotivo` (`features/pedidos/widgets/dialogo_motivo.dart`) y llama a `cancelarPedido`. Paginación de 5, tiempo real y botón "Hacer un pedido". La base (RLS `pedido_select`) ya solo le entrega los suyos. Pruebas en `test/mis_pedidos_test.dart`.
- **Cocina** (`features/cocina`, CU-03/06/15, diseño provisional sin Figma): tablero de 3 columnas (Pendiente / En preparación / Listo) con platillos y notas, panel de avisos de cocina (solo de hoy; nuevo/modificado/cancelado, "Entendido") y tiempo real; el aviso flotante lo da `AvisosCocinaFlotantes` en el marco (solo el chef, en cualquier pestaña; el gerente ve Cocina pero sin aviso flotante). El chef solo hace pendiente→en preparación→listo (lo valida el trigger); reutiliza `PedidoRepository.actualizarEstado`, `BotonConfirmable` (con `etiqueta`), `EstadoChip` y `TiempoChip`. Repositorio propio `CocinaRepository`. Gerente la ve igual.
- **Solicitudes de cambio (RN-03 corregida, sin PIN)** (`features/solicitudes`): el mesero solicita modificar/cancelar un pedido en preparación o listo (`DialogoSolicitud`, "Solicitar cambio" en la Comandería) y el gerente aprueba o rechaza en `PanelSolicitudes` (arriba de su Comandería); aprobar abre 10 minutos de autorización sobre el pedido. `AvisosSolicitudes` (en el marco) avisa al gerente de solicitudes nuevas y al mesero de la respuesta. Estado en `SolicitudesDeHoy`; repositorio `SolicitudRepository`; RPC `solicitar_cambio`/`resolver_solicitud`. Pruebas en `test/solicitudes_test.dart` (`FakeSolicitudRepository`).
- **Gerencia** (diseño provisional sin Figma): selector Reporte | Menú | Mesas | Cuentas | Bitácora (`gerencia_screen.dart`). **Menú** (`menu_admin_view.dart`) y **Mesas** (`mesas_admin_view.dart`): alta, edición, baja y disponibilidad (los repositorios `MenuRepository`/`MesaRepository` ahora escriben; widgets comunes en `widgets/vista_comun.dart`). **Bitácora** (`bitacora_view.dart`, RPC `bitacora_gerencial`). Cuentas ahora también se editan (`EditarCuentaDialog`, RPC `editar_empleado`). Pruebas en `test/administracion_test.dart`. **Reporte** (`reporte_view.dart`, CU-07): periodos hoy/ayer/7/30 días (`PeriodoReporte`, `reporte_providers.dart`), KPIs, pedidos por estado, tipo/origen, top platillos, ventas por día, descuentos y cancelaciones; datos de la RPC `reporte_gerencial` vía `ReporteRepository`. **Cuentas** (`cuentas_view.dart`). Pruebas en `test/reporte_test.dart` (`FakeReporteRepository`).
- **Zoom y escala** (`core/ui/zoom.dart`): escala automática en ventanas > 1500 px lógicos + zoom del usuario (Ctrl +/−/0 o botones del encabezado), guardado en shared_preferences.
- Router (`core/router/app_router.dart`): go_router con ShellRoute y redirect según sesión.
- Comandería (`features/pedidos`): pedidos del día, filtro de estado (por defecto "Activos"), búsqueda, paginación de 5, tiempo real. Tabla de 6 columnas (Folio con el mesero en gris debajo, Hora, Mesa/Tipo, Estado, Total, Acciones); por debajo de 700 px de ancho cada pedido es una tarjeta (`PedidosTabla`). "Registrar" y "Editar" abren la pantalla de comanda; "Ver detalle" abre un modal (`features/pedidos/detalle`) con datos, renglones, notas y desglose de IVA (los precios ya incluyen IVA 16 %: subtotal = total / 1.16, ver `desgloseIva`). Los checks listo→entregado y entregado→completado piden confirmar en una burbuja pequeña (`BotonConfirmable`). **Descuento o cortesía (CU-09):** solo el gerente, desde "Ver detalle" (`DialogoDescuento`: porcentaje —por defecto—, monto o cortesía → `PedidoRepository.aplicarDescuento` → RPC `aplicar_descuento`, que recibe el importe); el modal muestra Subtotal/IVA del pedido sin descuento, el descuento con su motivo y el total. Pruebas en `test/descuentos_test.dart`.
- **Comanda** (`features/pedidos/comanda`): una sola pantalla (`PedidoFormScreen`) para crear, editar (`/pedido/:folio/editar`) y para el pedido en línea del cliente. Estado en `ComandaController` (familia por `esCliente`). Fuera del `ShellRoute`, protegida con `AccesoRoles`: crear (`/pedido/nuevo`) mesero y cliente; editar mesero, gerente y cliente; no chef. Los pedidos en línea muestran el nombre del cliente (`PedidoResumen.nombreCliente`). Detalles y reglas en `docs/dominio.md` ("Menú y comanda").
- **Reservaciones** (`features/reservaciones`): lista (`ReservacionesScreen`) con filtro, confirmar y cancelar, y formulario único (`ReservacionFormDialog`) para crear/modificar. Estado en `ReservacionesLista` (Riverpod). Repositorio `ReservacionRepository`; entidad `Reservacion` con RN-07, `puedeConfirmar` y `sinConfirmar`. Ruta `/reservaciones` dentro del `ShellRoute`, con `AccesoPorRol`. Pruebas en `test/reservaciones_test.dart` con `FakeReservacionRepository` (`test/helpers/fakes_reservaciones.dart`). Los selectores de fecha/hora salen en español (la app fija `locale: es_MX` con `flutter_localizations`). Reglas por rol: solo el cliente crea y confirma (con más de 5 h); el mesero solo consulta; el gerente modifica y cancela, sin crear ni confirmar; el aviso de 5 h es en la app (AvisosReservaciones, montado en ShellAutenticado).
- **Android** (probado en un emulador con la pantalla del POCO X7 Pro, 1220×2712 a 446 dpi, y en el teléfono real): `.\scripts\run_android.ps1` (emulador usa `10.0.2.2`; teléfono real `-Servidor <IP de la laptop>`; el teléfono no puede usar `127.0.0.1`). El manifiesto declara INTERNET (sin él el release no se conecta) y permite HTTP para la base local. En teléfono (< 700 px): Comandería en tarjetas, comanda con barra compacta y barra inferior con el total (`_BarraResumen`), tablas de Gerencia con desplazamiento horizontal (`PanelBlanco.anchoMinimo`) y encabezados que apilan el botón (`SeccionGerencia`). `main.dart` envuelve la app en `_MarcoDelSistema` (espacio para la barra de estado) DENTRO de `EscalaInterfaz`. Pruebas en `test/comanda_telefono_test.dart` y `test/gerencia_telefono_test.dart`.
- Avisos flotantes: `core/ui/toast.dart` (`mostrarToast`). En pruebas, dejar pasar ~5 s con `tester.pump` para que el temporizador termine.
- Seguridad: nunca confiar en la UI para permisos; toda regla va en la base. Las pruebas con teclado/mouse simulados sobre el escritorio están prohibidas (usar `flutter test`).
- Diseño: tema en `core/theme` (paleta amber + navy estimada de las capturas de Figma); marco con encabezado en `presentation/layouts/app_shell.dart`.
- Pruebas: `test/` usa repositorios falsos (`test/helpers/fakes.dart`) con `overrideWithValue`; nunca se conecta a Supabase.
- Consultas con varias FK hacia la misma tabla (p. ej. `pedido`→`empleado`) deben indicar el nombre de la FK: `empleado!pedido_id_empleado_fkey(nombre)`.
- Para probar login a mano: `.\scripts\run_dev.ps1` y usuarios del seed.

## Estructura de lib/
- `core/`: configuración, tema, constantes, utilidades, errores.
- `data/`: repositorios, fuentes de datos (Supabase), DTOs.
- `domain/`: entidades y contratos de repositorio (sin dependencias de Flutter/Supabase).
- `features/<feature>/`: lógica y UI por funcionalidad (providers Riverpod, pantallas).
- `presentation/widgets/`: widgets reutilizables. `presentation/layouts/`: layouts responsivos.

## Convenciones de estado (Riverpod)
- Providers con `@riverpod` (generator). La UI usa `ConsumerWidget`.
- Los widgets no llaman a Supabase directamente: usan repositorios expuestos por providers.

## Contexto del entorno y del equipo
- Proyecto escolar en equipo; repo: https://github.com/Dioxid0/restaurante (rama `main`; **nadie sube directo a `main`**: cada integrante trabaja en su rama personal —`David`, `Cazales`— y entra por Pull Request con CI en verde; merge con "Create a merge commit"). Flujo completo en la sección "Colaboración con Git" del `README.md`. Si el usuario pide subir cambios, hacerlo a su rama, no a `main`.
- Sistema operativo del equipo: Windows. Usar siempre comandos de **PowerShell**.
- Flutter está instalado clonando el SDK en `C:\src\flutter` (winget no tiene paquete oficial). Puede no estar en el PATH de terminales ya abiertas: reabrir la terminal.
- Requiere Modo de desarrollador de Windows activado (symlinks de plugins).
- Docker Desktop debe estar corriendo antes de `npx supabase start`; si no lo está, avisar al usuario y detenerse.
- Supabase CLI se instala localmente con npm (`npx supabase ...`), no globalmente.
- Correr la app: `.\scripts\run_dev.ps1` (lee URL/anon key de `npx supabase status`). Instrucciones completas de incorporación en `README.md`: mantenerlas actualizadas si cambian los pasos.
- Editor del equipo: VS Code (Git desde su panel). Android Studio no es necesario; el SDK de Android se instalará al iniciar la fase móvil.
- `flutter_lints` activo; `custom_lint`/`riverpod_lint` pendientes por incompatibilidad.
- `supabase_flutter` marca `anonKey` como deprecado (usar `publishableKey` si se decide migrar); el proyecto usa por ahora `SUPABASE_ANON_KEY`.
- Las pantallas están diseñadas en Figma; el usuario las irá entregando.
- Antes de instalar software o modificar el sistema, explicar y pedir confirmación al usuario.

## Comandos
- `npx supabase start` / `stop` / `status`; `npx supabase migration new <nombre>`; `npx supabase db reset`.
- `flutter analyze`, `flutter test`.
