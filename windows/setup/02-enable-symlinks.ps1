$ErrorActionPreference = "Continue"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  ENABLE SYMLINKS (Developer Mode)" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[STOP] This step requires Administrator privileges." -ForegroundColor Red
    Write-Host "Run PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

$devModePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
try {
    if (-not (Test-Path $devModePath)) {
        New-Item -Path $devModePath -Force | Out-Null
    }
    Set-ItemProperty -Path $devModePath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -ErrorAction Stop
    Write-Host "[OK] Developer Mode enabled for symlinks" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Could not enable Developer Mode: $_" -ForegroundColor Red
    exit 1
}

Read-Host "Press Enter to close" | Out-Null
