$ErrorActionPreference = "Continue"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  PREREQUISITES COMPLIANCE — WSL/Virtualization" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

$vmp = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction SilentlyContinue
$hp = Get-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -ErrorAction SilentlyContinue

$pending = ($vmp.State -eq "EnabledPendingReboot" -or $hp.State -eq "EnabledPendingReboot")
$enabled = ($vmp.State -eq "Enabled" -and $hp.State -eq "Enabled")

if ($pending) {
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Magenta
    Write-Host "  REBOOT REQUIRED" -ForegroundColor Magenta
    Write-Host "===============================================" -ForegroundColor Magenta
    Write-Host "Virtualization features are queued but not active." -ForegroundColor White
    Write-Host "Reboot now, then run this script again." -ForegroundColor Yellow
    Write-Host "===============================================" -ForegroundColor Magenta
    exit 1
}

if (-not $enabled) {
    Write-Host "[INFO] Enabling virtualization features..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform, HypervisorPlatform -All -NoRestart
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Magenta
    Write-Host "  REBOOT REQUIRED" -ForegroundColor Magenta
    Write-Host "===============================================" -ForegroundColor Magenta
    Write-Host "Virtualization features enabled and pending activation." -ForegroundColor White
    Write-Host "Reboot now, then run this script again to continue." -ForegroundColor Yellow
    Write-Host "===============================================" -ForegroundColor Magenta
    exit 1
}

Write-Host "[OK] Virtualization features enabled" -ForegroundColor Green

Read-Host "Presiona Enter para cerrar" | Out-Null
