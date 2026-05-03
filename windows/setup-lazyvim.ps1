# setup-lazyvim.ps1
# BuildTools manual setup + LazyVim first-run (nvim trigger).
# Run AFTER chezmoi apply on a freshly formatted machine.
# NOTE: This is part of the FORMATEO flow, not the dotfiles flow.
#       Dotfiles flow handles: Neovim, fzf, ripgrep, tree-sitter CLI, LazyVim starter clone.

$ErrorActionPreference = "Continue"

function Log($msg, $color = "White") {
    Write-Host "[$(Get-Date -Format HH:mm:ss)] $msg" -ForegroundColor $color
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  LazyVim Full Setup" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 1. Verify Neovim is installed
# ============================================
$nvimExe = "C:\Program Files\Neovim\bin\nvim.exe"
if (-not (Test-Path $nvimExe)) {
    Log "Neovim not found. Run 'chezmoi apply' first (installs via winget)." "Red"
    exit 1
}
Log "Neovim detected." "Green"

# ============================================
# 2. Install Microsoft Visual Studio BuildTools
# ============================================
Log "Installing Visual Studio 2022 BuildTools..." "Yellow"
try {
    winget install --id Microsoft.VisualStudio.2022.BuildTools --silent --accept-package-agreements --accept-source-agreements
    Log "BuildTools installer launched." "Green"
} catch {
    Log "WARNING: winget install failed. You may need to download manually." "Red"
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   MANUAL STEP REQUIRED" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "In the Visual Studio Installer window:" -ForegroundColor White
Write-Host ""
Write-Host "1. Select:  'Desktop development with C++'" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. In the Installation details panel on the right," -ForegroundColor White
Write-Host "   ENSURE these are checked:" -ForegroundColor White
Write-Host "   - Windows SDK" -ForegroundColor Green
Write-Host "   - MSVC v143 - VS 2022 C++ x64/x86 build tools" -ForegroundColor Green
Write-Host ""
Write-Host "3. Click Install (bottom-right)" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Wait for completion (may take 10-20 min)" -ForegroundColor White
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 3. Backup existing nvim config (if any)
# NOTE: Neovim 0.12+ uses ~/.config/nvim/ (not %LOCALAPPDATA%/nvim/)
# ============================================
$nvimDir = "$env:USERPROFILE\.config\nvim"
$nvimDataDir = "$env:USERPROFILE\.local\share\nvim-data"

if (Test-Path $nvimDir) {
    $backupDir = "$nvimDir.bak.$(Get-Date -Format yyyyMMdd-HHmmss)"
    Move-Item -Path $nvimDir -Destination $backupDir -Force
    Log "Backed up old nvim config to: $backupDir" "Yellow"
}
if (Test-Path $nvimDataDir) {
    $backupDataDir = "$nvimDataDir.bak.$(Get-Date -Format yyyyMMdd-HHmmss)"
    Move-Item -Path $nvimDataDir -Destination $backupDataDir -Force
    Log "Backed up old nvim-data to: $backupDataDir" "Yellow"
}

# ============================================
# 4. Clone LazyVim starter (if not already present)
# ============================================
if (-not (Test-Path "$nvimDir\init.lua")) {
    Log "Cloning LazyVim starter..." "Yellow"
    git clone https://github.com/LazyVim/starter "$nvimDir" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Remove-Item -Path "$nvimDir\.git" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$nvimDir\README.md" -Force -ErrorAction SilentlyContinue
        Log "LazyVim starter cloned." "Green"
    } else {
        Log "FAILED to clone LazyVim starter." "Red"
        exit 1
    }
} else {
    Log "LazyVim starter already present." "Green"
}

# ============================================
# 5. First nvim run (triggers LazyVim plugin install)
# ============================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   FIRST NEOVIM LAUNCH" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Log "Opening Neovim to install LazyVim plugins..." "Yellow"
Write-Host ""
Write-Host "When Neovim opens:" -ForegroundColor White
Write-Host "  1. Wait for LazyVim to download and install plugins" -ForegroundColor Yellow
Write-Host "  2. Press 'q' to close the LazyVim dashboard" -ForegroundColor Yellow
Write-Host "  3. Type ':qa' and press Enter to quit" -ForegroundColor Yellow
Write-Host ""
Start-Process -FilePath $nvimExe -Wait
Log "LazyVim plugins installed." "Green"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  LazyVim setup complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Log "Custom configs from chezmoi will overlay the starter on next apply." "Green"
