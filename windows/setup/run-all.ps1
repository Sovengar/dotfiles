. "$PSScriptRoot\lib.ps1"
$ErrorActionPreference = "Continue"
Reset-SetupLog

# --- Setup Memory ---
$global:SetupMemory = Get-SetupMemory
if ($global:SetupMemory) {
    $lastRun = $global:SetupMemory.last_run
    Write-Host "[MEMORY] Se encontraron decisiones previas (ultima ejecucion: $lastRun)" -ForegroundColor Cyan
    $reuse = Read-Host "Aplicar las mismas decisiones? [y/N]"
    if ($reuse -match '^[yY]') {
        Write-Host "[MEMORY] Reutilizando decisiones anteriores" -ForegroundColor Green
    } else {
        $global:SetupMemory = Initialize-SetupMemory
    }
} else {
    $global:SetupMemory = Initialize-SetupMemory
}

function Run-Step {
    param([string]$Path)
    $scriptName = Split-Path $Path -Leaf

    if ($global:SetupMemory.scripts.$scriptName -eq "skipped") {
        Add-SetupLog -Message "[SKIP] $scriptName (reusing previous decision)"
        Write-Host "  [SKIP] $scriptName — reusing previous decision" -ForegroundColor Yellow
        return
    }

    & $Path
    if (-not $?) {
        Write-Host "[STOP] $Path failed — fix the issue and run again" -ForegroundColor Red
        exit 1
    }

    if (-not $global:SetupMemory.scripts.$scriptName) {
        Set-ScriptMemory -ScriptName $scriptName -Status "done"
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
    Add-SetupLog -Message "[SKIP] Docker setup (Docker not installed)"
    Write-Host "  [WARN] Docker not installed — skipping Docker setup" -ForegroundColor Yellow
}

# --- Save Memory ---
$global:SetupMemory.last_run = (Get-Date -Format o)
Save-SetupMemory -Memory $global:SetupMemory

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  ALL SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Next step: chezmoi apply --verbose" -ForegroundColor Yellow
Write-Host "OpenCode Mobile: https://termly.dev/blog/opencode-mobile-setup-guide" -ForegroundColor Magenta

Show-SetupLog

