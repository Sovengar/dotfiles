$ErrorActionPreference = "Continue"

function Run-Step {
    param([string]$Path)
    & $Path
    if (-not $?) {
        Write-Host "[STOP] $Path failed — fix the issue and run again" -ForegroundColor Red
        exit 1
    }
}

Run-Step "$PSScriptRoot\00-env-vars.ps1"
Run-Step "$PSScriptRoot\10-install-packages.ps1"
Run-Step "$PSScriptRoot\20-configure-system.ps1"
Run-Step "$PSScriptRoot\personal\ssh-client-setup.ps1"
Run-Step "$PSScriptRoot\personal\setup-ssh-server.ps1"
Run-Step "$PSScriptRoot\personal\startup-shortcuts.ps1"
Run-Step "$PSScriptRoot\personal\setup-listary.ps1"
Run-Step "$PSScriptRoot\30-setup-registry.ps1"
Run-Step "$PSScriptRoot\35-setup-auth.ps1"

$dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue
if ($dockerInstalled) {
    Run-Step "$PSScriptRoot\40-setup-docker.ps1"
} else {
    Write-Host "  [WARN] Docker not installed — skipping Docker setup" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  ALL SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Next step: chezmoi apply --verbose" -ForegroundColor Yellow

