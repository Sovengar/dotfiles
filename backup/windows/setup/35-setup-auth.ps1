$ErrorActionPreference = "Continue"

$response = Read-Host "Authenticate GitHub CLI (gh auth login)? (y/n)"
if ($response -match '^[yY]') {
    gh auth login
    if ($LASTEXITCODE -eq 0) { Write-Host "[OK] GitHub authenticated" -ForegroundColor Green }
    else { Write-Host "[WARN] gh auth login failed or skipped" -ForegroundColor Yellow }
}

$response = Read-Host "Authenticate GitLab CLI (glab auth login)? (y/n)"
if ($response -match '^[yY]') {
    glab auth login
    if ($LASTEXITCODE -eq 0) { Write-Host "[OK] GitLab authenticated" -ForegroundColor Green }
    else { Write-Host "[WARN] glab auth login failed or skipped" -ForegroundColor Yellow }
}

