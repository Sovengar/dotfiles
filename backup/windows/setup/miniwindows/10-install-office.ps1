#Requires -Version 7.0
# Install Microsoft 365 Apps (Word, Excel, PowerPoint, OneNote, Outlook)

. "$PSScriptRoot\lib.ps1"

Write-Host "Installing Microsoft 365 Apps..." -ForegroundColor Cyan

# Winget install for Microsoft 365
# This installs Word, Excel, PowerPoint, OneNote, Outlook
$officeResult = Install-WingetAppSilent -AppId "Microsoft.Office"

if (-not $officeResult) {
    Write-Host ""
    Write-Host "[FALLBACK] Winget install failed. Trying Microsoft Store..." -ForegroundColor Yellow

    # Try Microsoft Store for individual apps
    $apps = @(
        @{ Name = "OneNote"; Id = "Microsoft.Office.OneNote_8wekyb3d8bbwe" },
        @{ Name = "Word";     Id = "Microsoft.Office.Word_8wekyb3d8bbwe" },
        @{ Name = "Excel";    Id = "Microsoft.Office.Excel_8wekyb3d8bbwe" },
        @{ Name = "PowerPoint"; Id = "Microsoft.Office.PowerPoint_8wekyb3d8bbwe" }
    )

    foreach ($app in $apps) {
        $appPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\$($app.Id)"
        if (Test-Path $appPath) {
            Write-Host "  [OK] $($app.Name) already installed" -ForegroundColor Green
        } else {
            Write-Host "  Opening Store for $($app.Name)..." -ForegroundColor Yellow
            Start-Process "ms-windows-store://pdp/?productid=$($app.Id)" 2>$null
            Add-SetupLog -Message "[MANUAL] $($app.Name) - install from Store"
        }
    }
} else {
    Write-Host ""
    Write-Host "[OK] Microsoft 365 installed" -ForegroundColor Green
    Add-SetupLog -Message "[OK] Microsoft 365 installed via winget"
}

# Optional: install Edge for better Office integration (already in Windows 11)
$edgePath = "$env:ProgramFiles (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edgePath)) {
    Write-Host "[INFO] Microsoft Edge not found - Office web features may be limited" -ForegroundColor Yellow
} else {
    Write-Host "[OK] Microsoft Edge available" -ForegroundColor Green
}

Write-Host ""
Write-Host "Microsoft 365 installation complete." -ForegroundColor Green
Write-Host "Sign in with your Microsoft account when Office apps first launch." -ForegroundColor Yellow