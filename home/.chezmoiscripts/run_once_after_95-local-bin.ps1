# run_once_after_95-local-bin.ps1
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
# 3. CREAR SYMLINKS para herramientas WinGet
# ============================================
$wingetTools = @{
    'rg.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_8wekyb3d8bbwe\ripgrep-15.1.0-x86_64-pc-windows-msvc\rg.exe"
    'fd.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_8wekyb3d8bbwe\fd-v10.4.2-x86_64-pc-windows-msvc\fd.exe"
    'lazygit.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\JesseDuffield.lazygit_Microsoft.Winget.Source_8wekyb3d8bbwe\lazygit.exe"
    'fzf.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\junegunn.fzf_Microsoft.Winget.Source_8wekyb3d8bbwe\fzf.exe"
    'chezmoi.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\twpayne.chezmoi_Microsoft.Winget.Source_8wekyb3d8bbwe\chezmoi.exe"
    'codex.exe' = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\OpenAI.Codex_Microsoft.Winget.Source_8wekyb3d8bbwe\codex-x86_64-pc-windows-msvc.exe"
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
# 4. CREAR SYMLINKS para NVM y Node.js
# ============================================
$nvmHome = "$env:LOCALAPPDATA\nvm"
$nvmSymlink = "C:\nvm4w\nodejs"

# nvm.exe
$nvmExe = Join-Path $nvmHome 'nvm.exe'
if (Test-Path $nvmExe) {
    $link = Join-Path $localBin 'nvm.exe'
    if (Test-Path $link) { Remove-Item -Path $link -Force }
    try {
        New-Item -ItemType SymbolicLink -Path $link -Target $nvmExe -Force | Out-Null
        $createdLinks += 'nvm.exe'
    } catch {
        $warnings += "Failed to create symlink for nvm.exe`: $_"
    }
}

# node.exe (symlink funciona porque es un exe simple)
$nodeExe = Join-Path $nvmSymlink 'node.exe'
if (Test-Path $nodeExe) {
    $link = Join-Path $localBin 'node.exe'
    if (Test-Path $link) { Remove-Item -Path $link -Force }
    try {
        New-Item -ItemType SymbolicLink -Path $link -Target $nodeExe -Force | Out-Null
        $createdLinks += 'node.exe'
    } catch {
        $warnings += "Failed to create symlink for node.exe`: $_"
    }
}

Write-Host "[OK] Created $($createdLinks.Count) symlinks" -ForegroundColor Green

# ============================================
# 5. CREAR SYMLINKS para Go
# ============================================
$goPath = "${env:ProgramFiles}\Go\bin\go.exe"
if (Test-Path $goPath) {
    $link = Join-Path $localBin "go.exe"
    if (Test-Path $link) { Remove-Item -Path $link -Force }
    try {
        New-Item -ItemType SymbolicLink -Path $link -Target $goPath -Force | Out-Null
        $createdLinks += "go.exe"
    } catch {
        $warnings += "Failed to create symlink for go.exe`: $_"
    }
} else {
    $warnings += "go.exe not found in $goPath"
}

# ============================================
# 6. CREAR SYMLINKS para Java JDK
# ============================================
$javaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User")
if (-not $javaHome) { $javaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine") }

if ($javaHome -and (Test-Path $javaHome)) {
    $javaBin = Join-Path $javaHome "bin"
    $javaTools = @('java.exe', 'javac.exe', 'jar.exe', 'javadoc.exe')
    foreach ($name in $javaTools) {
        $target = Join-Path $javaBin $name
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
} else {
    $warnings += "JAVA_HOME not found or invalid"
}

# ============================================
# 7. CREAR SYMLINKS para Maven
# ============================================
$mavenHome = [Environment]::GetEnvironmentVariable("MAVEN_HOME", "User")
if ($mavenHome -and (Test-Path $mavenHome)) {
    $mvnCmd = Join-Path $mavenHome "bin\mvn.cmd"
    if (Test-Path $mvnCmd) {
        $link = Join-Path $localBin "mvn.cmd"
        if (Test-Path $link) { Remove-Item -Path $link -Force }
        try {
            New-Item -ItemType SymbolicLink -Path $link -Target $mvnCmd -Force | Out-Null
            $createdLinks += "mvn.cmd"
        } catch {
            $warnings += "Failed to create symlink for mvn.cmd`: $_"
        }
    }
} else {
    $warnings += "MAVEN_HOME not found or invalid"
}

# ============================================
# 8. LIMPIAR PATH
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
    "$env:USERPROFILE\Dropbox\DEV\tools\Maven\bin"
    # NVM paths
    "$env:LOCALAPPDATA\nvm"
    "C:\nvm4w\nodejs"
    "C:\nvm4w"
)

foreach ($path in $pathsToRemove) {
    if ($userPath -like "*$path*") {
        $userPath = $userPath -replace [regex]::Escape($path), ''
        $userPath = $userPath -replace ';;', ';'
        $removedPaths += $path
    }
}

# Asegurar que ~/.local/bin esta en PATH
if ($userPath -notlike "*$localBin*") {
    $userPath = "$localBin;$userPath"
}

# Limpiar ; inicial o final
$userPath = $userPath -replace '^;', '' -replace ';$', ''

[Environment]::SetEnvironmentVariable('PATH', $userPath, 'User')

if ($removedPaths.Count -gt 0) {
    Write-Host "[OK] Removed $($removedPaths.Count) obsolete paths from PATH" -ForegroundColor Green
}

# ============================================
# 6. RESUMEN SILENCIOSO
# ============================================
Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Local Bin Consolidation Complete" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "[MOVED]   $($movedItems.Count) items physically moved" -ForegroundColor Green
Write-Host "[LINKED]  $($createdLinks.Count) symlinks created" -ForegroundColor Green
Write-Host "[CLEANED] $($removedPaths.Count) PATH entries removed" -ForegroundColor Green

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