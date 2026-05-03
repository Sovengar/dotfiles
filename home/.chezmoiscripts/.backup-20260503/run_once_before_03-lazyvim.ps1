# run_once_before_03-lazyvim.ps1
# Clones LazyVim starter and applies custom configs

$ErrorActionPreference = "Continue"
$nvimDir = "$env:LOCALAPPDATA\nvim"

# Remove existing nvim config if present
if (Test-Path $nvimDir) {
    Remove-Item -Recurse -Force $nvimDir
    Write-Host "Removed existing nvim config" -ForegroundColor Yellow
}

# Clone LazyVim starter
try {
    git clone https://github.com/LazyVim/starter "$nvimDir"
    Write-Host "[OK] LazyVim starter cloned" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Could not clone LazyVim starter" -ForegroundColor Red
    exit 1
}

# Remove starter-specific files we don't need
Remove-Item -Path "$nvimDir\.git" -Recurse -Force
Remove-Item -Path "$nvimDir\README.md" -Force

# Note: chezmoi will overwrite the custom files (init.lua, lua/, etc.) during apply
Write-Host "LazyVim base installed. Custom configs will be applied by chezmoi." -ForegroundColor Green
