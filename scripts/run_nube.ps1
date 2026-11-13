# Corre la app contra Supabase en la NUBE (usa .env.nube.json, creado con configurar_nube.ps1).
# No toca la base local: para volver a la local usa run_dev.ps1 / run_android.ps1.
#
# Uso:
#   .\scripts\run_nube.ps1                          # Windows
#   .\scripts\run_nube.ps1 -Dispositivo <id>        # Android (ids con `flutter devices`)
param([string]$Dispositivo = 'windows')
Set-Location (Split-Path $PSScriptRoot -Parent)

if (-not (Test-Path '.env.nube.json')) {
    Write-Error 'Falta .env.nube.json. Créalo con: .\scripts\configurar_nube.ps1 -Url <url> -Clave <anon-o-publishable>'
    exit 1
}
flutter run -d $Dispositivo '--dart-define-from-file=.env.nube.json'
