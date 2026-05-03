# run_once_before_45-install-gaming-apps.ps1
# Installs gaming-related applications.

$ErrorActionPreference = "Continue"

$wingetApps = @(
    "Valve.Steam",
    "Valve.SteamLink",
    "Guru3D.Afterburner",
    "Guru3D.RTSS",
    "Reshade.Setup.AddonsSupport"
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

Write-Host "Gaming apps installation complete." -ForegroundColor Green
