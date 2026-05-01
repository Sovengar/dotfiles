# Apply Windows Registry Files
# Run as Administrator for system-wide registry changes

$ErrorActionPreference = "Stop"
$RegistryDir = Join-Path $PSScriptRoot "context-menus"

function Apply-RegFile {
    param([string]$Path)
    Write-Host "Applying: $Path" -ForegroundColor Cyan
    $process = Start-Process -FilePath "reg.exe" -ArgumentList "import", "`"$Path`"" -Wait -PassThru -NoNewWindow
    if ($process.ExitCode -eq 0) {
        Write-Host "  [OK]" -ForegroundColor Green
    } else {
        Write-Host "  [FAILED] Exit code: $($process.ExitCode)" -ForegroundColor Red
    }
}

Write-Host "=== Applying WezTerm Context Menus ===" -ForegroundColor Yellow
Get-ChildItem -Path "$RegistryDir\Wezterm" -Filter "*.reg" | ForEach-Object { Apply-RegFile $_.FullName }

Write-Host "`n=== Applying Windows Terminal Context Menus ===" -ForegroundColor Yellow
Get-ChildItem -Path "$RegistryDir\WindowsTerminal" -Filter "*.reg" | ForEach-Object { Apply-RegFile $_.FullName }

Write-Host "`n=== Applying Removers (if needed) ===" -ForegroundColor Yellow
Write-Host "Skipped. Run individual files from Removers\ if you want to remove context menus." -ForegroundColor DarkGray

Write-Host "`nDone!" -ForegroundColor Green
