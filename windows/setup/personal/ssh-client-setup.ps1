. "$PSScriptRoot\..\lib.ps1"
$ErrorActionPreference = "Continue"

if (-not (Confirm-Step "Run SSH setup (personal machine only)")) {
    Write-Host "[SKIP] SSH setup skipped" -ForegroundColor Yellow
    exit 0
}

$sshDir = "$env:USERPROFILE\.ssh"
$oneDriveSshDir = "$env:USERPROFILE\OneDrive\secrets\.ssh"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  SSH Setup" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    Write-Host "[OK] Created .ssh directory" -ForegroundColor Green
}

$identityFile = Join-Path $sshDir "jon"
if (-not (Test-Path $identityFile)) {
    Write-Host "[INFO] Generating SSH key: jon" -ForegroundColor Yellow
    ssh-keygen -t ed25519 -f $identityFile -N '""'
    Write-Host "[OK] SSH key generated" -ForegroundColor Green
    Write-Host "IMPORTANT: Copy your public key to the remote server:" -ForegroundColor Cyan
    Write-Host "  Get-Content $identityFile.pub | Set-Clipboard" -ForegroundColor White
} else {
    Write-Host "[OK] SSH key already exists" -ForegroundColor Green
}

$localKnownHosts = Join-Path $sshDir "known_hosts"
while (-not (Test-Path $oneDriveSshDir)) {
    Write-Host "[WARN] OneDrive no sincronizado? No se encuentra: $oneDriveSshDir" -ForegroundColor Yellow
    $retry = Read-Host "Reintentar (r) o saltar known_hosts (s)? (r/s)"
    if ($retry -notmatch '^[rR]') {
        Write-Host "[SKIP] known_hosts — OneDrive no disponible" -ForegroundColor Yellow
        break
    }
}
if (Test-Path "$oneDriveSshDir\known_hosts") {
    Copy-Item -Path "$oneDriveSshDir\known_hosts" -Destination $localKnownHosts -Force
    Write-Host "[OK] Restored known_hosts from OneDrive" -ForegroundColor Green
} elseif (Test-Path $oneDriveSshDir) {
    Write-Host "[SKIP] known_hosts not found in OneDrive" -ForegroundColor Yellow
}

$itemsToSecure = @($sshDir, $identityFile, "$identityFile.pub")
if (Test-Path $localKnownHosts) { $itemsToSecure += $localKnownHosts }
foreach ($item in $itemsToSecure) {
    if (Test-Path $item) {
        try { icacls $item /inheritance:r /grant:r "$($env:USERNAME):(R)" | Out-Null } catch {
            Write-Host "[WARN] Could not set strict permissions on $item" -ForegroundColor Yellow
        }
    }
}
Write-Host "[OK] Permissions configured" -ForegroundColor Green

Write-Host ""
Write-Host "To test your connection:" -ForegroundColor Cyan
Write-Host "  ssh -i ~/.ssh/jon buble@157.180.112.216" -ForegroundColor White
Write-Host "  or" -ForegroundColor White
Write-Host "  wezterm connect Jon" -ForegroundColor White
