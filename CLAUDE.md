# Sistema de restaurante (proyecto escolar)

## Stack y decisiones
- Flutter (Dart) + Supabase. Paquete `restaurant_app`, org `com.escuela`.
- Estado: Riverpod (`flutter_riverpod`, `riverpod_annotation` + `riverpod_generator`).
- Navegación: `go_router`. Modelos: `freezed` + `json_serializable`.
- Código generado con `dart run build_runner build --delete-conflicting-outputs`.
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

## Estructura de lib/
- `core/`: configuración, tema, constantes, utilidades, errores.
- `data/`: repositorios, fuentes de datos (Supabase), DTOs.
- `domain/`: entidades y contratos de repositorio (sin dependencias de Flutter/Supabase).
- `features/<feature>/`: lógica y UI por funcionalidad (providers Riverpod, pantallas).
- `presentation/widgets/`: widgets reutilizables. `presentation/layouts/`: layouts responsivos.

## Convenciones de estado (Riverpod)
- Providers con `@riverpod` (generator). La UI usa `ConsumerWidget`.
- Los widgets no llaman a Supabase directamente: usan repositorios expuestos por providers.

## Comandos
- `npx supabase start` / `stop` / `status`; `npx supabase migration new <nombre>`; `npx supabase db reset`.
- `flutter analyze`, `flutter test`.
