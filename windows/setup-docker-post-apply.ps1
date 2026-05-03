# setup-docker-post-apply.ps1
# Configures Docker Desktop to use WSL2 with Ubuntu.
# Run AFTER chezmoi apply on a freshly formatted machine.
# NOTE: This is part of the FORMATEO flow, not the dotfiles flow.

$ErrorActionPreference = "Continue"

function Log($msg, $color = "White") {
    Write-Host "[$(Get-Date -Format HH:mm:ss)] $msg" -ForegroundColor $color
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Docker Desktop WSL2 Setup" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 1. Verify WSL is installed
# ============================================
$null = wsl.exe --status 2>&1
if ($LASTEXITCODE -ne 0) {
    Log "WSL is not installed or not responding. Run setup-wsl-post-reboot.ps1 first." "Red"
    exit 1
}
Log "WSL detected" "Green"

# ============================================
# 2. Verify Ubuntu is installed
# ============================================
$distros = wsl.exe --list --quiet | Where-Object { $_.Trim() -ne "" }
$ubuntuInstalled = $distros | Where-Object { $_.Trim().ToLower().StartsWith("ubuntu") }

if (-not $ubuntuInstalled) {
    Log "Ubuntu not found in WSL. Distros found: $($distros -join ', ')" "Red"
    exit 1
}
Log "Ubuntu detected: $($ubuntuInstalled.Trim())" "Green"

# ============================================
# 3. Ensure Ubuntu uses WSL2
# ============================================
$line = wsl.exe --list --verbose | ForEach-Object {
    if ($_.IndexOf("Ubuntu") -ge 0) { $_ }
}

if ($line) {
    $version = ($line.Trim() -split '\s+')[-1]
    if ($version -eq "2") {
        Log "Ubuntu is already on WSL2" "Green"
    } else {
        Log "Switching Ubuntu to WSL2 (current version: $version)..." "Yellow"
        wsl.exe --set-version Ubuntu 2
        Log "Ubuntu now using WSL2" "Green"
    }
} else {
    Log "Could not determine Ubuntu WSL version in 'wsl --list --verbose'" "Red"
    exit 1
}

# ============================================
# 4. Launch Docker Desktop
# ============================================
$dockerExe = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
if (Test-Path $dockerExe) {
    Log "Opening Docker Desktop..." "Yellow"
    Get-Process "Docker Desktop" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process "Docker" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 1
    Start-Process $dockerExe
    Start-Sleep -Seconds 3
    Log "Docker Desktop launched" "Green"
} else {
    Log "Docker Desktop not found at $dockerExe. Install via winget first." "Red"
    exit 1
}

# ============================================
# 5. Manual instructions for WSL integration
# ============================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   MANUAL STEP REQUIRED" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "In Docker Desktop, go to:" -ForegroundColor White
Write-Host "  Settings > Resources > WSL Integration" -ForegroundColor Yellow
Write-Host ""
Write-Host "Enable:" -ForegroundColor White
Write-Host "  1. 'Enable integration with my default WSL distro'" -ForegroundColor Green
Write-Host "  2. 'Ubuntu'" -ForegroundColor Green
Write-Host ""
Write-Host "Then Apply & Restart." -ForegroundColor White
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Log "Docker WSL2 setup complete" "Green"
