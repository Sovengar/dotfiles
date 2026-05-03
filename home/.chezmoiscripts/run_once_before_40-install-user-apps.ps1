# run_once_before_40-install-user-apps.ps1
# Installs general user applications (non-essential, non-dev, non-gaming, non-security).

$ErrorActionPreference = "Continue"
$errorFile = "$env:TEMP\chezmoi-install-errors.log"

$wingetApps = @(
    "Bopsoft.Listary",
    "Microsoft.PowerToys",
    "Skillbrains.Lightshot",
    "Discord.Discord",
    "VideoLAN.VLC",
    "AIMP.AIMP",
    "Plex.Plex",
    "BitSum.ProcessLasso",
    "AutoHotkey.AutoHotkey",
    "BartelsMedia.MacroRecorder",
    "cjpais.Handy",
    "flux.flux"
)

foreach ($app in $wingetApps) {
    Write-Host "Installing: $app" -ForegroundColor Cyan
    $proc = Start-Process "winget.exe" -ArgumentList "install -e --id $app --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -PassThru -Wait
    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq -1978335189) {
        Write-Host "  [OK] $app" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $app (ExitCode: $($proc.ExitCode))" -ForegroundColor Red
    }
}

# Raycast (no disponible en winget, abrir pagina de descarga)
Write-Host "Abriendo pagina de descarga de Raycast..." -ForegroundColor Yellow
try {
    Start-Process "https://raycast.com"
    Write-Host "Raycast abierto en el navegador. Descarga e instala la version para Windows." -ForegroundColor Green
} catch {
    Write-Host "ERROR abriendo pagina de Raycast" -ForegroundColor Red
    Add-Content -Path $errorFile -Value "Error abriendo pagina de Raycast"
}

Write-Host "User apps installation complete." -ForegroundColor Green
