# run_once_after_30-startup-shortcuts.ps1
# Copies startup shortcuts from Dropbox

$startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\StartUp"
$shortcuts = @(
    @{ Source = "$HOME\Dropbox\Programs\Mechvibes.lnk"; Name = "Mechvibes" },
    @{ Source = "$HOME\Dropbox\Programs\z Boilerplate\TaskbarX.lnk"; Name = "TaskbarX" }
)

foreach ($sc in $shortcuts) {
    if (Test-Path $sc.Source) {
        Copy-Item -Path $sc.Source -Destination $startupFolder -Force
        Write-Host "[OK] Startup shortcut: $($sc.Name)" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] Not found: $($sc.Source)" -ForegroundColor Yellow
    }
}
