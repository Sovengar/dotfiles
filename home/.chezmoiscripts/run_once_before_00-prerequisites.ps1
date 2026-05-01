# run_once_before_00-prerequisites.ps1
# Sets PowerShell ExecutionPolicy to allow scripts

$ErrorActionPreference = "Stop"

try {
    Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
    Write-Host "[OK] ExecutionPolicy set to RemoteSigned" -ForegroundColor Green
}
catch {
    Write-Host "[WARN] Could not set ExecutionPolicy. Run as Admin if needed." -ForegroundColor Yellow
}
