$ErrorActionPreference = "Continue"

$response = Read-Host "Restore Listary Preferences.json? (y/n)"
if ($response -notmatch '^[yY]') {
    Write-Host "[SKIP] Listary config — user declined" -ForegroundColor Yellow
    exit 0
}

$src = "$PSScriptRoot\Listary\Preferences.json"
$dst = "$env:APPDATA\Listary\UserProfile\Settings\Preferences.json"

if (-not (Test-Path $src)) {
    Write-Host "[FAIL] Source not found: $src" -ForegroundColor Red
    exit 1
}

$dstDir = Split-Path $dst -Parent
while (-not (Test-Path $dstDir)) {
    Write-Host "[WARN] Listary no instalado? No se encuentra: $dstDir" -ForegroundColor Yellow
    $retry = Read-Host "Reintentar (r) o saltar (s)? (r/s)"
    if ($retry -notmatch '^[rR]') {
        Write-Host "[SKIP] Listary config — Listary no instalado" -ForegroundColor Yellow
        exit 0
    }
}

Copy-Item -Path $src -Destination $dst -Force
Write-Host "[OK] Listary Preferences.json restored" -ForegroundColor Green
