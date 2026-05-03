# run_once_before_30-registry.ps1
# Imports WezTerm context menu registry files (per-user, no admin needed)

$ErrorActionPreference = "Continue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$chezmoiRoot = Resolve-Path "$scriptDir\..\.."
$regDir = Join-Path $chezmoiRoot "windows\registry\context-menus\Wezterm"

$regFiles = @(
    "open-with-lazygit.reg",
    "open-with-opencode.reg"
)

if (-not (Test-Path $regDir)) {
    Write-Host "[SKIP] Wezterm reg folder not found: $regDir" -ForegroundColor Yellow
    return
}

foreach ($regFile in $regFiles) {
    $path = Join-Path $regDir $regFile
    if (Test-Path $path) {
        try {
            reg import "$path"
            Write-Host "[OK] Imported: $regFile" -ForegroundColor Green
        } catch {
            Write-Host "[FAIL] Could not import: $regFile - $_" -ForegroundColor Red
        }
    } else {
        Write-Host "[SKIP] Not found: $regFile" -ForegroundColor Yellow
    }
}
