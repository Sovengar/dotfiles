<#
.SYNOPSIS
  Public launcher for Windows.
  This script lives in the PUBLIC repo (Sovengar/dotfiles).
  It installs git + gh via winget, logs into GitHub, clones the PRIVATE repo,
  and delegates to its full installer.

.DESCRIPTION
  The launcher handles only authentication and cloning.
  The private repo's setup/install.ps1 handles the full setup:
  Set-ExecutionPolicy, chezmoi init, run-all.ps1, chezmoi apply.

.EXAMPLE
  irm https://raw.githubusercontent.com/Sovengar/dotfiles/master/launchers/windows.ps1 | iex
#>

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/Sovengar/dotfiles-windows-personal.git"
$RepoDir = "$env:USERPROFILE\.local\share\chezmoi"

function Write-Step([string]$msg) {
  Write-Host "===============================================" -ForegroundColor Cyan
  Write-Host "  $msg" -ForegroundColor Cyan
  Write-Host "===============================================" -ForegroundColor Cyan
}

# ── 1. Ensure winget is available ───────────────────────────────

Write-Step "CHECKING WINGET"
$winget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $winget) {
  Write-Host "winget not found. Please install 'App Installer' from the Microsoft Store first." -ForegroundColor Red
  Write-Host "Link: https://apps.microsoft.com/detail/9nblggh4nns1" -ForegroundColor Yellow
  exit 1
}
Write-Host "[OK] winget available" -ForegroundColor Green

# ── 2. Install Git ──────────────────────────────────────────────

Write-Step "INSTALLING GIT"
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
  Write-Host "Installing Git..."
  winget install --id Git.Git -e --source winget --silent --accept-package-agreements --accept-source-agreements
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
  Write-Host "[OK] Git installed" -ForegroundColor Green
} else {
  Write-Host "[OK] Git already installed" -ForegroundColor Green
}

# ── 3. Install GitHub CLI ───────────────────────────────────────

Write-Step "INSTALLING GITHUB CLI"
$gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $gh) {
  Write-Host "Installing GitHub CLI..."
  winget install --id GitHub.cli -e --source winget --silent --accept-package-agreements --accept-source-agreements
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
  Write-Host "[OK] gh installed" -ForegroundColor Green
} else {
  Write-Host "[OK] gh already installed" -ForegroundColor Green
}

# ── 4. GitHub Auth ──────────────────────────────────────────────

Write-Step "GITHUB LOGIN"
gh auth status 2>$null
if ($?) {
  Write-Host "[OK] Already authenticated" -ForegroundColor Green
} else {
  Write-Host ""
  Write-Host "To clone private dotfiles, you need to authenticate with GitHub." -ForegroundColor Yellow
  Write-Host "GitHub CLI will open your browser. Click 'Authorize' to continue." -ForegroundColor Yellow
  Write-Host ""
  gh auth login --hostname github.com --web --git-protocol https
  if (-not $?) {
    Write-Host "[ERROR] GitHub authentication failed." -ForegroundColor Red
    exit 1
  }
  gh auth setup-git
  Write-Host "[OK] Authenticated" -ForegroundColor Green
}

# ── 5. Clone repo ───────────────────────────────────────────────

Write-Step "CLONING REPO"
if (Test-Path "$RepoDir\.git") {
  Write-Host "Repo exists. Pulling latest..."
  git -C $RepoDir pull --ff-only
} else {
  Write-Host "Cloning $RepoUrl to $RepoDir..."
  New-Item -ItemType Directory -Path (Split-Path $RepoDir) -Force | Out-Null
  git clone $RepoUrl $RepoDir
}
Write-Host "[OK] Repo ready at $RepoDir" -ForegroundColor Green

# ── 6. Delegate to private installer ────────────────────────────

Write-Step "DELEGATING TO PRIVATE INSTALLER"
$privateInstaller = Join-Path $RepoDir "setup\install.ps1"
if (Test-Path $privateInstaller) {
  Write-Host "Running private installer..."
  & $privateInstaller
} else {
  Write-Host "[ERROR] Private installer not found at $privateInstaller" -ForegroundColor Red
  exit 1
}
