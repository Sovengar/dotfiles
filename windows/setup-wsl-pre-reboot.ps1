# setup-wsl-pre-reboot.ps1
# Enables virtualization features required for WSL2.
# MUST be run BEFORE the first chezmoi apply.
# After this script completes, reboot the computer, then run setup-wsl-post-reboot.ps1.

$ErrorActionPreference = "Stop"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  WSL2 Pre-Reboot Setup" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

try {
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform, HypervisorPlatform -All -NoRestart
    Write-Host "[OK] Virtualization features enabled (VirtualMachinePlatform, HypervisorPlatform)." -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT: A reboot is required before proceeding." -ForegroundColor Magenta
    Write-Host "After rebooting, run: .\windows\setup-wsl-post-reboot.ps1" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
} catch {
    Write-Host "[FAIL] Could not enable virtualization features. Run as Administrator." -ForegroundColor Red
    exit 1
}
