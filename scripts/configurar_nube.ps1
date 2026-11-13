# Guarda la URL y la llave PÚBLICA (anon / publishable) de tu proyecto de Supabase en la nube
# en .env.nube.json (ignorado por Git). Es lo único que la app necesita para conectarse.
#
# Dónde se ven: panel de Supabase -> Project Settings -> API (o "Connect"):
#   * Project URL            ->  https://xxxxxxxx.supabase.co
#   * anon / publishable key ->  (la pública). NUNCA uses la "service_role" / "secret".
#
# Uso:  .\scripts\configurar_nube.ps1 -Url https://xxxx.supabase.co -Clave <anon-o-publishable>
param(
    [Parameter(Mandatory = $true)][string]$Url,
    [Parameter(Mandatory = $true)][string]$Clave
)
Set-Location (Split-Path $PSScriptRoot -Parent)

if ($Url -notmatch '^https://[a-z0-9-]+\.supabase\.co/?$') {
    Write-Error 'La URL debe verse como https://xxxxxxxx.supabase.co'
    exit 1
}
if ($Clave -match 'service_role' -or $Clave -like 'sb_secret_*') {
    Write-Error 'Esa es una llave SECRETA. Usa la anon / publishable (pública).'
    exit 1
}
# Si es un JWT, comprueba que su rol sea "anon" (una service_role también empieza con eyJ...).
if ($Clave -like 'eyJ*') {
    try {
        $payload = $Clave.Split('.')[1].Replace('-', '+').Replace('_', '/')
        while ($payload.Length % 4) { $payload += '=' }
        $rol = ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload)) | ConvertFrom-Json).role
        if ($rol -ne 'anon') { Write-Error "La llave tiene rol '$rol'. Debe ser la 'anon' (pública)."; exit 1 }
    } catch { }
}

@{ SUPABASE_URL = $Url.TrimEnd('/'); SUPABASE_ANON_KEY = $Clave } |
    ConvertTo-Json | Set-Content -Path '.env.nube.json' -Encoding UTF8
Write-Host 'Guardado en .env.nube.json (ignorado por Git).' -ForegroundColor Green
