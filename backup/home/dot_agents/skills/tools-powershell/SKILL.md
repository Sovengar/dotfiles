---
name: tools-powershell
description: >
  Windows PowerShell patterns, WSL interop, and system administration.
  Trigger: Windows tasks, PowerShell scripts, WSL integration, Registry, Services, Networking.
tags: [powershell, windows, wsl, system-admin, scripts]
triggers: [powershell, windows, wsl, scripts, registry, services, networking, powershell-scripts, script-de-powershell, windows-admin]
---

# PowerShell Windows Patterns

> Critical patterns, pitfalls, and best practices for Windows administration.

---

## 1. WSL Interop

### Path Conversion

| Task | Command |
|------|---------|
| Linux → Windows path | `wslpath -w /mnt/c/Users` |
| Windows → Linux path | `wslpath -u C:\\Users` |

### Calling Windows from WSL

```bash
# Execute PowerShell command from WSL
powershell.exe -Command "Get-Process"

# Execute batch/cmd command
cmd.exe /c dir

# Run Windows executable
/myapp.exe arg1 arg2
```

### Critical WSL Patterns

| ❌ Wrong | ✅ Correct |
|----------|-----------|
| `/c/Users/...` | `/mnt/c/Users/...` |
| `C:\path` in bash | `/mnt/c/path` or `wslpath -w` |

---

## 2. Operator Syntax Rules

### CRITICAL: Parentheses Required

| ❌ Wrong | ✅ Correct |
|----------|-----------|
| `if (Test-Path "a" -or Test-Path "b")` | `if ((Test-Path "a") -or (Test-Path "b"))` |
| `if (Get-Item $x -and $y -eq 5)` | `if ((Get-Item $x) -and ($y -eq 5))` |

**Rule:** Each cmdlet call MUST be in parentheses when using logical operators.

---

## 3. Unicode/Emoji Restriction

### CRITICAL: No Unicode in Scripts

| Purpose | ❌ Don't Use | ✅ Use |
|---------|-------------|--------|
| Success | ✅ ✓ | [OK] [+] |
| Error | ❌ ✗ 🔴 | [!] [X] |
| Warning | ⚠️ 🟡 | [*] [WARN] |
| Info | ℹ️ 🔵 | [i] [INFO] |

**Rule:** Use ASCII characters only in PowerShell scripts.

---

## 4. File Paths & Permissions

### Windows Path Rules

| Pattern | Use |
|---------|-----|
| Literal path | `C:\Users\User\file.txt` |
| Variable path | `Join-Path $env:USERPROFILE "file.txt"` |
| Relative | `Join-Path $ScriptDir "data"` |

### Path Length Limitation

```powershell
# Check path length (260 char limit)
if ($fullPath.Length -gt 260) {
    # Use \\?\ prefix for extended paths
    $extendedPath = "\\?\$fullPath"
}

# Enable LongPathAware in registry for >260
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1
```

### CRLF vs LF

| Issue | Solution |
|-------|----------|
| Git line endings | `git config core.autocrlf true` |
| Convert to LF | `(Get-Content file.ps1) -join "`n" | Set-Content file.ps1 -NoNewline` |
| Detect encoding | `[System.Text.Encoding]::ASCII.GetString((Get-Content file.ps1 -Raw).Bytes[0..3])` |

---

## 5. PowerShell Core (pwsh)

### Cross-Platform Scripting

```powershell
# Check if running PowerShell Core
if ($PSVersionTable.PSVersion.Major -ge 6) {
    # Cross-platform compatible code
    $platform = $PSVersionTable.Platform
}

# Use pwsh for:
# - Linux/macOS execution
# - Modern cmdlets (ForEach-Object -Parallel)
# - JSON handling improvements
```

### Modern Cmdlet Patterns

```powershell
# Pipeline efficiency
Get-Process | Where-Object CPU -gt 10 | Sort-Object CPU -Descending | Select-Object -First 10

# ForEach-Object -Parallel (PS7+)
1..10 | ForEach-Object -Parallel { $_ * 2 } -ThrottleLimit 4

# Ternary operator (PS7+)
$result = $condition ? "yes" : "no"
```

---

## 6. Registry Operations

### Common Patterns

```powershell
# Read registry
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir"

# Write registry
Set-ItemProperty -Path "HKCU:\Software\MyApp" -Name "Setting" -Value "value"

# Create key
New-Item -Path "HKCU:\Software\MyApp" -Force | Out-Null

# Delete key/value
Remove-ItemProperty -Path "HKCU:\Software\MyApp" -Name "Setting"

# Registry types: String, ExpandString, Binary, DWord, MultiString, Qword
```

---

## 7. Windows Services Management

### Service Commands

```powershell
# Get service info
Get-Service -Name "Spooler"

# Start/Stop/Restart
Start-Service -Name "Spooler"
Stop-Service -Name "Spooler"
Restart-Service -Name "Spooler"

# Check service status
Get-Service | Where-Object Status -eq "Running"

# Create service (requires admin)
New-Service -Name "MyService" -BinaryPathName "C:\my.exe" -DisplayName "My Service"

# Service dependencies
Get-Service -Name "Spooler" | Select-Object -ExpandProperty DependentServices
```

---

## 8. Task Scheduler

### Create Scheduled Task

```powershell
# Create a basic scheduled task
$action = New-ScheduledTaskAction -Execute "C:\script.ps1" -Argument "-Param value"
$trigger = New-ScheduledTaskTrigger -Daily -At "09:00AM"
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "MyTask" -Action $action -Trigger $trigger -Settings $settings -Description "Daily task"

# List tasks
Get-ScheduledTask | Where-Object State -eq "Ready"

# Unregister
Unregister-ScheduledTask -TaskName "MyTask" -Confirm:$false
```

---

## 9. Windows Networking

### Network Commands

```powershell
# Get network adapters
Get-NetAdapter | Where-Object Status -eq "Up"

# IP configuration
Get-NetIPAddress -AddressFamily IPv4

# Test connectivity
Test-NetConnection -ComputerName "google.com" -Port 443

# Netsh equivalents (legacy)
netsh interface show interface
netsh wlan show networks

# Firewall rules
Get-NetFirewallRule | Where-Object Enabled -eq $true | Select-Object -First 10
New-NetFirewallRule -DisplayName "Allow Port 8080" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
```

### WSL2 Networking

```powershell
# Find WSL2 IP
(wsl hostname -I).Trim()

# Port forwarding (from Windows)
netsh interface portproxy add v4tov4 listenport=8080 connectport=8080 connectaddress=(wsl hostname -I).Trim()

# Check WSL2 network
Get-NetAdapter | Where-Object Name -like "*WSL*"
```

---

## 10. NTFS Permissions (ACLs)

### Common Patterns

```powershell
# Get ACL for folder
Get-Acl "C:\MyFolder" | Select-Object Owner, Access

# Add permission
$acl = Get-Acl "C:\MyFolder"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "DOMAIN\User", "Read", "Allow"
)
$acl.AddAccessRule($rule)
Set-Acl "C:\MyFolder" $acl

# Remove permission
$acl = Get-Acl "C:\MyFolder"
$acl.RemoveAccessRule($rule) | Out-Null
Set-Acl "C:\MyFolder" $acl

# Common rights: FullControl, Modify, ReadAndExecute, Read, Write
```

---

## 11. Null Check Patterns

### Always Check Before Access

| ❌ Wrong | ✅ Correct |
|----------|-----------|
| `$array.Count -gt 0` | `$array -and $array.Count -gt 0` |
| `$text.Length` | `if ($text) { $text.Length }` |
| `$obj.property` | `$obj?.property` (null-conditional, PS7+) |

---

## 12. Error Handling

### ErrorActionPreference

| Value | Use |
|-------|-----|
| Stop | Development (fail fast) |
| Continue | Production scripts |
| SilentlyContinue | When errors expected |

### Try/Catch Pattern

```powershell
try {
    # Don't return inside try
    $result = Get-Item "C:\file.txt"
    Write-Output "[OK] Found"
}
catch {
    Write-Warning "[ERROR] $_"
}
finally {
    # Cleanup here
}
# Return after try/catch
return $result
```

---

## 13. JSON Operations

### CRITICAL: Depth Parameter

| ❌ Wrong | ✅ Correct |
|----------|-----------|
| `ConvertTo-Json` | `ConvertTo-Json -Depth 10` |

### File Operations

| Operation | Pattern |
|-----------|---------|
| Read | `Get-Content "file.json" -Raw | ConvertFrom-Json` |
| Write | `$data | ConvertTo-Json -Depth 10 | Out-File "file.json" -Encoding UTF8` |

---

## 14. Windows Defender/Firewall

### Common Commands

```powershell
# Check Windows Defender status
Get-MpComputerStatus

# Add exclusion
Add-MpPreference -ExclusionPath "C:\Temp"
Add-MpPreference -ExclusionProcess "C:\myapp.exe"

# Firewall status
Get-NetFirewallProfile

# Enable/disable firewall
Set-NetFirewallProfile -Profile Domain -Enabled True
```

---

## 15. Case Sensitivity & Paths

### Windows vs Linux Differences

| Aspect | Windows | Linux/WSL |
|--------|---------|-----------|
| Paths | Case-insensitive | Case-sensitive |
| Drives | `C:\`, `D:\` | `/mnt/c/`, `/mnt/d/` |
| Separators | `\` | `/` |
| Environment | `$env:VAR` | `$env:VAR` |

### Path Normalization

```powershell
# Normalize path (resolve . and ..)
$normalized = (Resolve-Path "C:\Users\.\User\..\User").Path

# Case-insensitive comparison
"File.txt" -eq "file.txt"  # $true in Windows
```

---

## 16. Common Errors

| Error Message | Cause | Fix |
|---------------|-------|-----|
| "parameter 'or'" | Missing parentheses | Wrap cmdlets in () |
| "Unexpected token" | Unicode character | Use ASCII only |
| "Cannot find property" | Null object | Check null first |
| "Cannot convert" | Type mismatch | Use .ToString() |
| "Path too long" | >260 chars | Use `\\?\` prefix |
| "A parameter cannot be found that matches parameter name 'la'" | Using Linux command `ls -la` in PowerShell | Use `Get-ChildItem` instead |

---

### Common Linux Commands in PowerShell

| Linux Command | PowerShell Equivalent | Notes |
|---------------|----------------------|-------|
| `ls -la` | `Get-ChildItem -Force` | `-Force` shows hidden files |
| `ls -la /path` | `Get-ChildItem -Path /path -Force` | |
| `cat file.txt` | `Get-Content file.txt` | |
| `pwd` | `Get-Location` or `pwd` | pwd works in PowerShell |
| `cd` | `Set-Location` or `cd` | cd works in PowerShell |
| `mkdir dir` | `New-Item -ItemType Directory -Path dir` | |
| `rm -rf dir` | `Remove-Item -Recurse -Force dir` | |
| `cp src dst` | `Copy-Item -Path src -Destination dst` | |
| `mv src dst` | `Move-Item -Path src -Destination dst` | |
| `grep pattern` | `Select-String -Pattern pattern` | |
| `find . -name` | `Get-ChildItem -Recurse -Filter` | |

**Note:** PowerShell uses different flags than Linux commands. Always use PowerShell cmdlets, not Linux commands.

---

## 17. Script Template

```powershell
# Strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = Join-Path $ScriptDir "app.log"

# Main
try {
    # Logic here
    Write-Output "[OK] Done"
    exit 0
}
catch {
    Write-Warning "[ERROR] $_"
    exit 1
}
```

---

## When to Use

This skill is applicable when:
- Working with Windows PowerShell scripts
- WSL and Windows interop tasks
- Registry operations
- Windows Services management
- Task Scheduler automation
- Networking (netsh, firewall, WSL2)
- NTFS permissions and ACLs
- Windows Defender configuration
- Path length issues
- File encoding (CRLF/LF)
- PowerShell Core (pwsh) cross-platform scripts

---

## Commands Quick Reference

```bash
# WSL to Windows
wslpath -w /mnt/c/Users  # Linux → Windows
powershell.exe -Command "Get-Process"

# PowerShell
Get-Service
Get-NetAdapter
Get-Acl
Get-ItemProperty
Get-ScheduledTask

# Registry
Set-ItemProperty -Path "HKCU:\..." -Name "..." -Value "..."
New-Item -Path "HKCU:\..."
```