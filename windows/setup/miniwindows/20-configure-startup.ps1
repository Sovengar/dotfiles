#Requires -Version 7.0
# Configure startup items for a lightweight VM experience

. "$PSScriptRoot\lib.ps1"

Write-Host "Configuring startup for lightweight VM usage..." -ForegroundColor Cyan

# Disable unnecessary Windows services for VM performance
$servicesToDisable = @(
    "SysMain"          # Superfetch - not needed in VM
    "WSearch"         # Windows Search indexer - saves disk I/O
    "DiagTrack"       # Connected User Experiences - telemetry
    "dmwappushservice" # WAP Push - telemetry
)

foreach ($svc in $servicesToDisable) {
    try {
        $svcObj = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($svcObj -and $svcObj.Status -ne 'Stopped') {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "  [OK] Disabled: $svc" -ForegroundColor Green
        } elseif ($svcObj) {
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "  [OK] Already stopped, disabled: $svc" -ForegroundColor Green
        }
    } catch {
        Write-Host "  [SKIP] Could not disable: $svc" -ForegroundColor Yellow
    }
}

# Disable Windows Defender real-time for VM performance (optional, at your own risk)
# Set-MpPreference -DisableRealtimeMonitoring $true

# Set power plan to High Performance
try {
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    Write-Host "  [OK] Power plan set to High Performance" -ForegroundColor Green
} catch {
    Write-Host "  [SKIP] Could not set power plan" -ForegroundColor Yellow
}

# Disable hibernation to save disk space
try {
    powercfg /hibernate off 2>$null
    Write-Host "  [OK] Hibernation disabled (saves disk space)" -ForegroundColor Green
} catch {
    Write-Host "  [SKIP] Could not disable hibernation" -ForegroundColor Yellow
}

# Create a shortcut folder for Office apps on the shared drive
$sharedDir = "C:\shared"
if (Test-Path $sharedDir) {
    Write-Host "  [OK] Shared folder available at $sharedDir" -ForegroundColor Green
} else {
    Write-Host "  [INFO] Shared folder not found at $sharedDir" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Startup configuration complete." -ForegroundColor Green