$ErrorActionPreference = "Continue"

$response = Read-Host "Authenticate GitHub CLI (gh auth login)? (y/n)"
if ($response -match '^[yY]') {
    gh auth login
    if ($LASTEXITCODE -eq 0) { Write-Host "[OK] GitHub authenticated" -ForegroundColor Green }
    else { Write-Host "[WARN] gh auth login failed or skipped" -ForegroundColor Yellow }
}

$response = Read-Host "Authenticate OpenCode (opencode login)? (y/n)"
if ($response -match '^[yY]') {
    Push-Location $HOME
    opencode login
    Pop-Location
    if ($LASTEXITCODE -eq 0) { Write-Host "[OK] OpenCode authenticated" -ForegroundColor Green }
    else { Write-Host "[WARN] opencode login failed or skipped" -ForegroundColor Yellow }
}
