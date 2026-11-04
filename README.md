# Restaurante (proyecto escolar)

Sistema para restaurante: app de escritorio (Windows) primero, móvil (Android) después.
Stack: **Flutter + Supabase** (Supabase corre **local** en Docker durante el desarrollo).

Repositorio: https://github.com/Dioxid0/restaurante

---

## Guía de incorporación (desde cero, Windows 10/11)

Sigue los pasos en orden. Todos los comandos son de **PowerShell**.
Tiempo estimado: 1 a 2 horas, sobre todo por las descargas.

### 0. Requisitos previos
- Windows 10/11 de 64 bits, ~15 GB libres en disco y 8 GB de RAM o más.
- Una cuenta de GitHub y **haber aceptado la invitación** al repositorio
  (pídela a quien administra el repo; llega por correo o en https://github.com/notifications).

### 1. Instalar Git
```powershell
winget install --id Git.Git -e
```
Cierra y abre PowerShell y configura tu identidad (usa el correo de tu cuenta de GitHub):
```powershell
git config --global user.name "Tu Nombre"
git config --global user.email "tu_correo@ejemplo.com"
```

### 2. Instalar Visual Studio Code
```powershell
winget install --id Microsoft.VisualStudioCode -e
```
Extensiones recomendadas (pestaña Extensiones): **Flutter** (instala también Dart),
y opcionalmente **Supabase** / **SQL Formatter**.

### 3. Instalar Node.js (LTS)
```powershell
winget install --id OpenJS.NodeJS.LTS -e
```
Verifica en una terminal nueva: `node --version` y `npm --version`.

### 4. Instalar Docker Desktop
```powershell
winget install --id Docker.DockerDesktop -e
```
Reinicia el equipo si lo pide, **abre Docker Desktop** y espera a que indique que
está corriendo (ícono de ballena estable). Si pide WSL 2, acepta la instalación.
Debe estar abierto siempre que uses Supabase local. Verifica:
```powershell
docker info --format "{{.ServerVersion}}"
```

### 5. Instalar Visual Studio Build Tools (compilar para Windows)
Flutter necesita las herramientas de C++ para compilar apps de escritorio.
```powershell
winget install --id Microsoft.VisualStudio.2022.BuildTools -e --override "--passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```
(Alternativa: instalar Visual Studio 2022 Community y marcar la carga de trabajo
**Desarrollo para el escritorio con C++**.)

### 6. Instalar Flutter
No existe un paquete oficial de Flutter en winget; se clona el SDK:
```powershell
New-Item -ItemType Directory -Force C:\src | Out-Null
git clone https://github.com/flutter/flutter.git -b stable C:\src\flutter
```
Agrega Flutter al PATH de tu usuario:
```powershell
[Environment]::SetEnvironmentVariable('Path', ([Environment]::GetEnvironmentVariable('Path','User').TrimEnd(';') + ';C:\src\flutter\bin'), 'User')
```
**Cierra y abre PowerShell** y verifica:
```powershell
flutter --version
```

### 7. Activar el Modo de desarrollador de Windows
Es obligatorio (los plugins de Flutter usan enlaces simbólicos). Ejecuta:
```powershell
start ms-settings:developers
```
y activa **Modo de desarrollador**.

### 8. Verificar el entorno
```powershell
flutter doctor -v
```
Deben estar en verde **Flutter**, **Windows Version** y **Visual Studio**.
Lo siguiente se puede ignorar por ahora: *Android toolchain* (se instala al empezar la fase móvil) y *Chrome*.

### 9. Clonar el proyecto
```powershell
git clone https://github.com/Dioxid0/restaurante.git C:\ESCUELA\restaurante
cd C:\ESCUELA\restaurante
code .
```
(Puedes clonarlo en otra ruta; evita carpetas dentro de OneDrive.)
La primera vez que hagas `git clone`/`push`, se abrirá el navegador para iniciar sesión en GitHub.

### 10. Instalar dependencias
```powershell
npm install
flutter pub get
```
`npm install` instala la CLI de Supabase (se usa con `npx supabase`) dentro del proyecto.

### 11. Levantar Supabase local
Con Docker Desktop abierto:
```powershell
npx supabase start
```
La primera vez descarga varias imágenes (varios GB) y puede tardar 10 a 20 minutos.
Al terminar muestra las URLs y claves. Para verlas de nuevo:
```powershell
npx supabase status
```
- API: `http://127.0.0.1:54321`
- Studio (panel web de la base de datos): http://127.0.0.1:54323
- Correos de prueba (Mailpit): http://127.0.0.1:54324

Las migraciones de `supabase/migrations/` se aplican automáticamente al iniciar.

### 12. Correr la app
```powershell
.\scripts\run_dev.ps1
```
El script lee la URL y la anon key de `npx supabase status` y ejecuta
`flutter run -d windows` con `--dart-define`. Debe abrirse la pantalla **Iniciar Sesión**. Entra con un usuario de prueba (ver
`supabase/seed.sql`; por ejemplo el del mesero) y deberías ver la **Comandería y Mesas** con
pedidos de ejemplo. Eso confirma que Flutter, Riverpod, Supabase Auth, las migraciones y RLS funcionan.
Si ves "No se pudieron cargar los pedidos", revisa que Supabase esté corriendo
(`npx supabase status`) y que las migraciones y el seed estén aplicados (`npx supabase db reset`).

Si PowerShell bloquea el script ("la ejecución de scripts está deshabilitada"):
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

**Desde VS Code (botón Run / F5):** genera una vez el archivo local de claves (ignorado por Git)
con Supabase corriendo:
```powershell
.\scripts\setup_env.ps1
```
Luego abre **Ejecutar y depurar** (Ctrl+Shift+D), elige **"Restaurante (Windows, Supabase local)"**
y pulsa F5 (o el botón verde). También sirve el botón ▶ sobre `main()` en `lib/main.dart`
solo si agregas el `--dart-define-from-file=.env.json` en `.vscode/launch.json`; usa F5.
Requiere la extensión Flutter instalada. Repite `setup_env.ps1` si reinicias Supabase con claves nuevas.

Manera manual equivalente (sustituye los valores de `npx supabase status`, sin `<` `>`):
```powershell
flutter run -d windows --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_ANON_KEY=PEGA_AQUI_LA_ANON_KEY
```
Con VS Code, el mismo `--dart-define` puede ponerse en `.vscode/launch.json` (args), **sin versionar claves**.

### Usuarios de prueba
La base local trae datos de ejemplo (mesas, menú y 4 usuarios: mesero, chef, gerente y cliente).
Las credenciales están en el encabezado de `supabase/seed.sql`. Para volver al estado inicial:
```powershell
npx supabase db reset
```
Dominio, roles y reglas de negocio: [docs/dominio.md](docs/dominio.md).

### 13. Detener todo al terminar
```powershell
npx supabase stop
```

---

## Flujo de trabajo en equipo

1. Antes de empezar: `git checkout main` y `git pull`.
2. Crea una rama por tarea: `git checkout -b feature/nombre-corto`.
3. Haz commits pequeños con mensajes claros (panel Control de código fuente de VS Code).
4. Sube la rama: `git push -u origin feature/nombre-corto` y abre un **Pull Request** en GitHub.
5. Otro compañero lo revisa y se hace merge a `main`. **No hagas push directo a `main`.**
6. Si cambias el esquema de la base de datos, usa **migraciones** (ver abajo).

### Base de datos (Supabase)
- Todo cambio de esquema va en una migración, nunca solo desde Studio:
  ```powershell
  npx supabase migration new nombre_descriptivo
  ```
  Escribe el SQL en el archivo creado en `supabase/migrations/` y aplícalo con:
  ```powershell
  npx supabase db reset
  ```
  (recrea la base local desde las migraciones; borra los datos locales).
- **Toda tabla debe tener RLS activado** (`alter table ... enable row level security;`) y sus políticas.
- Después de hacer `git pull`, si hay migraciones nuevas, ejecuta `npx supabase db reset`.

### Código generado (Riverpod / freezed / json)
```powershell
dart run build_runner build
```
(o `watch` en lugar de `build` mientras desarrollas).

### Calidad
```powershell
flutter analyze
flutter test
```

## Seguridad: reglas que todos deben cumplir
- **Nunca** subir `.env`, claves ni contraseñas. `.gitignore` ya los bloquea; no lo evadas.
- **Nunca** usar la `service_role`/secret key en la app Flutter. Solo URL + anon key.
- Las claves se pasan con `--dart-define`; no se escriben en el código.

## Estructura
```
lib/
  core/          configuración, tema, constantes, utilidades
  data/          repositorios y fuentes de datos (Supabase)
  domain/        entidades y contratos
  features/      funcionalidades (providers + pantallas)
  presentation/  widgets/ reutilizables y layouts/ responsivos
supabase/        config.toml y migrations/
scripts/         run_dev.ps1
```

## Problemas comunes
| Síntoma | Solución |
|---|---|
| `flutter` no se reconoce | Cierra y abre PowerShell; revisa que `C:\src\flutter\bin` esté en el PATH. |
| "Building with plugins requires symlink support" | Activa el Modo de desarrollador (paso 7). |
| `npx supabase start` falla con error de Docker | Abre Docker Desktop y espera a que esté listo. |
| Puerto 54321/54322/54323 ocupado | `npx supabase stop` y revisa que ningún otro proyecto Supabase esté corriendo. |
| La app lanza "Faltan SUPABASE_URL..." | Corre con `.\scripts\run_dev.ps1` o con los dos `--dart-define`. |
| Error de compilación C++ / MSVC | Falta la carga de trabajo de C++ (paso 5); revisa `flutter doctor -v`. |
| Cambió el esquema tras un `git pull` | `npx supabase db reset`. |
