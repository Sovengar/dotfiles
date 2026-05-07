# setup-docker-post-apply.ps1
# Configures Docker Desktop to use WSL2 with Ubuntu.
# Run AFTER chezmoi apply.
# Idempotent: skips if Docker WSL integration already configured.

$ErrorActionPreference = "Continue"

function Log($msg, $color = "White") {
    Write-Host "[$(Get-Date -Format HH:mm:ss)] $msg" -ForegroundColor $color
}

$settingsFile = "$env:APPDATA\Docker\settings-store.json"
if (Test-Path $settingsFile) {
    $settings = Get-Content $settingsFile | ConvertFrom-Json
    if ($settings.IntegratedWslDistros -contains "Ubuntu") {
        Log "Docker WSL integration already configured for Ubuntu" "Green"
        Log "Skipping Docker setup" "Yellow"
        exit 0
    }
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
# 4. Configure WSL integration programmatically
# ============================================
$dockerExe = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
if (-not (Test-Path $dockerExe)) {
    Log "Docker Desktop not found at $dockerExe. Install via winget first." "Red"
    exit 1
}

$configured = $false
try {
    $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
    if ($settings.IntegratedWslDistros -notcontains "Ubuntu") {
        $settings.IntegratedWslDistros += "Ubuntu"
    }
    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Force -Encoding utf8
    Log "WSL distro 'Ubuntu' written to Docker settings" "Green"

    Log "Restarting Docker Desktop..." "Yellow"
    Get-Process "Docker Desktop", "Docker" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2
    Start-Process $dockerExe

    Log "Waiting for Docker to be ready..." "Yellow"
    $timeout = 45
    $waited = 0
    while ($waited -lt $timeout) {
        Start-Sleep -Seconds 3
        $waited += 3
        $null = docker ps 2>&1
        if ($LASTEXITCODE -eq 0) {
            Log "Docker Desktop is running" "Green"
            break
        }
    }
    if ($LASTEXITCODE -ne 0) {
        throw "Docker did not come online within ${timeout}s"
    }

    Start-Sleep -Seconds 3
    $null = wsl -d Ubuntu -- docker ps 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not reachable from WSL Ubuntu"
    }
    $configured = $true
    Log "Docker WSL integration verified from WSL Ubuntu" "Green"
} catch {
    Log "Auto-configuration failed: $_" "Red"
}
if (-not $configured) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "   MANUAL STEP REQUIRED" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Docker Desktop may already be open." -ForegroundColor White
    Write-Host "Go to: Settings > Resources > WSL Integration" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Enable:" -ForegroundColor White
    Write-Host "  1. 'Enable integration with my default WSL distro'" -ForegroundColor Green
    Write-Host "  2. 'Ubuntu'" -ForegroundColor Green
    Write-Host ""
    Write-Host "Then Apply & Restart." -ForegroundColor White
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Log "Docker WSL2 setup requires manual config" "Yellow"
}

Log "Docker WSL2 setup complete" "Green"
