$ErrorActionPreference = "Continue"

$regDir = "$PSScriptRoot\registry\context-menus"
$categories = @("VSCode", "Wezterm", "System")

foreach ($category in $categories) {
    $catDir = Join-Path $regDir $category
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
