# run_once_before_02-configure-wsl2.ps1
# Enables virtualization features and installs WSL2

$ErrorActionPreference = "Continue"

try {
    wsl --update
    Write-Host "[OK] WSL2 updated" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] WSL2 update failed" -ForegroundColor Red
}

try {
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform, HypervisorPlatform -All -NoRestart
    Write-Host "[OK] Virtualization features enabled. Reboot required." -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Could not enable virtualization features" -ForegroundColor Red
}
