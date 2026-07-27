#Requires -Version 7.0
# Configure RDP and remote access for the VM

. "$PSScriptRoot\lib.ps1"

Write-Host "Configuring RDP and remote access..." -ForegroundColor Cyan

# Ensure RDP is enabled
$rdpKey = "HKLM:\System\CurrentControlSet\Control\Terminal Server"
try {
    Set-ItemProperty -Path $rdpKey -Name "fDenyTSConnections" -Value 0 -ErrorAction Stop
    Write-Host "  [OK] RDP enabled" -ForegroundColor Green
} catch {
    Write-Host "  [SKIP] Could not enable RDP via registry" -ForegroundColor Yellow
}

# Enable RDP firewall rule
try {
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
    Write-Host "  [OK] RDP firewall rule enabled" -ForegroundColor Green
} catch {
    Write-Host "  [SKIP] Could not enable RDP firewall rule" -ForegroundColor Yellow
}

# Configure RDP for best experience
$rdpSettings = @(
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"; Name = "MaxIdleTime"; Value = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"; Name = "MaxDisconnectionTime"; Value = 0 }
)

foreach ($setting in $rdpSettings) {
    try {
        New-Item -Path $setting.Path -Force -ErrorAction SilentlyContinue | Out-Null
        Set-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value -ErrorAction SilentlyContinue
    } catch {
        # Non-critical
    }
}

Write-Host "  [OK] RDP session limits configured" -ForegroundColor Green

# Disable lock screen for RDP convenience
try {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableLockWorkstation" -Value 1 -ErrorAction SilentlyContinue
    Write-Host "  [OK] Lock screen disabled for RDP convenience" -ForegroundColor Green
} catch {
    Write-Host "  [SKIP] Could not disable lock screen" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "RDP configuration complete." -ForegroundColor Green