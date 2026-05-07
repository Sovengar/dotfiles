. "$PSScriptRoot\..\lib.ps1"
$ErrorActionPreference = "Continue"

if (-not (Confirm-Step "Install startup shortcuts (Mechvibes, TaskbarX)")) {
    Write-Host "[SKIP] Startup shortcuts — user declined" -ForegroundColor Yellow
    exit 0
}

$shortcuts = @(
    @{ Source = "$HOME\Dropbox\Programs\Mechvibes.lnk"; Name = "Mechvibes" },
    @{ Source = "$HOME\Dropbox\Programs\z Boilerplate\TaskbarX.lnk"; Name = "TaskbarX" }
)

$allMissing = $true
while ($allMissing) {
    $allMissing = $true
    foreach ($sc in $shortcuts) {
        if (Test-Path $sc.Source) {
            $allMissing = $false
            break
        }
    }
    if ($allMissing) {
        Write-Host "[WARN] Dropbox not synced? Ningún shortcut encontrado en Dropbox" -ForegroundColor Yellow
        $retry = Read-Host "Reintentar (r) o saltar (s)? (r/s)"
        if ($retry -notmatch '^[rR]') {
            Write-Host "[SKIP] Startup shortcuts — dependencias no disponibles" -ForegroundColor Yellow
            exit 0
        }
    }
}

$startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\StartUp"
foreach ($sc in $shortcuts) {
    if (Test-Path $sc.Source) {
        Copy-Item -Path $sc.Source -Destination $startupFolder -Force
        Write-Host "[OK] Startup shortcut: $($sc.Name)" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] Not found: $($sc.Source)" -ForegroundColor Yellow
    }
}
