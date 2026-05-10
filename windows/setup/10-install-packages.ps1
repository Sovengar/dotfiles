. "$PSScriptRoot\lib.ps1"
$ErrorActionPreference = "Continue"

$allPackages = Read-Packages
if (-not $allPackages) { exit 1 }

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  RESETTING WINGET SOURCES" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Reset-WingetSources

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  CORE APPS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Install-WingetList -AppIds $allPackages.core.winget

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  DEV TOOLS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Install-WingetList -AppIds $allPackages.dev.winget

$wslOpencodeCheck = wsl bash -lc "which opencode 2>/dev/null || test -f ~/.opencode/bin/opencode 2>/dev/null && echo installed" 2>$null
if ($wslOpencodeCheck -match "installed") {
    Write-Host "[OK] OpenCode already installed in WSL2" -ForegroundColor Green
} else {
    Write-Host "[INFO] Installing OpenCode in WSL2..." -ForegroundColor Cyan
    try {
        wsl bash -c "curl -fsSL https://opencode.ai/install | bash" 2>&1 | ForEach-Object { Write-Host "  $_" }
        Write-Host "[OK] OpenCode installed in WSL2" -ForegroundColor Green
    } catch {
        Add-SetupLog -Message "[WARN] WSL2 OpenCode install skipped (WSL2 not available)"
        Write-Host "[WARN] WSL2 not available, skipping OpenCode install" -ForegroundColor Yellow
    }
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  USER APPS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Install-WingetList -AppIds $allPackages.user.winget

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  GAMING APPS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Install-WingetList -AppIds $allPackages.gaming.winget

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  SECURITY APPS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Install-WingetList -AppIds $allPackages.security.winget

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  MANUAL DOWNLOADS (background)" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Start-BackgroundDownloads -Downloads $allPackages.dev.manual_downloads

$oneNotePath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\Microsoft.Office.OneNote_8wekyb3d8bbwe"
if (-not (Test-Path $oneNotePath)) {
    Write-Host "Abriendo Microsoft Store para OneNote..." -ForegroundColor Yellow
    try {
        Start-Process "ms-windows-store://pdp/?productid=9WZDNCRFHVJL"
        Write-Host "Microsoft Store abierta en OneNote. Instala manualmente desde la tienda." -ForegroundColor Green
    } catch {
        Write-Host "ERROR abriendo Microsoft Store para OneNote" -ForegroundColor Red
    }
} else {
    Write-Host "[OK] OneNote already installed" -ForegroundColor Green
}

$raycastPath = "$env:LOCALAPPDATA\Programs\Raycast\Raycast.exe"
if (-not (Test-Path $raycastPath)) {
    Write-Host "[INFO] Installing Raycast via Microsoft Store..." -ForegroundColor Yellow
    winget install --id 9PFXXSHC64H3 --source msstore --silent --accept-package-agreements 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Raycast installed" -ForegroundColor Green
    } else {
        Write-Host "[INFO] Could not install silently — opening Microsoft Store page..." -ForegroundColor Yellow
        Start-Process "ms-windows-store://pdp/?productid=9PFXXSHC64H3"
    }
} else {
    Write-Host "[OK] Raycast already installed" -ForegroundColor Green
}





Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  MISE TOOLS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
$miseBinDir = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe\mise\bin"
if (-not (Test-Path "$miseBinDir\mise.exe")) {
    Add-SetupLog -Message "[WARN] mise not found, skipping mise tools install"
    Write-Host "[WARN] mise not found, skipping mise install" -ForegroundColor Yellow
} else {
    $env:Path = "$miseBinDir;$env:Path"
    $miseConfigPath = "$env:USERPROFILE\.config\mise\config.toml"
    $rendered = chezmoi cat "~\.config\mise\config.toml" 2>$null
    if ($rendered) {
        New-Item -ItemType Directory -Path (Split-Path $miseConfigPath -Parent) -Force | Out-Null
        $rendered | Set-Content -Path $miseConfigPath -Encoding UTF8 -Force
        Write-Host "[OK] Deployed mise config from chezmoi source" -ForegroundColor Green
    }
    $miseConfigs = @(
        $miseConfigPath,
        "$env:USERPROFILE\mise.toml",
        "$env:USERPROFILE\.mise.toml",
        (Join-Path (Get-Location) "mise.toml"),
        (Join-Path (Get-Location) ".mise.toml")
    )
    $miseConfig = $miseConfigs | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $miseConfig) {
        Write-Host "[SKIP] No mise config found (define tools in ~/.config/mise/config.toml first)" -ForegroundColor Yellow
    } else {
        Write-Host "[INFO] Installing mise tools from $miseConfig..." -ForegroundColor Cyan
        mise install 2>&1 | ForEach-Object { Write-Host "  $_" }
        mise reshim 2>&1 | ForEach-Object { Write-Host "  $_" }
        Write-Host "[OK] mise tools installed" -ForegroundColor Green
    }
    $miseShimsDir = "$env:USERPROFILE\.local\share\mise\shims"
    if (Test-Path $miseShimsDir) {
        $env:Path = "$miseShimsDir;$env:Path"
    }
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  NPM GLOBAL PACKAGES" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
$npmPackages = $allPackages.dev.npm_global
if ($npmPackages) {
    mise exec node -- npm install -g $npmPackages
    Write-Host "[OK] npm globals installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  BUN GLOBAL PACKAGES" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
$bunPackages = $allPackages.dev.bun_global
if ($bunPackages) {
    foreach ($pkg in $bunPackages) {
        mise exec bun -- bun install -g $pkg
    }
    Write-Host "[OK] bun globals installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  GO INSTALL" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
$goPackages = $allPackages.dev.go_install
if ($goPackages) {
    foreach ($pkg in $goPackages) {
        mise exec go -- go install $pkg
    }
    Write-Host "[OK] go installs completed" -ForegroundColor Green
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  FIRECRAWL CLI" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
mise exec node -- npm install -g firecrawl-cli@latest
Write-Host "[INFO] firecrawl CLI installed. API key se configura via chezmoi." -ForegroundColor Yellow

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  GH EXTENSIONS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
if (Get-Command gh -ErrorAction SilentlyContinue) {
    $ghExts = $allPackages.dev.gh_extensions
    if ($ghExts) {
        foreach ($ext in $ghExts) {
            gh extension install $ext --force 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [OK] gh extension: $ext" -ForegroundColor Green
            } else {
                Write-Host "  [WARN] gh extension $ext failed" -ForegroundColor Yellow
            }
        }
    }
} else {
    Add-SetupLog -Message "[WARN] gh not found, skipping gh extensions"
    Write-Host "[WARN] gh not found, skipping gh extensions" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  PS MODULES" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
$psModules = $allPackages.dev.ps_modules
if ($psModules) {
    foreach ($mod in $psModules) {
        if (-not (Get-Module -ListAvailable -Name $mod)) {
            Install-Module -Name $mod -Scope CurrentUser -Force -SkipPublisherCheck
            Write-Host "  [OK] PS module: $mod" -ForegroundColor Green
        } else {
            Write-Host "  [OK] PS module $mod already installed" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  BUILD TOOLS (LazyVim dep)" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Install-WingetApp -AppId "Microsoft.VisualStudio.2022.BuildTools"

$vsInstallPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\BuildTools"
$vcvars = "$vsInstallPath\VC\Auxiliary\Build\vcvarsall.bat"
if (-not (Test-Path $vcvars)) {
    $vsInstaller = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe"
    if (Test-Path $vsInstaller) {
        Write-Host "[INFO] Adding 'Desktop development with C++' workload..." -ForegroundColor Cyan
        $proc = Start-Process -FilePath $vsInstaller -ArgumentList "modify --installPath `"$vsInstallPath`" --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --quiet --wait --norestart" -Wait -PassThru
        if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
            Write-Host "[OK] C++ build tools installed" -ForegroundColor Green
            Add-SetupLog -Message "[OK] C++ build tools workload installed"
        } else {
            Write-Host "[WARN] VS installer exit code $($proc.ExitCode). Open Visual Studio Installer and add 'Desktop development with C++' manually." -ForegroundColor Yellow
            Add-SetupLog -Message "[WARN] VS installer exit code $($proc.ExitCode)"
        }
    } else {
        Add-SetupLog -Message "[ACTION] Visual Studio Installer not found at $vsInstaller"
        Write-Host "[WARN] Visual Studio Installer not found. Please open it and select 'Desktop development with C++'" -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] C++ build tools already installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  LAZYVIM" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
$nvimDir = "$env:USERPROFILE\.config\nvim"
if (-not (Test-Path "$nvimDir\init.lua")) {
    Write-Host "[LazyVim] Cloning LazyVim starter..." -ForegroundColor Cyan
    git clone https://github.com/LazyVim/starter "$nvimDir" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Remove-Item -Path "$nvimDir\.git" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$nvimDir\README.md" -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] LazyVim starter cloned" -ForegroundColor Green
        Write-Host "Custom configs will be applied by chezmoi apply" -ForegroundColor Green
    } else {
        Add-SetupLog -Message "[FAIL] Could not clone LazyVim starter"
        Write-Host "[FAIL] Could not clone LazyVim starter" -ForegroundColor Red
    }
} else {
    Write-Host "[OK] LazyVim already present" -ForegroundColor Green
}

$lazyVimPlugins = "$env:USERPROFILE\.local\share\nvim-data\lazy"
if (Test-Path $lazyVimPlugins) {
    Write-Host "[OK] LazyVim plugins already installed" -ForegroundColor Green
} else {
    $nvimExe = "C:\Program Files\Neovim\bin\nvim.exe"
    if (Test-Path $nvimExe) {
        Write-Host ""
        Write-Host "===============================================" -ForegroundColor Cyan
        Write-Host "  FIRST NEOVIM LAUNCH (LazyVim plugins)" -ForegroundColor Cyan
        Write-Host "===============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Opening Neovim to install LazyVim plugins..." -ForegroundColor Yellow
        Write-Host "1. Wait for LazyVim to download and install plugins" -ForegroundColor White
        Write-Host "2. Press 'q' to close the LazyVim dashboard" -ForegroundColor White
        Write-Host "3. Type ':qa' and press Enter to quit" -ForegroundColor White
        Write-Host ""
        Start-Process -FilePath $nvimExe -Wait
        Write-Host "[OK] LazyVim plugins installed" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  INSTALL CDX (Rust CLI)" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
$repoUrl = "https://github.com/Sovengar/cdx.git"
$projectDir = "$env:TEMP\cdx-rs-build"
$binDir = "$env:USERPROFILE\.local\bin"
$binPath = "$binDir\cdx-rs.exe"

New-Item -ItemType Directory -Path $binDir -Force -ErrorAction SilentlyContinue | Out-Null

Write-Host "[cdx] Cloning repo..." -ForegroundColor Cyan
Remove-Item -LiteralPath $projectDir -Recurse -Force -ErrorAction SilentlyContinue
git clone $repoUrl $projectDir 2>$null

if (-not (Test-Path "$projectDir\Cargo.toml")) {
    Write-Host "[cdx] Failed to clone repo" -ForegroundColor Red
} else {
    $hasRust = Get-Command rustc -ErrorAction SilentlyContinue
    if (-not $hasRust) {
        Write-Host "[cdx] Rust not found, installing via rustup..." -ForegroundColor Yellow
        $rustupUrl = "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
        $rustupPath = "$env:TEMP\rustup-init.exe"
        Invoke-WebRequest -Uri $rustupUrl -OutFile $rustupPath
        & $rustupPath -y
        $env:Path = [Environment]::GetEnvironmentVariable("Path", "User")
    }

    Push-Location $projectDir
    Write-Host "[cdx] Building release..." -ForegroundColor Cyan
    cargo build --release
    $buildOk = $LASTEXITCODE -eq 0
    Pop-Location

    if ($buildOk) {
        $retries = 5
        do {
            try {
                Copy-Item -LiteralPath "$projectDir\target\release\cdx-rs.exe" -Destination $binPath -Force -ErrorAction Stop
                $copied = $true
            } catch {
                $copied = $false
                $retries--
                if ($retries -gt 0) {
                    Write-Host "[cdx] Binary in use, retrying in 2s..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 2
                }
            }
        } while (-not $copied -and $retries -gt 0)
        if ($copied) {
            Write-Host "[cdx] Installed to $binPath" -ForegroundColor Green
        } else {
            Write-Host "[cdx] Could not copy binary (in use). Close cdx and re-run." -ForegroundColor Red
        }
    } else {
        Write-Host "[cdx] Build failed" -ForegroundColor Red
    }
    Remove-Item -LiteralPath $projectDir -Recurse -Force -ErrorAction SilentlyContinue
}


Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  PACKAGE INSTALLATION COMPLETE" -ForegroundColor Cyan
