# setup-ssh-server.ps1
# Configures this Windows machine as an OpenSSH SSH server.
# Run on the REMOTE machine that will accept SSH connections (e.g., VPS, work PC).

. "$PSScriptRoot\..\lib.ps1"
$ErrorActionPreference = "Continue"

if (-not (Confirm-Step "Configure this machine as an SSH server (personal machine only)")) {
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
    ssh-keygen -t ed25519 -f $sshKeyPath -N ""
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
# 6b. Also add to administrators_authorized_keys if admin user
# ============================================
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Log "User is admin — adding key to administrators_authorized_keys..." "Yellow"
    $adminKeysFile = "$env:ProgramData\ssh\administrators_authorized_keys"
    $pubKey = Get-Content "$HOME\.ssh\jon.pub" -ErrorAction SilentlyContinue
    if ($pubKey) {
        Add-Content -Path $adminKeysFile -Value $pubKey -Encoding ASCII
        icacls $adminKeysFile /inheritance:r /grant "SYSTEM:(F)" /grant "BUILTIN\Administradores:(F)"
        Log "Public key added to administrators_authorized_keys." "Green"
    }
} else {
    Log "User is not admin — administrators_authorized_keys not needed." "Green"
}

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
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   SETUP COMPLETE — NEXT STEPS" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  SERVER (this machine):" -ForegroundColor Green
Write-Host "    ✓ OpenSSH Server installed and running"
Write-Host "    ✓ Firewall port 22 open"
Write-Host "    ✓ SSH key pair at ~/.ssh/jon (ed25519, no passphrase)"
Write-Host "    ✓ Public key in authorized_keys"
if ($isAdmin) {
    Write-Host "    ✓ Also in administrators_authorized_keys (admin user)"
}
Write-Host ""
Write-Host "  CLIENT machine needs:" -ForegroundColor Yellow
Write-Host "    1. Copy ~/.ssh/jon (private key, no passphrase)" -ForegroundColor White
Write-Host "       to the client's ~/.ssh/" -ForegroundColor White
Write-Host "    2. Copy ~/.ssh/jon.pub (public) to the client's ~/.ssh/" -ForegroundColor White
Write-Host "    3. In client's wezterm.lua, add ssh_domains entry:" -ForegroundColor White
Write-Host '       {'
Write-Host '         name = '<server-alias>','
Write-Host '         remote_address = '<server-ip>','
Write-Host "         username = '$($env:USERNAME)',"
Write-Host "         ssh_option = {"
Write-Host "           identityfile = wezterm.home_dir .. '/.ssh/jon',"
Write-Host "         }"
Write-Host '       }'
Write-Host "    4. wezterm connect <server-alias>" -ForegroundColor Yellow
Write-Host ""
Write-Host "  NOTE for admin users on Windows:" -ForegroundColor Cyan
Write-Host "    OpenSSH on Windows uses administrators_authorized_keys" -ForegroundColor White
Write-Host "    instead of the user's .ssh/authorized_keys" -ForegroundColor White
Write-Host "    This script handles it automatically." -ForegroundColor White
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

Log "OpenSSH Server setup complete." "Green"
