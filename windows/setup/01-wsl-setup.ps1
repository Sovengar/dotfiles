$ErrorActionPreference = "Continue"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  WSL & PREREQUISITES SETUP" -ForegroundColor Cyan
Write-Host "  Run this BEFORE run-all.ps1" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# ── 1. Virtualization features ──────────────────────────────────────

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
    Write-Host "Reboot now, then run this script again." -ForegroundColor Yellow
    Write-Host "===============================================" -ForegroundColor Magenta
    exit 1
}

Write-Host "[OK] Virtualization features enabled" -ForegroundColor Green

# ── 2. WSL installation ────────────────────────────────────────────

$wslInstalled = Get-Command wsl.exe -ErrorAction SilentlyContinue
if (-not $wslInstalled) {
    Write-Host "[INFO] Installing WSL2 + Ubuntu..." -ForegroundColor Yellow
    wsl --install -d Ubuntu -n
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Magenta
    Write-Host "  REBOOT REQUIRED" -ForegroundColor Magenta
    Write-Host "===============================================" -ForegroundColor Magenta
    Write-Host "WSL installed. Reboot now, then run this script again." -ForegroundColor Yellow
    Write-Host "===============================================" -ForegroundColor Magenta
    exit 1
}
Write-Host "[OK] WSL2 already installed" -ForegroundColor Green

# ── 3. Ubuntu distribution ─────────────────────────────────────────

$wslList = (wsl --list --quiet 2>$null) -replace "\x00", ""
$ubuntuDistro = $wslList | Where-Object { $_ -like "*Ubuntu*" }

$firstInstall = -not $ubuntuDistro
if ($firstInstall) {
    Write-Host "[INFO] Installing Ubuntu distribution..." -ForegroundColor Yellow
    wsl --install -d Ubuntu -n
    Write-Host "[OK] Ubuntu installed" -ForegroundColor Green
} else {
    Write-Host "[OK] Ubuntu already installed" -ForegroundColor Green
}

# ── 4. Ubuntu user creation (first install only) ────────────────────

$userMarker = "$env:USERPROFILE\.wsl-ubuntu-user-created"

if ($firstInstall -or -not (Test-Path $userMarker)) {
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Yellow
    Write-Host "  UBUNTU FIRST-TIME SETUP" -ForegroundColor Yellow
    Write-Host "===============================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ubuntu is installed but needs a user to be created first."
    Write-Host ""
    Write-Host "1. Press Windows key, type 'Ubuntu' and launch it"
    Write-Host "   (or run: wsl -d Ubuntu)"
    Write-Host "2. Wait for 'Installing, this may take a few minutes...'"
    Write-Host "3. Enter a UNIX username and password when prompted"
    Write-Host "4. Type: exit"
    Write-Host "5. Close the Ubuntu window"
    Write-Host ""
    Write-Host "Come back here and press Enter to continue." -ForegroundColor Cyan
    Read-Host "Press Enter to confirm" | Out-Null

    Set-Content -Path $userMarker -Value "done" -NoNewline
    Write-Host "[OK] Ubuntu user setup confirmed" -ForegroundColor Green
} else {
    Write-Host "[OK] Ubuntu user already configured" -ForegroundColor Green
}

# ── 5. Update WSL ─────────────────────────────────────────────────

Write-Host "[INFO] Updating WSL2..." -ForegroundColor Yellow
wsl --update
Write-Host "[OK] WSL2 updated" -ForegroundColor Green

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  WSL SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Next step: run run-all.ps1" -ForegroundColor Yellow

Read-Host "Press Enter to close" | Out-Null
