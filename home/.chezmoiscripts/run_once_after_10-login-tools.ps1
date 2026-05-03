# run_once_after_90-login-tools.ps1
# Logs into CLI tools that require authentication
# NOTE: Some of these may require interactive input

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "AUTHENTICATION REQUIRED" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The following tools need authentication:" -ForegroundColor Yellow
Write-Host "  - GitHub CLI (gh auth login)" -ForegroundColor White
Write-Host "  - OpenCode (opencode login)" -ForegroundColor White
Write-Host "  - GitHub Copilot (via VS Code or gh)" -ForegroundColor White
Write-Host ""
Write-Host "Run these commands manually after this script completes:" -ForegroundColor Yellow
Write-Host "  gh auth login" -ForegroundColor Green
Write-Host "  opencode login" -ForegroundColor Green
Write-Host ""

# Optional: Try non-interactive auth if credentials are available
$envFile = "$HOME\OneDrive\Formateo\env.toml"
if (Test-Path $envFile) {
    Write-Host "Found env.toml - you may need to export API keys manually." -ForegroundColor Yellow
}
