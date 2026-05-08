$ErrorActionPreference = "Continue"

$repoUrl = "https://github.com/Sovengar/cdx.git"
$projectDir = "$env:TEMP\cdx-rs-build"
$binDir = "$env:USERPROFILE\.local\bin"
$binPath = "$binDir\cdx.exe"

New-Item -ItemType Directory -Path $binDir -Force -ErrorAction SilentlyContinue | Out-Null

# Clone
Remove-Item -LiteralPath $projectDir -Recurse -Force -ErrorAction SilentlyContinue
git clone $repoUrl $projectDir 2>$null

if (-not (Test-Path "$projectDir\Cargo.toml")) {
    Write-Host "[cdx] Failed to clone repo" -ForegroundColor Red
    exit 1
}

# Check Rust
$hasRust = Get-Command rustc -ErrorAction SilentlyContinue
if (-not $hasRust) {
    Write-Host "[cdx] Rust not found, installing via rustup..." -ForegroundColor Yellow
    $rustupUrl = "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
    $rustupPath = "$env:TEMP\rustup-init.exe"
    Invoke-WebRequest -Uri $rustupUrl -OutFile $rustupPath
    & $rustupPath -y
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "User")
}

# Build
Push-Location $projectDir
Write-Host "[cdx] Building release..." -ForegroundColor Cyan
cargo build --release
$buildOk = $LASTEXITCODE -eq 0
Pop-Location

if (-not $buildOk) {
    Write-Host "[cdx] Build failed" -ForegroundColor Red
    Remove-Item -LiteralPath $projectDir -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Copy binary (retry if in use)
$retries = 5
do {
    try {
        Copy-Item -LiteralPath "$projectDir\target\release\cdx-rs.exe" -Destination $binPath -Force -ErrorAction Stop
        $copied = $true
    } catch {
        $copied = $false
        $retries--
        if ($retries -gt 0) {
            Write-Host "[cdx] Binary in use, retrying in 2s..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
} while (-not $copied -and $retries -gt 0)

# Cleanup
Remove-Item -LiteralPath $projectDir -Recurse -Force -ErrorAction SilentlyContinue

if ($copied) {
    Write-Host "[cdx] Installed to $binPath" -ForegroundColor Green
} else {
    Write-Host "[cdx] Could not copy binary (in use). Close cdx and re-run." -ForegroundColor Red
}
