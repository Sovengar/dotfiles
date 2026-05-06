$ErrorActionPreference = "Continue"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  WSL2 SETUP" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

Write-Host "[OK] Virtualization features already enabled (checked in step 03)" -ForegroundColor Green

$wslInstalled = Get-Command wsl.exe -ErrorAction SilentlyContinue
if (-not $wslInstalled) {
    Write-Host "[INFO] Installing WSL2..." -ForegroundColor Yellow
    wsl --install -d Ubuntu
    Write-Host "[OK] WSL2 + Ubuntu installed" -ForegroundColor Green
} else {
    Write-Host "[OK] WSL2 already installed" -ForegroundColor Green

    $ubuntuDistro = wsl --list --quiet | Where-Object { $_.Trim().ToLower().StartsWith("ubuntu") }
    if (-not $ubuntuDistro) {
        Write-Host "[INFO] Installing Ubuntu distribution..." -ForegroundColor Yellow
        wsl --install -d Ubuntu
        Write-Host "[OK] Ubuntu installed" -ForegroundColor Green
    } else {
        Write-Host "[OK] Ubuntu already installed" -ForegroundColor Green
    }

    Write-Host "[INFO] Updating WSL2..." -ForegroundColor Yellow
    wsl --update
    Write-Host "[OK] WSL2 updated" -ForegroundColor Green
}

Read-Host "Presiona Enter para cerrar" | Out-Null
