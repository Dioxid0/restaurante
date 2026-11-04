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
- Login (`features/auth`): usuario + contraseña → Supabase Auth con `usuario@restaurante.local`. Solo entran empleados (si la cuenta no está en `empleado`, se cierra la sesión). Sin selector de rol: el rol sale de la base.
- Router (`core/router/app_router.dart`): go_router con redirect según sesión. `/` (Home) elige la pantalla por rol: mesero → Comandería; chef y gerente → "en construcción".
- Comandería del mesero (`features/pedidos`): pedidos del día, filtro de estado (por defecto "Activos"), búsqueda, paginación de 5, tiempo real. "Registrar", "Editar" y "Ver detalle" son stubs hasta recibir esas pantallas de Figma.
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
- Proyecto escolar en equipo; repo: https://github.com/Dioxid0/restaurante (rama `main`, trabajo por ramas + Pull Request; no push directo a `main`).
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
