# run_once_before_40-install-user-apps.ps1
# Installs general user applications (non-essential, non-dev, non-gaming, non-security).

$ErrorActionPreference = "Continue"

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

Write-Host "User apps installation complete." -ForegroundColor Green
