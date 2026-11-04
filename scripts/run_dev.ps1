# Corre la app en Windows contra Supabase local.
# Lee la URL y la anon key de `npx supabase status` (no se guardan en ningún archivo).
# Uso:  .\scripts\run_dev.ps1
Set-Location (Split-Path $PSScriptRoot -Parent)

# `supabase status` escribe avisos informativos en stderr; en PowerShell 5.1 eso no debe tratarse como error.
$ErrorActionPreference = 'Continue'
$raw = cmd /c "npx supabase status -o json 2>nul"
$s = $null
try { $s = ($raw -join "`n") | ConvertFrom-Json } catch {}

if (-not $s -or -not $s.ANON_KEY) {
    Write-Error 'Supabase local no está corriendo. Abre Docker Desktop y ejecuta: npx supabase start'
    exit 1
}

flutter run -d windows "--dart-define=SUPABASE_URL=$($s.API_URL)" "--dart-define=SUPABASE_ANON_KEY=$($s.ANON_KEY)"
