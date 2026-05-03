# run_once_before_20-install-core.ps1
# Installs essential system applications that everyone needs regardless of role.

$ErrorActionPreference = "Continue"

$wingetApps = @(
    "Microsoft.WindowsTerminal",
    "RARLab.WinRAR",
    "Dropbox.Dropbox",
    "Google.GoogleDrive",
    "Microsoft.OneDrive",
    "PuTTY.PuTTY"
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

# OneNote (Microsoft Store)
Write-Host "Abriendo Microsoft Store para OneNote..." -ForegroundColor Yellow
try {
    Start-Process "ms-windows-store://pdp/?productid=9WZDNCRFHVJL"
    Write-Host "Microsoft Store abierta en OneNote. Instala manualmente desde la tienda." -ForegroundColor Green
} catch {
    Write-Host "ERROR abriendo Microsoft Store para OneNote" -ForegroundColor Red
}

Write-Host "Core system apps installation complete." -ForegroundColor Green
