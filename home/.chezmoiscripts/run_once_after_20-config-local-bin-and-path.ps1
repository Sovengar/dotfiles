# run_once_after_95-config-local-bin-and-path.ps1
# Consolida todos los ejecutables en ~/.local/bin y limpia el PATH
# Ejecuta al final del chezmoi apply

$ErrorActionPreference = "Continue"
$localBin = "$env:USERPROFILE\.local\bin"
$createdLinks = @()
$movedItems = @()
$removedPaths = @()
$warnings = @()

# Activar Modo Desarrollador para permitir symlinks sin admin
$devModePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
try {
    if (-not (Test-Path $devModePath)) {
        New-Item -Path $devModePath -Force | Out-Null
    }
    Set-ItemProperty -Path $devModePath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -ErrorAction Stop
    Write-Host "[OK] Developer Mode enabled for symlinks" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Could not enable Developer Mode (requires admin). Symlinks may fail." -ForegroundColor Yellow
}

# Asegurar que ~/.local/bin existe
New-Item -ItemType Directory -Force -Path $localBin | Out-Null
Write-Host "[INFO] Consoliding executables to $localBin" -ForegroundColor Cyan

# ============================================
# 1. MOVER fisicamente ~/go/bin/* a ~/.local/bin
# ============================================
$goBin = "$env:USERPROFILE\go\bin"
if (Test-Path $goBin) {
    $items = Get-ChildItem -Path $goBin -Recurse -File
    foreach ($item in $items) {
        $relativePath = $item.FullName.Substring($goBin.Length + 1)
        $dest = Join-Path $localBin $relativePath
        $destDir = Split-Path -Parent $dest
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        }
        if (Test-Path $dest) {
            Remove-Item -Path $dest -Force
        }
        Move-Item -Path $item.FullName -Destination $dest -Force
        $movedItems += $relativePath
    }
    # Eliminar directorio vacio
    if ((Get-ChildItem -Path $goBin -Recurse -File).Count -eq 0) {
        Remove-Item -Path $goBin -Recurse -Force
    }
    Write-Host "[OK] Moved $($movedItems.Count) items from ~/go/bin" -ForegroundColor Green
}

# ============================================
# 2. MOVER fisicamente ~/bin/* a ~/.local/bin
# ============================================
$homeBin = "$env:USERPROFILE\bin"
if (Test-Path $homeBin) {
    $items = Get-ChildItem -Path $homeBin -Recurse -File
    foreach ($item in $items) {
        $relativePath = $item.FullName.Substring($homeBin.Length + 1)
        $dest = Join-Path $localBin $relativePath
        $destDir = Split-Path -Parent $dest
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        }
        if (Test-Path $dest) {
            Remove-Item -Path $dest -Force
        }
        Move-Item -Path $item.FullName -Destination $dest -Force
        $movedItems += $relativePath
    }
    # Eliminar directorio vacio
    if ((Get-ChildItem -Path $homeBin -Recurse -File).Count -eq 0) {
        Remove-Item -Path $homeBin -Recurse -Force
    }
    Write-Host "[OK] Moved $($items.Count) items from ~/bin" -ForegroundColor Green
}

# ============================================
# 3. MOVER gh.exe desde GitHub CLI instalación del sistema
# ============================================
$ghSystemPath = "C:\Program Files\GitHub CLI\gh.exe"
$ghLocalPath = Join-Path $localBin "gh.exe"
if (Test-Path $ghSystemPath) {
    if (Test-Path $ghLocalPath) { Remove-Item -Path $ghLocalPath -Force }
    try {
        Move-Item -Path $ghSystemPath -Destination $ghLocalPath -Force
        $movedItems += "gh.exe"
        Write-Host "[OK] Moved gh.exe from system to ~/.local/bin" -ForegroundColor Green
        # Eliminar directorio vacio si queda vacio
        $ghDir = "C:\Program Files\GitHub CLI"
        if ((Get-ChildItem -Path $ghDir -Recurse -File -ErrorAction SilentlyContinue).Count -eq 0) {
            Remove-Item -Path $ghDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    } catch {
        $warnings += "Failed to move gh.exe`: $_"
    }
}

# ============================================
# 4. CREAR SYMLINKS para herramientas WinGet
# ============================================
$wingetTools = @{
    'rg.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_8wekyb3d8bbwe\ripgrep-15.1.0-x86_64-pc-windows-msvc\rg.exe"
    'fd.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_8wekyb3d8bbwe\fd-v10.4.2-x86_64-pc-windows-msvc\fd.exe"
    'gk.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GitKraken.cli_Microsoft.Winget.Source_8wekyb3d8bbwe\gk.exe"
    'lazygit.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\JesseDuffield.lazygit_Microsoft.Winget.Source_8wekyb3d8bbwe\lazygit.exe"
    'fzf.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\junegunn.fzf_Microsoft.Winget.Source_8wekyb3d8bbwe\fzf.exe"
    'chezmoi.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\twpayne.chezmoi_Microsoft.Winget.Source_8wekyb3d8bbwe\chezmoi.exe"
    'codex.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\OpenAI.Codex_Microsoft.Winget.Source_8wekyb3d8bbwe\codex-x86_64-pc-windows-msvc.exe"
}

# opencode (installed via bun, use .cmd wrapper)
$opencodeTarget = "$env:USERPROFILE\.cache\.bun\bin\opencode.exe"
$opencodeWrapper = Join-Path $localBin "opencode.cmd"
if (Test-Path $opencodeTarget) {
    if (Test-Path $opencodeWrapper) { Remove-Item -Path $opencodeWrapper -Force }
    $wrapperContent = "@echo off`n`"$opencodeTarget`" %*"
    Set-Content -Path $opencodeWrapper -Value $wrapperContent -Encoding ASCII -Force
    $createdLinks += "opencode.cmd"
    Write-Host "[OK] Created opencode.cmd wrapper" -ForegroundColor Green
}

foreach ($name in $wingetTools.Keys) {
    $target = $wingetTools[$name]
    $link = Join-Path $localBin $name
    
    if (Test-Path $target) {
        if (Test-Path $link) {
            Remove-Item -Path $link -Force
        }
        try {
            New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null
            $createdLinks += $name
        } catch {
            $warnings += "Failed to create symlink for $name`: $_"
        }
    } else {
        $warnings += "Tool not found: $target"
    }
}

# mise-en-place (winget: jdx.mise)
$misePaths = @(
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe\mise\bin\mise.exe",
    "$env:LOCALAPPDATA\Programs\mise\bin\mise.exe",
    "$env:LOCALAPPDATA\mise\bin\mise.exe",
    "$env:ProgramFiles\mise\bin\mise.exe"
)
$miseFound = $false
foreach ($path in $misePaths) {
    if (Test-Path $path) {
        $link = Join-Path $localBin "mise.exe"
        if (Test-Path $link) { Remove-Item -Path $link -Force }
        New-Item -ItemType SymbolicLink -Path $link -Target $path -Force | Out-Null
        $createdLinks += "mise.exe"
        $miseFound = $true
        break
    }
}
if (-not $miseFound) {
    $warnings += "mise.exe not found in standard locations"
}

# Starship (usualmente en Program Files)
$starshipPaths = @(
    "${env:ProgramFiles}\starship\bin\starship.exe",
    "${env:LOCALAPPDATA}\Programs\Starship\bin\starship.exe",
    "${env:ProgramFiles(x86)}\starship\bin\starship.exe"
)
$starshipFound = $false
foreach ($path in $starshipPaths) {
    if (Test-Path $path) {
        $link = Join-Path $localBin "starship.exe"
        if (Test-Path $link) { Remove-Item -Path $link -Force }
        New-Item -ItemType SymbolicLink -Path $link -Target $path -Force | Out-Null
        $createdLinks += "starship.exe"
        $starshipFound = $true
        break
    }
}
if (-not $starshipFound) {
    $warnings += "starship.exe not found in standard locations"
}

# ============================================
# 5. Node.js (instalado via mise)
# ============================================

# ============================================
# 6. Go (instalado via mise)

# ============================================
# 7. CREAR SYMLINKS para Docker CLI
# ============================================
$dockerBin = "C:\Program Files\Docker\Docker\resources\bin"
$dockerTools = @('docker.exe', 'docker-compose.exe', 'kubectl.exe')
foreach ($name in $dockerTools) {
    $target = Join-Path $dockerBin $name
    $link = Join-Path $localBin $name
    if (Test-Path $target) {
        if (Test-Path $link) { Remove-Item -Path $link -Force }
        try {
            New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null
            $createdLinks += $name
        } catch {
            $warnings += "Failed to create symlink for $name`: $_"
        }
    }
}

# ============================================
# 8. CREAR SYMLINKS para Podman CLI
# ============================================
$podmanBin = "C:\Program Files\RedHat\Podman"
$podmanTools = @('podman.exe')
foreach ($name in $podmanTools) {
    $target = Join-Path $podmanBin $name
    $link = Join-Path $localBin $name
    if (Test-Path $target) {
        if (Test-Path $link) { Remove-Item -Path $link -Force }
        try {
            New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null
            $createdLinks += $name
        } catch {
            $warnings += "Failed to create symlink for $name`: $_"
        }
    }
}

# ============================================
# 9. CREAR WRAPPERS para Neovim
# ============================================
$nvimBin = "C:\Program Files\Neovim\bin"

# nvim.exe: wrapper .cmd porque symlink falla (necesita runtime files)
$nvimExe = Join-Path $nvimBin "nvim.exe"
if (Test-Path $nvimExe) {
    $wrapper = Join-Path $localBin "nvim.cmd"
    $content = "@echo off`n`"$nvimExe`" %*"
    Set-Content -Path $wrapper -Value $content -Encoding ASCII -Force
    $createdLinks += "nvim.cmd (wrapper)"
}

# win32yank.exe: symlink funciona (autocontenido)
$win32yank = Join-Path $nvimBin "win32yank.exe"
if (Test-Path $win32yank) {
    $link = Join-Path $localBin "win32yank.exe"
    if (Test-Path $link) { Remove-Item -Path $link -Force }
    try {
        New-Item -ItemType SymbolicLink -Path $link -Target $win32yank -Force | Out-Null
        $createdLinks += "win32yank.exe"
    } catch {
        $warnings += "Failed to create symlink for win32yank.exe`: $_"
    }
}

# ============================================
# 10. CREAR SYMLINKS para WezTerm
# ============================================
$weztermBin = "C:\Program Files\WezTerm"
$weztermTools = @('wezterm.exe', 'wezterm-gui.exe')
foreach ($name in $weztermTools) {
    $target = Join-Path $weztermBin $name
    $link = Join-Path $localBin $name
    if (Test-Path $target) {
        if (Test-Path $link) { Remove-Item -Path $link -Force }
        try {
            New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null
            $createdLinks += $name
        } catch {
            $warnings += "Failed to create symlink for $name`: $_"
        }
    }
}

# ============================================
# 14. CREAR SYMLINKS para Git
# ============================================
$gitCmd = "C:\Program Files\Git\cmd"
$gitTools = @('git.exe')
foreach ($name in $gitTools) {
    $target = Join-Path $gitCmd $name
    $link = Join-Path $localBin $name
    if (Test-Path $target) {
        if (Test-Path $link) { Remove-Item -Path $link -Force }
        try {
            New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null
            $createdLinks += $name
        } catch {
            $warnings += "Failed to create symlink for $name`: $_"
        }
    }
}

# ============================================
# 15. LIMPIAR VARIABLES OBSOLETAS
# ============================================
[Environment]::SetEnvironmentVariable("JAVA_HOME", $null, "User")
[Environment]::SetEnvironmentVariable("MAVEN_HOME", $null, "User")
Write-Host "[OK] Removed obsolete JAVA_HOME and MAVEN_HOME" -ForegroundColor Green

# ============================================
# 16. CONFIGURAR VARIABLES DE ENTORNO MISE
# ============================================
$miseDataDir = "$env:USERPROFILE\.local\share\mise"
$miseConfigDir = "$env:USERPROFILE\.config\mise"
$miseShimsDir = "$miseDataDir\shims"

[Environment]::SetEnvironmentVariable("MISE_DATA_DIR", $miseDataDir, "User")
[Environment]::SetEnvironmentVariable("MISE_CONFIG_DIR", $miseConfigDir, "User")
Write-Host "[OK] Set MISE_DATA_DIR=$miseDataDir" -ForegroundColor Green
Write-Host "[OK] Set MISE_CONFIG_DIR=$miseConfigDir" -ForegroundColor Green

# ============================================
# 17. LIMPIAR PATH
# ============================================
$userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
$pathsToRemove = @(
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_8wekyb3d8bbwe\ripgrep-15.1.0-x86_64-pc-windows-msvc"
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_8wekyb3d8bbwe\fd-v10.4.2-x86_64-pc-windows-msvc"
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\JesseDuffield.lazygit_Microsoft.Winget.Source_8wekyb3d8bbwe"
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\junegunn.fzf_Microsoft.Winget.Source_8wekyb3d8bbwe"
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\twpayne.chezmoi_Microsoft.Winget.Source_8wekyb3d8bbwe"
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\OpenAI.Codex_Microsoft.Winget.Source_8wekyb3d8bbwe"
    "$env:USERPROFILE\go\bin"
    "$env:USERPROFILE\bin"
    "C:\Program Files\Go\bin"
    "C:\Program Files\Eclipse Adoptium\jdk-21.0.9.10-hotspot\bin"
    "C:\Program Files\Eclipse Adoptium\jdk-21.0.9.10-hotspot\\bin"
    "$env:USERPROFILE\Dropbox\DEV\tools\Maven\bin"
    "%MAVEN_HOME%\bin"
    # GitHub CLI (moved to ~/.local/bin)
    "C:\Program Files\GitHub CLI"
    "C:\Program Files\GitHub CLI\"
    # Starship (symlinked to ~/.local/bin)
    "C:\Program Files\starship\bin"
    "C:\Program Files\starship\bin\"
    # Docker (symlinked to ~/.local/bin)
    "C:\Program Files\Docker\Docker\resources\bin"
    # Neovim (symlinked to ~/.local/bin)
    "C:\Program Files\Neovim\bin"
    # WezTerm (symlinked to ~/.local/bin)
    "C:\Program Files\WezTerm"
    "C:\Program Files\WezTerm\"
    # Git (symlinked to ~/.local/bin)
    "C:\Program Files\Git\cmd"
    # Podman CLI (symlinked to ~/.local/bin)
    "C:\Program Files\RedHat\Podman"
    "C:\Program Files\RedHat\Podman\"
)

foreach ($path in $pathsToRemove) {
    if ($userPath -like "*$path*") {
        $userPath = $userPath -replace [regex]::Escape($path), ''
        $userPath = $userPath -replace ';;', ';'
        $removedPaths += $path
    }
}

# Asegurar que ~/.local/bin y mise shims estan en PATH
if ($userPath -notlike "*$localBin*") {
    $userPath = "$localBin;$userPath"
}
if ($userPath -notlike "*$miseShimsDir*") {
    $userPath = "$miseShimsDir;$userPath"
}

# Asegurar que mise bin está en PATH (para poder usar mise directamente)
$miseBinDir = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe\mise\bin"
if ($userPath -notlike "*jdx.mise*") {
    $userPath = "$miseBinDir;$userPath"
}

# Limpiar ; inicial o final
$userPath = $userPath -replace '^;', '' -replace ';$', ''

[Environment]::SetEnvironmentVariable('PATH', $userPath, 'User')

if ($removedPaths.Count -gt 0) {
    Write-Host "[OK] Removed $($removedPaths.Count) obsolete paths from USER PATH" -ForegroundColor Green
}

# ============================================
# 18. LIMPIAR MACHINE PATH (si es posible)
# ============================================
$machinePath = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
$machinePathsToRemove = @(
    "C:\Program Files\GitHub CLI\"
    "C:\Program Files\Go\bin"
    "C:\Users\buble\Dropbox\DEV\tools\Maven\bin"
    "C:\Users\buble\go\bin"
    # Starship (symlinked to ~/.local/bin)
    "C:\Program Files\starship\bin\"
    # Docker (symlinked to ~/.local/bin)
    "C:\Program Files\Docker\Docker\resources\bin"
    # Neovim (symlinked to ~/.local/bin)
    "C:\Program Files\Neovim\bin"
    # Bottom (symlinked to ~/.local/bin)
    "C:\Program Files\bottom\bin\"
    # WezTerm (symlinked to ~/.local/bin)
    "C:\Program Files\WezTerm"
    # Git (symlinked to ~/.local/bin)
    "C:\Program Files\Git\cmd"
)

$machineRemoved = @()
foreach ($path in $machinePathsToRemove) {
    if ($machinePath -like "*$path*") {
        $machinePath = $machinePath -replace [regex]::Escape($path), ''
        $machinePath = $machinePath -replace ';;', ';'
        $machineRemoved += $path
    }
}

if ($machineRemoved.Count -gt 0) {
    $machinePath = $machinePath -replace '^;', '' -replace ';$', ''
    try {
        [Environment]::SetEnvironmentVariable('PATH', $machinePath, 'Machine')
        Write-Host "[OK] Removed $($machineRemoved.Count) obsolete paths from MACHINE PATH" -ForegroundColor Green
    } catch {
        $warnings += "Could not clean MACHINE PATH (requires admin): $_"
    }
}

# ============================================
# 18. WSL-OPENCODE WRAPPER
# ============================================
# Managed by chezmoi: home/.local/bin/wsl-opencode.ps1
$wslOpencodePath = Join-Path $localBin "wsl-opencode.ps1"
if (-not (Test-Path $wslOpencodePath)) {
    # Fallback if chezmoi didn't place it (should not happen)
    $opencodePath = "/home/jon/.opencode/bin/opencode"
    $wslOpencodeContent = @"
#!/usr/bin/env pwsh
param(
    [Parameter(ValueFromRemainingArguments = `$true)]
    `$Args
)
`$opencodePath = "$opencodePath"
`$command = "`$opencodePath `$Args"
wsl bash -lc "`$command"
"@
    Set-Content -Path $wslOpencodePath -Value $wslOpencodeContent -Encoding UTF8 -Force
    Write-Host "[OK] Created wsl-opencode.ps1 wrapper (fallback)" -ForegroundColor Yellow
} else {
    Write-Host "[OK] wsl-opencode.ps1 already in place (chezmoi-managed)" -ForegroundColor Green
}
# ============================================
Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Local Bin Consolidation Complete" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "[MOVED]   $($movedItems.Count) items physically moved" -ForegroundColor Green
Write-Host "[LINKED]  $($createdLinks.Count) symlinks created" -ForegroundColor Green
Write-Host "[CLEANED] $($removedPaths.Count) USER PATH entries removed" -ForegroundColor Green
Write-Host "[CLEANED] $($machineRemoved.Count) MACHINE PATH entries removed" -ForegroundColor Green

if ($warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "[WARNINGS]" -ForegroundColor Yellow
    foreach ($warn in $warnings) {
        Write-Host "  ! $warn" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[INFO] Restart your terminal to apply PATH changes" -ForegroundColor Magenta
Write-Host "===============================================" -ForegroundColor Cyan