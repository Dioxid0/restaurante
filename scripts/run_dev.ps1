# Corre la app en Windows contra Supabase local.
# Lee la URL y la anon key de `npx supabase status` (no se guardan en ningún archivo).
# Uso:  .\scripts\run_dev.ps1
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

$s = npx supabase status -o json 2>$null | ConvertFrom-Json
if (-not $s.ANON_KEY) { throw 'Supabase local no está corriendo. Ejecuta: npx supabase start' }

flutter run -d windows "--dart-define=SUPABASE_URL=$($s.API_URL)" "--dart-define=SUPABASE_ANON_KEY=$($s.ANON_KEY)"
