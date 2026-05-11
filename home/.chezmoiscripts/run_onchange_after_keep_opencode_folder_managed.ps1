$ErrorActionPreference = "Continue"

$opencodePrefix = ".config/opencode/"
$homePath = $env:USERPROFILE

$excludePrefixes = @(
    ".config/opencode/logs/",
    ".config/opencode/.firecrawl"
)

$unmanaged = chezmoi unmanaged 2>$null
if (-not $unmanaged) { exit }

$added = 0
foreach ($path in $unmanaged) {
    if ($path -notlike "$opencodePrefix*") { continue }

    $exclude = $false
    foreach ($prefix in $excludePrefixes) {
        if ($path -like "$prefix*") { $exclude = $true; break }
    }
    if ($exclude) { continue }

    $fullPath = Join-Path $homePath $path
    if (Test-Path $fullPath) {
        $result = chezmoi add "$fullPath" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [MANAGED] $path" -ForegroundColor Green
            $added++
        }
    }
}

if ($added -gt 0) {
    Write-Host "Keep opencode managed: $added file(s) added to chezmoi" -ForegroundColor Green
}
else {
    Write-Host "Keep opencode managed: nothing to add" -ForegroundColor Gray
}
