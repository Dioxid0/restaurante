# Genera .env.json (ignorado por Git) con la URL y anon key de Supabase local.
# VS Code lo usa vía --dart-define-from-file. Ejecutar una vez, y de nuevo si cambian las claves.
# Uso:  .\scripts\setup_env.ps1
Set-Location (Split-Path $PSScriptRoot -Parent)

$ErrorActionPreference = 'Continue'
$raw = cmd /c "npx supabase status -o json 2>nul"
$s = $null
try { $s = ($raw -join "`n") | ConvertFrom-Json } catch {}

if (-not $s -or -not $s.ANON_KEY) {
    Write-Error 'Supabase local no está corriendo. Abre Docker Desktop y ejecuta: npx supabase start'
    exit 1
}

@{ SUPABASE_URL = $s.API_URL; SUPABASE_ANON_KEY = $s.ANON_KEY } |
    ConvertTo-Json | Set-Content -Path .env.json -Encoding utf8
Write-Host 'Listo: .env.json creado (no se versiona).'
