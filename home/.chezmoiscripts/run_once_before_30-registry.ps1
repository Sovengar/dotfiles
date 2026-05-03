# run_once_after_20-registry.ps1
# Imports registry files for context menus

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoRoot = Split-Path -Parent $scriptDir
$regDir = Join-Path $repoRoot "registry"

$regFiles = @(
    "RunWithPwsh7.reg",
    "RunWithPwsh7Admin.reg",
    "open-with-lazygit.reg",
    "open-with-opencode.reg"
)

foreach ($regFile in $regFiles) {
    $path = Join-Path $regDir $regFile
    if (Test-Path $path) {
        try {
            reg import "$path"
            Write-Host "[OK] Imported: $regFile" -ForegroundColor Green
        } catch {
            Write-Host "[FAIL] Could not import: $regFile" -ForegroundColor Red
        }
    } else {
        Write-Host "[SKIP] Not found: $regFile" -ForegroundColor Yellow
    }
}
