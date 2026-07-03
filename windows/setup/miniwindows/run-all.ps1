#Requires -Version 7.0
# MiniWindows Setup - Microsoft 365 Apps for the WinApps VM
# Run this inside the Windows VM after first boot.
#
# From PowerShell inside the VM:
#   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
#   C:\shared\setup-mini\run-all.ps1

. "$PSScriptRoot\lib.ps1"
$ErrorActionPreference = "Continue"
Reset-SetupLog

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  MiniWindows Setup for Microsoft 365" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

Run-Step "$PSScriptRoot\10-install-office.ps1"
Run-Step "$PSScriptRoot\20-configure-startup.ps1"
Run-Step "$PSScriptRoot\30-configure-rdp.ps1"

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  MiniWindows Setup Complete!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Sign in to Microsoft 365 when Office apps launch" -ForegroundColor White
Write-Host "  2. Close the RDP window - VM will auto-start next time" -ForegroundColor White
Write-Host ""

Show-SetupLog