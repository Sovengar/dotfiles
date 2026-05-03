# run_once_before_30-registry.ps1
# Imports context menu registry files (per-user, no admin needed)

$ErrorActionPreference = "Continue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$chezmoiRoot = Resolve-Path "$scriptDir\..\.."
$contextMenusDir = Join-Path $chezmoiRoot "windows\registry\context-menus"

$categories = @("Wezterm", "System")

foreach ($category in $categories) {
    $catDir = Join-Path $contextMenusDir $category
    if (-not (Test-Path $catDir)) { continue }

    $regFiles = Get-ChildItem -Path $catDir -Filter "*.reg" -File
    foreach ($regFile in $regFiles) {
        try {
            reg import "$($regFile.FullName)"
            Write-Host "[OK] Imported: $($regFile.Name)" -ForegroundColor Green
        } catch {
            Write-Host "[FAIL] Could not import: $($regFile.Name) - $_" -ForegroundColor Red
        }
    }
}
