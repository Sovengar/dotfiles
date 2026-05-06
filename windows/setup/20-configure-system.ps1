$ErrorActionPreference = "Continue"
$localBin = "$env:USERPROFILE\.local\bin"
$toolingPath = "$env:USERPROFILE\dev\tooling"
$createdLinks = @()
$movedItems = @()
$removedPaths = @()
$warnings = @()

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

New-Item -ItemType Directory -Force -Path $localBin | Out-Null
Write-Host "[INFO] Consolidating executables to $localBin" -ForegroundColor Cyan

function Move-BinContents {
    param([string]$SourceDir, [string]$Label)
    if (-not (Test-Path $SourceDir)) { return @() }
    $moved = @()
    $items = Get-ChildItem -Path $SourceDir -Recurse -File
    foreach ($item in $items) {
        $relativePath = $item.FullName.Substring($SourceDir.Length + 1)
        $dest = Join-Path $localBin $relativePath
        $destDir = Split-Path -Parent $dest
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        if (Test-Path $dest) { Remove-Item -Path $dest -Force }
        Move-Item -Path $item.FullName -Destination $dest -Force
        $moved += $relativePath
    }
    if ($moved.Count -gt 0 -and (Get-ChildItem -Path $SourceDir -Recurse -File).Count -eq 0) {
        Remove-Item -Path $SourceDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "[OK] Moved $($moved.Count) items from $Label" -ForegroundColor Green
    return $moved
}

$movedItems += Move-BinContents -SourceDir "$env:USERPROFILE\go\bin" -Label "~/go/bin"
$movedItems += Move-BinContents -SourceDir "$env:USERPROFILE\bin" -Label "~/bin"

$ghSystemPath = "C:\Program Files\GitHub CLI\gh.exe"
$ghLocalPath = Join-Path $localBin "gh.exe"
if (Test-Path $ghSystemPath -and -not (Test-Path $ghLocalPath)) {
    try {
        Move-Item -Path $ghSystemPath -Destination $ghLocalPath -Force
        $movedItems += "gh.exe"
        Write-Host "[OK] Moved gh.exe from system to ~/.local/bin" -ForegroundColor Green
    } catch {
        $warnings += "Failed to move gh.exe: $_"
    }
}

$wingetTools = @{
    'rg.exe'       = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_8wekyb3d8bbwe\ripgrep-15.1.0-x86_64-pc-windows-msvc\rg.exe"
    'fd.exe'       = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_8wekyb3d8bbwe\fd-v10.4.2-x86_64-pc-windows-msvc\fd.exe"
    'gk.exe'       = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GitKraken.cli_Microsoft.Winget.Source_8wekyb3d8bbwe\gk.exe"
    'lazygit.exe'  = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\JesseDuffield.lazygit_Microsoft.Winget.Source_8wekyb3d8bbwe\lazygit.exe"
    'fzf.exe'      = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\junegunn.fzf_Microsoft.Winget.Source_8wekyb3d8bbwe\fzf.exe"
    'chezmoi.exe'  = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\twpayne.chezmoi_Microsoft.Winget.Source_8wekyb3d8bbwe\chezmoi.exe"
    'codex.exe'    = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\OpenAI.Codex_Microsoft.Winget.Source_8wekyb3d8bbwe\codex-x86_64-pc-windows-msvc.exe"
}

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
        if (Test-Path $link) { Remove-Item -Path $link -Force }
        try {
            New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null
            $createdLinks += $name
        } catch { $warnings += "Failed to create symlink for $($name): $_" }
    } else { $warnings += "Tool not found: $target" }
}

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
        $miseFound = $true; break
    }
}
if (-not $miseFound) { $warnings += "mise.exe not found" }

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
        $starshipFound = $true; break
    }
}
if (-not $starshipFound) { $warnings += "starship.exe not found" }

$dockerBin = "C:\Program Files\Docker\Docker\resources\bin"
foreach ($name in @('docker.exe', 'docker-compose.exe', 'kubectl.exe')) {
    $target = Join-Path $dockerBin $name
    $link = Join-Path $localBin $name
    if (Test-Path $target) {
        if (Test-Path $link) { Remove-Item -Path $link -Force }
        try { New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null; $createdLinks += $name } catch { $warnings += "Failed $($name): $_" }
    }
}

$podmanBin = "C:\Program Files\RedHat\Podman"
foreach ($name in @('podman.exe')) {
    $target = Join-Path $podmanBin $name
    $link = Join-Path $localBin $name
    if (Test-Path $target) {
        if (Test-Path $link) { Remove-Item -Path $link -Force }
        try { New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null; $createdLinks += $name } catch { $warnings += "Failed $($name): $_" }
    }
}

$nvimBin = "C:\Program Files\Neovim\bin"
$nvimExe = Join-Path $nvimBin "nvim.exe"
if (Test-Path $nvimExe) {
    $wrapper = Join-Path $localBin "nvim.cmd"
    $content = "@echo off`n`"$nvimExe`" %*"
    Set-Content -Path $wrapper -Value $content -Encoding ASCII -Force
    $createdLinks += "nvim.cmd (wrapper)"
}
$win32yank = Join-Path $nvimBin "win32yank.exe"
if (Test-Path $win32yank) {
    $link = Join-Path $localBin "win32yank.exe"
    if (Test-Path $link) { Remove-Item -Path $link -Force }
    try { New-Item -ItemType SymbolicLink -Path $link -Target $win32yank -Force | Out-Null; $createdLinks += "win32yank.exe" } catch { $warnings += "Failed win32yank: $_" }
}

$weztermBin = "C:\Program Files\WezTerm"
foreach ($name in @('wezterm.exe', 'wezterm-gui.exe')) {
    $target = Join-Path $weztermBin $name
    $link = Join-Path $localBin $name
    if (Test-Path $target) {
        if (Test-Path $link) { Remove-Item -Path $link -Force }
        try { New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null; $createdLinks += $name } catch { $warnings += "Failed $($name): $_" }
    }
}

$ideaSource = "$toolingPath\IntelliJ IDEA\bin\idea64.exe"
$ideaLink = Join-Path $localBin "idea.exe"
if (Test-Path $ideaSource) {
    if (Test-Path $ideaLink) { Remove-Item -Path $ideaLink -Force }
    try { New-Item -ItemType SymbolicLink -Path $ideaLink -Target $ideaSource -Force | Out-Null; $createdLinks += "idea.exe" } catch { $warnings += "Failed idea.exe: $_" }
} else { $warnings += "IntelliJ IDEA not found" }

$antigravityDir = "$toolingPath\Antigravity"
$antigravityExe = Join-Path $antigravityDir "Antigravity.exe"
$antigravityCli = Join-Path $antigravityDir "resources\app\out\cli.js"
if (Test-Path $antigravityExe) {
    $wrapper = Join-Path $localBin "antigravity.cmd"
    $content = "@echo off`nset ELECTRON_RUN_AS_NODE=1`n`"$antigravityExe`" `"$antigravityCli`" %*"
    Set-Content -Path $wrapper -Value $content -Encoding ASCII -Force
    $createdLinks += "antigravity.cmd (wrapper)"
    Write-Host "[OK] Created antigravity.cmd wrapper" -ForegroundColor Green
} else { $warnings += "Antigravity not found" }

foreach ($name in @('git.exe')) {
    $target = "C:\Program Files\Git\cmd\$name"
    $link = Join-Path $localBin $name
    if (Test-Path $target) {
        if (Test-Path $link) { Remove-Item -Path $link -Force }
        try { New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null; $createdLinks += $name } catch { $warnings += "Failed $($name): $_" }
    }
}

[Environment]::SetEnvironmentVariable("JAVA_HOME", $null, "User")
[Environment]::SetEnvironmentVariable("MAVEN_HOME", $null, "User")
Write-Host "[OK] Removed obsolete JAVA_HOME and MAVEN_HOME" -ForegroundColor Green

$miseDataDir = "$env:USERPROFILE\.local\share\mise"
$miseConfigDir = "$env:USERPROFILE\.config\mise"
$miseShimsDir = "$miseDataDir\shims"
[Environment]::SetEnvironmentVariable("MISE_DATA_DIR", $miseDataDir, "User")
[Environment]::SetEnvironmentVariable("MISE_CONFIG_DIR", $miseConfigDir, "User")
Write-Host "[OK] Set MISE_DATA_DIR and MISE_CONFIG_DIR" -ForegroundColor Green

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
    "%MAVEN_HOME%\bin"
    "C:\Program Files\GitHub CLI"
    "C:\Program Files\GitHub CLI\"
    "C:\Program Files\starship\bin"
    "C:\Program Files\starship\bin\"
    "C:\Program Files\Docker\Docker\resources\bin"
    "C:\Program Files\Neovim\bin"
    "C:\Program Files\WezTerm"
    "C:\Program Files\WezTerm\"
    "C:\Program Files\Git\cmd"
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

if ($userPath -notlike "*$localBin*") { $userPath = "$localBin;$userPath" }
if ($userPath -notlike "*$miseShimsDir*") { $userPath = "$miseShimsDir;$userPath" }
$userPath = $userPath -replace '^;', '' -replace ';$', ''
[Environment]::SetEnvironmentVariable('PATH', $userPath, 'User')

$machinePath = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
$machinePathsToRemove = @(
    "C:\Program Files\GitHub CLI\"
    "C:\Program Files\Go\bin"
    "$env:USERPROFILE\Dropbox\DEV\tools\Maven\bin"
    "$env:USERPROFILE\go\bin"
    "C:\Program Files\starship\bin\"
    "C:\Program Files\Docker\Docker\resources\bin"
    "C:\Program Files\Neovim\bin"
    "C:\Program Files\bottom\bin\"
    "C:\Program Files\WezTerm"
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
    try { [Environment]::SetEnvironmentVariable('PATH', $machinePath, 'Machine'); Write-Host "[OK] Cleaned MACHINE PATH" -ForegroundColor Green } catch { $warnings += "Could not clean MACHINE PATH (requires admin)" }
}

$wslOpencodePath = Join-Path $localBin "wsl-opencode.ps1"
$wslOpencodeContent = @"
#!/usr/bin/env pwsh
param(
    [Parameter(ValueFromRemainingArguments = `$true)]
    `$Args
)
`$opencodePath = "/home/jon/.opencode/bin/opencode"
`$command = "`$opencodePath `$Args"
wsl bash -lc "`$command"
"@
Set-Content -Path $wslOpencodePath -Value $wslOpencodeContent -Encoding UTF8 -Force
Write-Host "[OK] Created wsl-opencode.ps1 wrapper" -ForegroundColor Green

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  System Configuration Complete" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "[MOVED]   $($movedItems.Count) items" -ForegroundColor Green
Write-Host "[LINKED]  $($createdLinks.Count) symlinks" -ForegroundColor Green
Write-Host "[CLEANED] $($removedPaths.Count) USER PATH + $($machineRemoved.Count) MACHINE PATH" -ForegroundColor Green
if ($warnings.Count -gt 0) {
    Write-Host "`n[WARNINGS]" -ForegroundColor Yellow
    foreach ($warn in $warnings) { Write-Host "  ! $warn" -ForegroundColor Yellow }
}
Write-Host "`n[INFO] Restart your terminal to apply PATH changes" -ForegroundColor Magenta
