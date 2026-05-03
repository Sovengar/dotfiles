# setup-wsl-post-reboot.ps1
# Installs/updates WSL2 and the Ubuntu distribution.
# MUST be run AFTER the computer has been rebooted from setup-wsl-pre-reboot.ps1.
# After this script completes, run: chezmoi apply

$ErrorActionPreference = "Continue"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  WSL2 Post-Reboot Setup" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

try {
    wsl --update
    Write-Host "[OK] WSL2 updated" -ForegroundColor Green
} catch {
    Write-Host "[WARN] WSL2 update may require manual attention." -ForegroundColor Yellow
}

try {
    wsl --install -d Ubuntu
    Write-Host "[OK] Ubuntu distribution installed/updated in WSL2." -ForegroundColor Green
} catch {
    Write-Host "[WARN] Ubuntu installation may require manual attention." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "WSL2 setup complete. You can now run: chezmoi apply" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan
