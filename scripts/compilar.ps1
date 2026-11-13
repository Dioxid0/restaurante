# Compila la versión instalable de la app: .exe de Windows y/o .apk de Android.
# La URL y la llave pública se "hornean" al compilar, así que hay UNA versión por base de datos:
#   -Entorno nube   -> usa .env.nube.json (Supabase en la nube; necesita internet)
#   -Entorno local  -> usa la base local en Docker (funciona SIN internet)
#       * Windows: apunta a 127.0.0.1 (la misma laptop).
#       * Android: el teléfono no puede usar 127.0.0.1; apunta a la IP de esta laptop en la red
#         (o pásala con -Servidor). Teléfono y laptop deben estar en la misma red / punto de acceso.
#
# Salidas (carpeta dist\ , ignorada por Git):
#   dist\windows-<entorno>\            -> carpeta completa; el programa es restaurant_app.exe
#   dist\El-Buen-Sabor-<entorno>.apk
#
# Uso:
#   .\scripts\compilar.ps1 -Entorno nube
#   .\scripts\compilar.ps1 -Entorno local -Plataforma apk -Servidor 192.168.1.74
param(
    [Parameter(Mandatory = $true)][ValidateSet('local', 'nube')][string]$Entorno,
    [ValidateSet('windows', 'apk', 'ambos')][string]$Plataforma = 'ambos',
    [string]$Servidor = ''
)
Set-Location (Split-Path $PSScriptRoot -Parent)
$ErrorActionPreference = 'Stop'

function Obtener-IpLan {
    # IP de la interfaz que usa la ruta por defecto (ignora Docker, Hamachi, etc.).
    $ruta = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Sort-Object RouteMetric | Select-Object -First 1
    if (-not $ruta) { return $null }
    (Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $ruta.InterfaceIndex -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -notmatch '^169\.254' } | Select-Object -First 1).IPAddress
}

function Leer-Local {
    $raw = cmd /c "npx supabase status -o json 2>nul"
    $s = $null
    try { $s = ($raw -join "`n") | ConvertFrom-Json } catch {}
    if (-not $s -or -not $s.ANON_KEY) {
        throw 'Supabase local no está corriendo. Abre Docker Desktop y ejecuta: npx supabase start'
    }
    $s
}

# Define: construye la lista de --dart-define según el entorno y la plataforma.
function Defines($plataforma) {
    if ($Entorno -eq 'nube') {
        if (-not (Test-Path '.env.nube.json')) { throw 'Falta .env.nube.json (usa scripts\configurar_nube.ps1).' }
        return @('--dart-define-from-file=.env.nube.json')
    }
    $s = Leer-Local
    $u = [uri]$s.API_URL
    $host_ = '127.0.0.1'
    if ($plataforma -eq 'apk') {
        $host_ = if ($Servidor) { $Servidor } else { Obtener-IpLan }
        if (-not $host_) { throw 'No pude detectar la IP de la laptop. Pásala con -Servidor 192.168.x.x' }
        Write-Host "APK local: el teléfono se conectará a http://${host_}:$($u.Port)" -ForegroundColor Yellow
    }
    @("--dart-define=SUPABASE_URL=http://${host_}:$($u.Port)", "--dart-define=SUPABASE_ANON_KEY=$($s.ANON_KEY)")
}

New-Item -ItemType Directory -Force dist | Out-Null

if ($Plataforma -in 'windows', 'ambos') {
    Write-Host "== Compilando Windows ($Entorno)..." -ForegroundColor Cyan
    flutter build windows --release @(Defines 'windows')
    if ($LASTEXITCODE -ne 0) { throw 'Falló la compilación de Windows' }
    $destino = "dist\windows-$Entorno"
    if (Test-Path $destino) { Remove-Item $destino -Recurse -Force }
    Copy-Item 'build\windows\x64\runner\Release' $destino -Recurse
    Write-Host "   Listo: $destino\restaurant_app.exe (necesita TODA la carpeta)" -ForegroundColor Green
}

if ($Plataforma -in 'apk', 'ambos') {
    Write-Host "== Compilando Android ($Entorno)..." -ForegroundColor Cyan
    flutter build apk --release @(Defines 'apk')
    if ($LASTEXITCODE -ne 0) { throw 'Falló la compilación del APK' }
    Copy-Item 'build\app\outputs\flutter-apk\app-release.apk' "dist\El-Buen-Sabor-$Entorno.apk" -Force
    Write-Host "   Listo: dist\El-Buen-Sabor-$Entorno.apk" -ForegroundColor Green
}
