# setup-ssh-server.ps1
# Configures this Windows machine as an OpenSSH SSH server.
# Run on the REMOTE machine that will accept SSH connections (e.g., VPS, work PC).

$ErrorActionPreference = "Continue"

$response = Read-Host "Configure this machine as an SSH server (personal machine only)? [y/N]"
if ($response -ne 'y' -and $response -ne 'Y') {
    Write-Host "[SKIP] SSH server setup skipped" -ForegroundColor Yellow
    exit 0
}

function Log($msg, $color = "White") {
    Write-Host "[$(Get-Date -Format HH:mm:ss)] $msg" -ForegroundColor $color
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  OpenSSH Server Setup" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 1. Install OpenSSH Server
# ============================================
Log "Installing OpenSSH Server..." "Yellow"
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Log "OpenSSH Server installed." "Green"

# ============================================
# 2. Start and enable sshd
# ============================================
Log "Starting sshd service..." "Yellow"
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
Log "sshd service running and set to automatic." "Green"

# ============================================
# 3. Verify sshd is running
# ============================================
$svc = Get-Service sshd
if ($svc.Status -eq "Running") {
    Log "sshd is RUNNING." "Green"
} else {
    Log "WARNING: sshd is $($svc.Status)" "Red"
}

# ============================================
# 4. Firewall rule for port 22
# ============================================
Log "Adding firewall rule for SSH (port 22)..." "Yellow"
$ruleName = "sshd"
$existing = Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue

if (-not $existing) {
    New-NetFirewallRule -Name $ruleName -DisplayName "OpenSSH Server" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    Log "Firewall rule created." "Green"
} else {
    Log "Firewall rule already exists." "Green"
}

# ============================================
# 5. Generate SSH key pair
# ============================================
$sshKeyPath = "$HOME\.ssh\jon"

if (-not (Test-Path $sshKeyPath)) {
    Log "Generating SSH key (ed25519) at ~/.ssh/jon..." "Yellow"
    if (-not (Test-Path "$HOME\.ssh")) {
        New-Item -ItemType Directory -Path "$HOME\.ssh" -Force | Out-Null
    }
    ssh-keygen -t ed25519 -f $sshKeyPath -N '""'
    Log "Key generated." "Green"
} else {
    Log "SSH key already exists at ~/.ssh/jon" "Green"
}

# ============================================
# 6. Setup authorized_keys for the user
# ============================================
$authKeysFile = "$HOME\.ssh\authorized_keys"

if (-not (Test-Path $authKeysFile)) {
    New-Item -ItemType File -Path $authKeysFile -Force | Out-Null
}

Log "Setting permissions on authorized_keys..." "Yellow"
icacls $authKeysFile /inheritance:r /grant "$($env:USERNAME):(R)"

# ============================================
# 7. Instructions for copying public key
# ============================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   NEXT STEPS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$pubKey = Get-Content "$HOME\.ssh\jon.pub" -ErrorAction SilentlyContinue
if ($pubKey) {
    Write-Host "Your public key (copied to clipboard):" -ForegroundColor White
    Write-Host "  $pubKey" -ForegroundColor Yellow
    $pubKey | Set-Clipboard
    Write-Host ""
    Write-Host "It's already on your clipboard." -ForegroundColor White
}

Write-Host ""
Write-Host "--- If this IS your local machine that connects TO a remote server: ---" -ForegroundColor Cyan
Write-Host "1. Copy the public key (already on clipboard if generated now)" -ForegroundColor White
Write-Host "2. On the REMOTE machine, paste it in:" -ForegroundColor White
Write-Host "     C:\Users\<user>\.ssh\authorized_keys" -ForegroundColor Yellow
Write-Host ""
Write-Host "--- If this IS the REMOTE machine (server being configured): ---" -ForegroundColor Cyan
Write-Host "1. From your LOCAL machine, copy jon.pub:" -ForegroundColor White
Write-Host "     Get-Content ~/.ssh/jon.pub | Set-Clipboard" -ForegroundColor Yellow
Write-Host "2. Paste it here (in this machine) at:" -ForegroundColor White
Write-Host "     C:\Users\$($env:USERNAME)\.ssh\authorized_keys" -ForegroundColor Yellow
Write-Host ""
Write-Host "--- Then test the connection from LOCAL: ---" -ForegroundColor Cyan
Write-Host "  ssh -i ~/.ssh/jon <user>@<host>" -ForegroundColor Yellow
Write-Host "  wezterm connect <host-alias>" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Log "OpenSSH Server setup complete." "Green"
