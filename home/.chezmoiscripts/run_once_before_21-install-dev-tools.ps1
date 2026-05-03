# run_once_before_30-install-dev-tools.ps1
# Installs all developer tools, editors, CLI utilities, and WSL2 tools.
# Consolidates: install-packages (dev part) + lazyvim + linux-tools + opencode-WSL2.

$ErrorActionPreference = "Continue"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Installing Developer Tools" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# ============================================
# 1. WINGET DEV APPS
# ============================================
$wingetApps = @(
    "Microsoft.PowerShell",
    "Git.Git",
    "GitHub.GitHubDesktop",
    "GitHub.cli",
    "Microsoft.VisualStudioCode",
    "Neovim.Neovim",
    "wez.wezterm.nightly",
    "Starship.Starship",
    "jdx.mise",
    "DEVCOM.JetBrainsMonoNerdFont",
    "JetBrains.IntelliJIDEA",
    "Bruno.Bruno",
    "DBeaver.DBeaver.Community",
    "beekeeper-studio.beekeeper-studio",
    "RedHat.Podman",
    "Docker.DockerDesktop",
    "DEVCOM.JMeter",
    "SmartBear.SoapUI",
    "WinSCP.WinSCP",
    "JesseDuffield.lazygit",
    "OpenAI.Codex",
    "GitKraken.cli"
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

# ============================================
# 2. MISE TOOLS (must run BEFORE npm/bun/go globals)
# ============================================
$miseBinDir = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe\mise\bin"
if (Test-Path "$miseBinDir\mise.exe") {
    $env:Path = "$miseBinDir;$env:Path"
    Write-Host "[INFO] Installing mise tools..." -ForegroundColor Cyan
    mise install --force | ForEach-Object { Write-Host "  $_" }
    Write-Host "[OK] mise tools installed" -ForegroundColor Green
    
    # Add mise shims to PATH for this session so node/npm/bun/go are available
    $miseShimsDir = "$env:USERPROFILE\.local\share\mise\shims"
    if (Test-Path $miseShimsDir) {
        $env:Path = "$miseShimsDir;$env:Path"
        Write-Host "[OK] mise shims added to PATH for this session" -ForegroundColor Green
    }
} else {
    Write-Host "[WARN] mise not found, skipping mise install. npm/bun/go globals may use system versions." -ForegroundColor Yellow
}

# ============================================
# 3. GLOBAL PACKAGE MANAGERS (npm, bun, go)
# ============================================
npm install -g @openai/codex backlog.md @devcontainers/cli tree-sitter-cli
bun install -g opencode-ai
go install github.com/edouard-claude/snip/cmd/snip@latest
go install github.com/sorenisanerd/gotty@latest
npx -y firecrawl-cli@latest init --all

# ============================================
# 4. MANUAL DOWNLOADS (fallbacks and non-winget tools)
# ============================================
$toolingPath = "$env:USERPROFILE\dev\tooling"
New-Item -ItemType Directory -Path $toolingPath -Force | Out-Null

# JMeter fallback
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

# Podman Desktop (GUI)
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

# Antigravity (via winget with fallback to manual download)
$antigravityExe = "$toolingPath\Antigravity\Antigravity.exe"
if (-not (Test-Path $antigravityExe)) {
    try {
        Write-Host "Installing Antigravity via winget..." -ForegroundColor Cyan
        $proc = Start-Process "winget.exe" -ArgumentList "install -e --id Google.Antigravity --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -PassThru -Wait
        if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq -1978335189) {
            Write-Host "  [OK] Antigravity installed via winget" -ForegroundColor Green
        } else {
            Write-Host "  [FALLBACK] Downloading Antigravity manually..." -ForegroundColor Yellow
            $antigravityInstaller = "$env:TEMP\Antigravity-setup.exe"
            Invoke-WebRequest -Uri "https://antigravity.google/download/windows" -OutFile $antigravityInstaller -UseBasicParsing
            Start-Process -FilePath $antigravityInstaller -ArgumentList "/S" -Wait
            Write-Host "  [OK] Antigravity installed manually" -ForegroundColor Green
        }
    } catch {
        Write-Host "  [FAIL] Antigravity install failed: $_" -ForegroundColor Red
    }
}

# IntelliJ IDEA manual
$intellijExe = "$toolingPath\IntelliJ IDEA\bin\idea64.exe"
if (-not (Test-Path $intellijExe)) {
    try {
        Write-Host "Downloading IntelliJ IDEA..." -ForegroundColor Cyan
        $intellijZip = "$env:TEMP\intellij.zip"
        Invoke-WebRequest -Uri "https://data.services.jetbrains.com/products/download?code=IIC&platform=windows" -OutFile $intellijZip -UseBasicParsing
        Expand-Archive -Path $intellijZip -DestinationPath $toolingPath -Force
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

# VisualVM
$visualVmUrl = "https://github.com/oracle/visualvm/releases/download/2.1.10/visualvm_2110.zip"
$visualVmZip = "$env:TEMP\visualvm.zip"
$visualVmPath = "$toolingPath\visualvm"
try {
    Write-Host "Downloading VisualVM..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $visualVmUrl -OutFile $visualVmZip -UseBasicParsing
    Expand-Archive -Path $visualVmZip -DestinationPath $toolingPath -Force
    $extracted = Get-ChildItem -Path $toolingPath -Filter "visualvm_*" -Directory | Select-Object -First 1
    if ($extracted) {
        if (Test-Path "$toolingPath\visualvm") { Remove-Item "$toolingPath\visualvm" -Recurse -Force }
        Rename-Item -Path $extracted.FullName -NewName "visualvm" -Force
    }
    Remove-Item $visualVmZip -Force
    Write-Host "  [OK] VisualVM installed to $visualVmPath" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] VisualVM download/install failed" -ForegroundColor Red
}

# JD-GUI
$jdGuiUrl = "https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.jar"
$jdGuiPath = "$toolingPath\jd-gui"
try {
    Write-Host "Downloading JD-GUI..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $jdGuiPath -Force | Out-Null
    Invoke-WebRequest -Uri $jdGuiUrl -OutFile "$jdGuiPath\jd-gui-1.6.6.jar" -UseBasicParsing
    "@echo off`njava -jar `"$jdGuiPath\jd-gui-1.6.6.jar`" %*" | Out-File -FilePath "$jdGuiPath\jd-gui.bat" -Encoding ASCII
    Write-Host "  [OK] JD-GUI installed to $jdGuiPath" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] JD-GUI download/install failed" -ForegroundColor Red
}

# ============================================
# 5. LAZYVIM SETUP
# ============================================
$nvimDir = "$env:USERPROFILE\.config\nvim"
if (-not (Test-Path "$nvimDir\init.lua")) {
    git clone https://github.com/LazyVim/starter "$nvimDir" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Remove-Item -Path "$nvimDir\.git" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$nvimDir\README.md" -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] LazyVim starter cloned" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Could not clone LazyVim starter" -ForegroundColor Red
    }
} else {
    Write-Host "[OK] LazyVim already present" -ForegroundColor Green
}
Write-Host "Custom configs will be applied by chezmoi." -ForegroundColor Green

# ============================================
# 6. LINUX-STYLE CLI TOOLS (via winget)
# ============================================
$tools = @(
    @{ Name = "btm"; WingetId = "Clement.bottom"; Description = "Process monitor (htop alternative)" },
    @{ Name = "rg"; WingetId = "BurntSushi.ripgrep.MSVC"; Description = "Fast text search (grep alternative)" },
    @{ Name = "fd"; WingetId = "sharkdp.fd"; Description = "File finder (find alternative)" },
    @{ Name = "fzf"; WingetId = "Junegunn.fzf"; Description = "Fuzzy finder" }
)

foreach ($tool in $tools) {
    Write-Host ""
    Write-Host "[$($tool.Name)] $($tool.Description)" -ForegroundColor Yellow
    if (Get-Command $tool.Name -ErrorAction SilentlyContinue) {
        Write-Host "  Already installed" -ForegroundColor Green
    } else {
        Write-Host "  Installing via winget..." -ForegroundColor DarkYellow
        try {
            winget install --id $tool.WingetId --silent --accept-package-agreements --accept-source-agreements
            Write-Host "  [OK] Installation completed" -ForegroundColor Green
        } catch {
            Write-Host "  [FAIL] Installation error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
# ============================================
# 7. WSL2 TOOLS (opencode)
# ============================================
Write-Host ""
Write-Host "[INFO] Installing OpenCode in WSL2..." -ForegroundColor Cyan
$opencodeInstall = @'
curl -fsSL https://opencode.ai/install | bash
'@
wsl bash -c $opencodeInstall
Write-Host "[OK] OpenCode installed in WSL2" -ForegroundColor Green

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Developer tools installation complete." -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
