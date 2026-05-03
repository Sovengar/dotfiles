# run_once_before_01-install-packages.ps1
# Installs all apps via winget, npm, and go

$ErrorActionPreference = "Continue"
$wingetApps = @(
    "RARLab.WinRAR",
    "Bopsoft.Listary",
    "Skillbrains.Lightshot",
    "Discord.Discord",
    "Microsoft.PowerToys",
    "Microsoft.WindowsTerminal",
    "wez.wezterm",
    "VideoLAN.VLC",
    "AIMP.AIMP",
    "Plex.Plex",
    "Guru3D.Afterburner",
    "BitSum.ProcessLasso",
    "Reshade.Setup.AddonsSupport",
    "Guru3D.RTSS",
    "Valve.SteamLink",
    "Valve.Steam",
    "Dropbox.Dropbox",
    "Google.GoogleDrive",
    "Microsoft.OneDrive",
    "Microsoft.PowerShell",
    "DEVCOM.JetBrainsMonoNerdFont",
    "Canonical.Ubuntu",
    "flux.flux",
    "Malwarebytes.Malwarebytes",
    "AutoHotkey.AutoHotkey",
    "BartelsMedia.MacroRecorder",
    "Git.Git",
    "GitHub.GitHubDesktop",
    "Microsoft.VisualStudioCode",
    "JetBrains.IntelliJIDEA",
    "Bruno.Bruno",
    "DBeaver.DBeaver.Community",
    "beekeeper-studio.beekeeper-studio",
    "RedHat.Podman",
    "DEVCOM.JMeter",
    "SmartBear.SoapUI",
    "WinSCP.WinSCP",
    "Starship.Starship",
    "jdx.mise",
    "Docker.DockerDesktop",
    "PuTTY.PuTTY",
    "GitHub.cli",
    "JesseDuffield.lazygit",
    "cjpais.Handy",
    "OpenAI.Codex"
)

foreach ($app in $wingetApps) {
    Write-Host "Installing: $app" -ForegroundColor Cyan
    $proc = Start-Process "winget.exe" -ArgumentList "install -e --id $app --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -PassThru -Wait
    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq -1978335189) {
        Write-Host "  [OK] $app" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $app (ExitCode: $($proc.ExitCode))" -ForegroundColor Red
    }
}

# Manual downloads - fallback for winget packages that may fail or for GUI apps
$toolingPath = "$env:USERPROFILE\dev\tooling"
New-Item -ItemType Directory -Path $toolingPath -Force | Out-Null

# JMeter fallback - winget package often fails, download manually if not found
$jmeterBat = "$toolingPath\jmeter\bin\jmeter.bat"
if (-not (Test-Path $jmeterBat)) {
    try {
        Write-Host "Downloading JMeter (fallback)..." -ForegroundColor Cyan
        $jmeterZip = "$env:TEMP\jmeter.zip"
        Invoke-WebRequest -Uri "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.6.3.zip" -OutFile $jmeterZip -UseBasicParsing
        Expand-Archive -Path $jmeterZip -DestinationPath $toolingPath -Force
        $extracted = Get-ChildItem -Path $toolingPath -Filter "apache-jmeter*" -Directory | Select-Object -First 1
        if ($extracted) {
            if (Test-Path "$toolingPath\jmeter") { Remove-Item "$toolingPath\jmeter" -Recurse -Force }
            Rename-Item -Path $extracted.FullName -NewName "jmeter" -Force
        }
        Remove-Item $jmeterZip -Force
        Write-Host "  [OK] JMeter installed to $jmeterBat" -ForegroundColor Green
    } catch {
        Write-Host "  [FAIL] JMeter download failed" -ForegroundColor Red
    }
}

# Podman Desktop (GUI) - separate from CLI, winget only installs CLI
$podmanDesktopExe = "$env:LOCALAPPDATA\Programs\podman-desktop\Podman Desktop.exe"
if (-not (Test-Path $podmanDesktopExe)) {
    try {
        Write-Host "Downloading Podman Desktop..." -ForegroundColor Cyan
        $podmanInstaller = "$env:TEMP\podman-desktop.exe"
        Invoke-WebRequest -Uri "https://github.com/podman-desktop/podman-desktop/releases/download/v1.13.1/podman-desktop-1.13.1-setup.exe" -OutFile $podmanInstaller -UseBasicParsing
        Start-Process $podmanInstaller -ArgumentList "S" -Wait
        Write-Host "  [OK] Podman Desktop installed" -ForegroundColor Green
    } catch {
        Write-Host "  [FAIL] Podman Desktop download failed" -ForegroundColor Red
    }
}

# Antigravity - not in winget, manual download if needed
$antigravityExe = "$toolingPath\Antigravity\Antigravity.exe"
if (-not (Test-Path $antigravityExe)) {
    Write-Host "  [SKIP] Antigravity not found - add download URL manually if needed" -ForegroundColor Yellow
}

# IntelliJ IDEA - not in winget, download manually
$intellijExe = "$toolingPath\IntelliJ IDEA\bin\idea64.exe"
if (-not (Test-Path $intellijExe)) {
    try {
        Write-Host "Downloading IntelliJ IDEA..." -ForegroundColor Cyan
        $intellijZip = "$env:TEMP\intellij.zip"
        Invoke-WebRequest -Uri "https://data.services.jetbrains.com/products/download?code=IIC&platform=windows" -OutFile $intellijZip -UseBasicParsing
        # Extract to tooling folder
        Expand-Archive -Path $intellijZip -DestinationPath $toolingPath -Force
        # Rename extracted folder
        $extracted = Get-ChildItem -Path $toolingPath -Filter "idea-IC*" -Directory | Select-Object -First 1
        if ($extracted) {
            if (Test-Path "$toolingPath\IntelliJ IDEA") { Remove-Item "$toolingPath\IntelliJ IDEA" -Recurse -Force }
            Rename-Item -Path $extracted.FullName -NewName "IntelliJ IDEA" -Force
        }
        Remove-Item $intellijZip -Force
        Write-Host "  [OK] IntelliJ IDEA installed to $intellijExe" -ForegroundColor Green
    } catch {
        Write-Host "  [FAIL] IntelliJ IDEA download failed: $_" -ForegroundColor Red
    }
}

# VisualVM (not in winget)
$visualVmUrl = "https://github.com/oracle/visualvm/releases/download/2.1.10/visualvm_2110.zip"
$visualVmZip = "$env:TEMP\visualvm.zip"
$visualVmPath = "$toolingPath\visualvm"
try {
    Write-Host "Downloading VisualVM..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $visualVmUrl -OutFile $visualVmZip -UseBasicParsing
    Expand-Archive -Path $visualVmZip -DestinationPath $toolingPath -Force
    # Rename extracted folder
    $extracted = Get-ChildItem -Path $toolingPath -Filter "visualvm_*" -Directory | Select-Object -First 1
    if ($extracted) {
        if (Test-Path "$toolingPath\visualvm") {
            Remove-Item "$toolingPath\visualvm" -Recurse -Force
        }
        Rename-Item -Path $extracted.FullName -NewName "visualvm" -Force
    }
    Remove-Item $visualVmZip
    Write-Host "  [OK] VisualVM installed to $visualVmPath" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] VisualVM download/install failed" -ForegroundColor Red
}

# JD-GUI (not in winget)
$jdGuiUrl = "https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.jar"
$jdGuiPath = "$toolingPath\jd-gui"
try {
    Write-Host "Downloading JD-GUI..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $jdGuiPath -Force | Out-Null
    Invoke-WebRequest -Uri $jdGuiUrl -OutFile "$jdGuiPath\jd-gui-1.6.6.jar" -UseBasicParsing
    # Create a simple batch wrapper
    "@echo off`njava -jar `"$jdGuiPath\jd-gui-1.6.6.jar`" %*" | Out-File -FilePath "$jdGuiPath\jd-gui.bat" -Encoding ASCII
    Write-Host "  [OK] JD-GUI installed to $jdGuiPath" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] JD-GUI download/install failed" -ForegroundColor Red
}

# Node.js via mise (instalado después con mise install)

# NOTA: No añadimos ~/go/bin al PATH porque los bins se consolidan en ~/.local/bin via symlinks

# Global npm packages
npm install -g @openai/codex backlog.md @devcontainers/cli

# Global bun packages
bun install -g opencode-ai

# mise: instalar tools configurados
$miseBinDir = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe\mise\bin"
if (Test-Path "$miseBinDir\mise.exe") {
    $env:Path = "$miseBinDir;$env:Path"
    Write-Host "[INFO] Installing mise tools..." -ForegroundColor Cyan
    mise install --force | ForEach-Object { Write-Host "  $_" }
    Write-Host "[OK] mise tools installed" -ForegroundColor Green
} else {
    Write-Host "[WARN] mise not found, skipping mise install" -ForegroundColor Yellow
}

# Go tools
go install github.com/edouard-claude/snip/cmd/snip@latest
go install github.com/sorenisanerd/gotty@latest

# Firecrawl CLI
npx -y firecrawl-cli@latest init --all

# --- Create shortcuts in dev/tooling ---
Write-Host "Creating shortcuts in dev/tooling..." -ForegroundColor Magenta
$toolingPath = "$env:USERPROFILE\dev\tooling"
New-Item -ItemType Directory -Path $toolingPath -Force | Out-Null

function Find-AppPath {
    param([string]$ExeName, [string[]]$SearchPaths)
    foreach ($path in $SearchPaths) {
        if (Test-Path $path) { return $path }
    }
    # Fallback: search in common locations
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

Write-Host "Package installation complete." -ForegroundColor Green
