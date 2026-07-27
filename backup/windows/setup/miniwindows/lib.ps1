# MiniWindows Setup - Helper functions

$script:SetupLogFile = "$env:TEMP\miniwindows-setup-summary.txt"

function Add-SetupLog {
    param([string]$Message)
    $line = "[$(Get-Date -Format HH:mm:ss)] $Message"
    Add-Content -Path $script:SetupLogFile -Value $line -Encoding UTF8
}

function Show-SetupLog {
    if (Test-Path $script:SetupLogFile) {
        Write-Host ""
        Write-Host "Setup log saved to: $script:SetupLogFile" -ForegroundColor Cyan
    }
}

function Reset-SetupLog {
    if (Test-Path $script:SetupLogFile) {
        Remove-Item $script:SetupLogFile -Force
    }
}

function Run-Step {
    param([string]$Path)
    $scriptName = Split-Path $Path -Leaf
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "  Running: $scriptName" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    & $Path
    if (-not $?) {
        Write-Host "[STOP] $Path failed" -ForegroundColor Red
        Add-SetupLog -Message "[FAIL] $scriptName"
    } else {
        Add-SetupLog -Message "[OK] $scriptName"
    }
}

function Install-WingetAppSilent {
    param([string]$AppId)
    Write-Host "  Installing: $AppId" -ForegroundColor Cyan
    winget install -e --id $AppId --source winget --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) {
        Write-Host "  [OK] $AppId" -ForegroundColor Green
        return $true
    }
    Write-Host "  [FAIL] $AppId (Exit: $LASTEXITCODE)" -ForegroundColor Red
    return $false
}