$ErrorActionPreference = "Continue"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  ENABLE SYMLINKS (Developer Mode)" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

$devModePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
try {
    if (-not (Test-Path $devModePath)) {
        New-Item -Path $devModePath -Force | Out-Null
    }
    Set-ItemProperty -Path $devModePath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -ErrorAction Stop
    Write-Host "[OK] Developer Mode enabled for symlinks" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Could not enable Developer Mode (requires admin). Symlinks may fail." -ForegroundColor Yellow
}

Read-Host "Press Enter to close" | Out-Null
