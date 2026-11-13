# Corre la app en Android contra Supabase local.
# El teléfono/emulador NO puede usar 127.0.0.1 (ahí "localhost" es el propio teléfono):
#   * Emulador de Android Studio -> 10.0.2.2 (alias del equipo anfitrión). Es el valor por defecto.
#   * Teléfono real (USB o Wi-Fi) -> la IP de esta laptop en la red compartida: -Servidor 192.168.x.x
#     (con `ipconfig` ves la "Dirección IPv4"; el teléfono y la laptop deben estar en la misma red,
#      o la laptop conectada al punto de acceso del teléfono).
# Lee la anon key de `npx supabase status` (no se guarda en ningún archivo).
#
# Uso:
#   .\scripts\run_android.ps1                              # emulador
#   .\scripts\run_android.ps1 -Servidor 192.168.1.50       # teléfono real
#   .\scripts\run_android.ps1 -Dispositivo emulator-5554   # elegir dispositivo (flutter devices)
param(
    [string]$Servidor = '10.0.2.2',
    [string]$Dispositivo = ''
)
Set-Location (Split-Path $PSScriptRoot -Parent)

$ErrorActionPreference = 'Continue'
$raw = cmd /c "npx supabase status -o json 2>nul"
$s = $null
try { $s = ($raw -join "`n") | ConvertFrom-Json } catch {}

if (-not $s -or -not $s.ANON_KEY) {
    Write-Error 'Supabase local no está corriendo. Abre Docker Desktop y ejecuta: npx supabase start'
    exit 1
}

# Cambia el host de la URL local (127.0.0.1) por el que alcanza el teléfono, conservando el puerto.
$url = ([uri]$s.API_URL)
$urlMovil = '{0}://{1}:{2}' -f $url.Scheme, $Servidor, $url.Port

$args = @('run')
if ($Dispositivo) { $args += @('-d', $Dispositivo) }
$args += @("--dart-define=SUPABASE_URL=$urlMovil", "--dart-define=SUPABASE_ANON_KEY=$($s.ANON_KEY)")
Write-Host "Conectando a $urlMovil"
flutter @args
