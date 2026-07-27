. "$PSScriptRoot\..\lib.ps1"
$ErrorActionPreference = "Continue"

if (-not (Confirm-Step "Run SSH setup (personal machine only)")) {
    Write-Host "[SKIP] SSH setup skipped" -ForegroundColor Yellow
    exit 0
}

$sshDir = "$env:USERPROFILE\.ssh"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$secretsFile = Join-Path $repoRoot "secrets\dotfiles.sops.yaml"

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
if ((Test-Path $secretsFile) -and (Get-Command sops -ErrorAction SilentlyContinue) -and (Get-Command ssh-keyscan -ErrorAction SilentlyContinue)) {
    $json = & sops --decrypt --output-type json $secretsFile 2>$null
    if ($LASTEXITCODE -eq 0) {
        $secrets = $json | ConvertFrom-Json
        $sshHost = $secrets.ssh.host
        if ($sshHost) {
            ssh-keyscan $sshHost 2>$null | Set-Content -Path $localKnownHosts -Encoding ascii
            Write-Host "[OK] known_hosts generated from SOPS ssh.host" -ForegroundColor Green
        } else {
            Write-Host "[SKIP] ssh.host not configured in SOPS secrets" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[WARN] Could not decrypt SOPS secrets; skipping known_hosts" -ForegroundColor Yellow
    }
} else {
    Write-Host "[SKIP] sops or ssh-keyscan unavailable; skipping known_hosts" -ForegroundColor Yellow
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
