# Genera la semilla para la base de la NUBE a partir de supabase/seed.sql, con contraseñas
# nuevas y aleatorias (las del seed local están en el repositorio y NO deben usarse en la nube).
#
# Salida (ambos archivos están en .gitignore, nunca se suben a GitHub):
#   supabase/seed_nube.local.sql   -> se pega en el SQL Editor del panel de Supabase y se ejecuta
#   credenciales-nube.txt          -> usuarios y contraseñas para entrar a la app en la nube
#
# Uso:  .\scripts\preparar_semilla_nube.ps1
# Si ya existe credenciales-nube.txt NO se sobrescribe (para no perder contraseñas ya repartidas);
# bórralo a mano si quieres generar otras.
Set-Location (Split-Path $PSScriptRoot -Parent)

$salidaSql = 'supabase\seed_nube.local.sql'
$salidaCred = 'credenciales-nube.txt'
if ((Test-Path $salidaCred) -or (Test-Path $salidaSql)) {
    Write-Error "Ya existen $salidaCred / $salidaSql. Bórralos si quieres generar contraseñas nuevas."
    exit 1
}

function Nueva-Contrasena {
    # 16 caracteres sin símbolos ambiguos (0/O, 1/l/I) ni comillas, más "-" y "#" para cumplir "mínimo 8" con variedad.
    $letras = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789'.ToCharArray()
    $bytes = New-Object byte[] 16
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $p = -join ($bytes | ForEach-Object { $letras[$_ % $letras.Length] })
    return $p.Substring(0, 5) + '-' + $p.Substring(5, 5) + '#' + $p.Substring(10, 6)
}

$claves = [ordered]@{
    'Mesero#2026'  = Nueva-Contrasena
    'Chef#2026'    = Nueva-Contrasena
    'Gerente#2026' = Nueva-Contrasena
    'Cliente#2026' = Nueva-Contrasena
}

$sql = [System.IO.File]::ReadAllText((Resolve-Path 'supabase\seed.sql'), [System.Text.Encoding]::UTF8)

# 1) Quita el encabezado con las credenciales locales (hasta la primera línea que no es comentario).
$lineas = $sql -split "`r?`n"
$inicio = 0
while ($inicio -lt $lineas.Count -and $lineas[$inicio].StartsWith('--')) { $inicio++ }
$sql = ($lineas[$inicio..($lineas.Count - 1)]) -join "`n"

# 2) Quita el PIN del gerente (ya no se usa; la tabla gerente_pin quedó sin uso).
$sql = [regex]::Replace($sql, "insert into public\.gerente_pin.*?where usuario = 'gerente';\s*", '', 'Singleline')

# 3) Cambia las contraseñas locales por las nuevas.
foreach ($k in $claves.Keys) { $sql = $sql.Replace("'$k'", "'$($claves[$k])'") }
foreach ($k in $claves.Keys) {
    if ($sql.Contains("'$k'")) { Write-Error "No se pudo reemplazar la contraseña $k"; exit 1 }
}

$encabezado = @"
-- =====================================================================
-- Semilla para la NUBE (generada por scripts/preparar_semilla_nube.ps1).
-- Contiene contraseñas: NO la subas a GitHub (está en .gitignore).
-- Ejecútala UNA sola vez en Supabase -> SQL Editor, después de `db push`.
-- =====================================================================

"@
[System.IO.File]::WriteAllText((Join-Path (Get-Location) $salidaSql), $encabezado + $sql, (New-Object System.Text.UTF8Encoding($false)))

$cred = @"
El Buen Sabor - credenciales de la NUBE (no subir a GitHub, no compartir por chat)
Generadas el $(Get-Date -Format 'yyyy-MM-dd HH:mm')

Personal (campo "Usuario o correo electrónico" = el usuario):
  gerente   /  $($claves['Gerente#2026'])
  chef      /  $($claves['Chef#2026'])
  mesero    /  $($claves['Mesero#2026'])     (se muestra como "Juan Pérez")

Cliente de prueba (entra con su correo):
  cliente@correo.com  /  $($claves['Cliente#2026'])
"@
[System.IO.File]::WriteAllText((Join-Path (Get-Location) $salidaCred), $cred, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "Listo." -ForegroundColor Green
# Copia la semilla al portapapeles LEYENDO EN UTF-8 (en Windows PowerShell 5.1, Get-Content sin
# -Encoding lee ANSI y los acentos quedan dañados en la base: "PÃ©rez").
Get-Content $salidaSql -Raw -Encoding UTF8 | Set-Clipboard
Write-Host "  1) La semilla ya está en el portapapeles: pégala en Supabase -> SQL Editor y ejecútala UNA vez."
Write-Host "     (También está en $salidaSql; si la copias a mano usa: Get-Content $salidaSql -Raw -Encoding UTF8 | Set-Clipboard)"
Write-Host "  2) Tus usuarios y contraseñas están en $salidaCred (guárdalo y no lo subas)."
