# run_once_after_25-create-dev-shortcuts.ps1
# Creates shortcuts for development tools in dev/tooling.
# This script runs AFTER dev tools have been installed.

$ErrorActionPreference = "Continue"
$toolingPath = "$env:USERPROFILE\dev\tooling"
New-Item -ItemType Directory -Path $toolingPath -Force | Out-Null

function Find-AppPath {
    param([string]$ExeName, [string[]]$SearchPaths)
    foreach ($path in $SearchPaths) {
        if (Test-Path $path) { return $path }
    }
    $commonRoots = @(
        "$env:LOCALAPPDATA\Programs",
        "$env:LOCALAPPDATA",
        "$env:PROGRAMFILES",
        "$env:PROGRAMFILES(x86)",
        "$env:USERPROFILE\Dropbox\DEV\tools"
    )
    foreach ($root in $commonRoots) {
        if (Test-Path $root) {
            $found = Get-ChildItem -Path $root -Filter $ExeName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 FullName
            if ($found) { return $found.FullName }
        }
    }
    return $null
}

$apps = @(
    @{ Name = 'GitHub Desktop'; Exe = 'GitHubDesktop.exe'; Paths = @("$env:LOCALAPPDATA\GitHubDesktop\GitHubDesktop.exe", 'C:\Program Files\GitHub Desktop\GitHubDesktop.exe') },
    @{ Name = 'Bruno'; Exe = 'Bruno.exe'; Paths = @("$env:LOCALAPPDATA\Programs\Bruno\Bruno.exe", "$env:LOCALAPPDATA\Programs\bruno\Bruno.exe") },
    @{ Name = 'DBeaver'; Exe = 'dbeaver.exe'; Paths = @("$env:LOCALAPPDATA\DBeaver\dbeaver.exe", 'C:\Program Files\DBeaver\dbeaver.exe') },
    @{ Name = 'Beekeeper Studio'; Exe = 'Beekeeper Studio.exe'; Paths = @("$env:LOCALAPPDATA\Programs\Beekeeper Studio\Beekeeper Studio.exe") },
    @{ Name = 'Podman Desktop'; Exe = 'Podman Desktop.exe'; Paths = @("$env:LOCALAPPDATA\Programs\podman-desktop\Podman Desktop.exe") },
    @{ Name = 'Podman CLI'; Exe = 'podman.exe'; Paths = @("C:\Program Files\RedHat\Podman\podman.exe") },
    @{ Name = 'Docker Desktop'; Exe = 'Docker Desktop.exe'; Paths = @("C:\Program Files\Docker\Docker\Docker Desktop.exe") },
    @{ Name = 'JMeter'; Exe = 'jmeter.bat'; Paths = @("$toolingPath\jmeter\bin\jmeter.bat") },
    @{ Name = 'SoapUI'; Exe = 'soapui.bat'; Paths = @('C:\Program Files\SmartBear\SoapUI-5.9.1\bin\soapui.bat', 'C:\Program Files\SmartBear\SoapUI-5.7.0\bin\soapui.bat') },
    @{ Name = 'WinSCP'; Exe = 'WinSCP.exe'; Paths = @("$env:LOCALAPPDATA\Programs\WinSCP\WinSCP.exe", 'C:\Program Files\WinSCP\WinSCP.exe') },
    @{ Name = 'VisualVM'; Exe = 'visualvm.exe'; Paths = @("$toolingPath\visualvm\bin\visualvm.exe") },
    @{ Name = 'JD-GUI'; Exe = 'jd-gui.bat'; Paths = @("$toolingPath\jd-gui\jd-gui.bat") },
    @{ Name = 'Antigravity'; Exe = 'Antigravity.exe'; Paths = @("$toolingPath\Antigravity\Antigravity.exe") },
    @{ Name = 'IntelliJ IDEA'; Exe = 'idea64.exe'; Paths = @("$toolingPath\IntelliJ IDEA\bin\idea64.exe") },
    @{ Name = 'WezTerm'; Exe = 'wezterm.exe'; Paths = @("C:\Program Files\WezTerm\wezterm.exe") },
    @{ Name = 'VSCode'; Exe = 'Code.exe'; Paths = @("$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe", "C:\Program Files\Microsoft VS Code\Code.exe") }
)

$WshShell = New-Object -ComObject WScript.Shell
foreach ($app in $apps) {
    $target = Find-AppPath -ExeName $app.Exe -SearchPaths $app.Paths
    if ($target) {
        $lnkPath = "$toolingPath\$($app.Name).lnk"
        $Shortcut = $WshShell.CreateShortcut($lnkPath)
        $Shortcut.TargetPath = $target
        if ($target -match '\.(bat|cmd)$') {
            $Shortcut.WorkingDirectory = (Split-Path $target)
        }
        $Shortcut.Save()
        Write-Host "  [OK] $($app.Name).lnk -> $target" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] $($app.Name) - executable not found" -ForegroundColor Yellow
    }
}

Write-Host "Dev shortcuts creation complete." -ForegroundColor Green
