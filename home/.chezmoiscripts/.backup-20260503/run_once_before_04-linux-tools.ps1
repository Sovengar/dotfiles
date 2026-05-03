# run_once_before_04-linux-tools.ps1
# Instala herramientas Linux-style para Windows si no estan presentes
# Se ejecuta automaticamente al hacer chezmoi apply

$ErrorActionPreference = "Continue"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Verificando herramientas tipo Linux" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

$tools = @(
    @{ 
        Name = "btm"; 
        WingetId = "Clement.bottom";
        Description = "Monitor de procesos (alternativa a htop)"
    },
    @{ 
        Name = "rg"; 
        WingetId = "BurntSushi.ripgrep.MSVC";
        Description = "Buscador de texto ultra-rapido (alternativa a grep)"
    },
    @{ 
        Name = "fd"; 
        WingetId = "sharkdp.fd";
        Description = "Buscador de archivos (alternativa a find)"
    }
)

foreach ($tool in $tools) {
    Write-Host ""
    Write-Host "[$($tool.Name)] $($tool.Description)" -ForegroundColor Yellow
    
    if (Get-Command $tool.Name -ErrorAction SilentlyContinue) {
        Write-Host "  ✓ Ya instalado" -ForegroundColor Green
    } else {
        Write-Host "  → Instalando via winget..." -ForegroundColor DarkYellow
        try {
            winget install --id $tool.WingetId --silent --accept-package-agreements --accept-source-agreements
            Write-Host "  ✓ Instalacion completada" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Error en la instalacion: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Verificar PATH
Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Verificando PATH" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

$requiredPaths = @(
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_8wekyb3d8bbwe\ripgrep-15.1.0-x86_64-pc-windows-msvc",
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_8wekyb3d8bbwe\fd-v10.4.2-x86_64-pc-windows-msvc",
    "$env:USERPROFILE\.local\bin"
)

$userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
$pathUpdated = $false

foreach ($p in $requiredPaths) {
    if (Test-Path $p) {
        if ($userPath -notlike "*$p*") {
            $userPath += ";$p"
            $pathUpdated = $true
            Write-Host "  → Agregando al PATH: $p" -ForegroundColor DarkYellow
        } else {
            Write-Host "  ✓ Ya en PATH: $p" -ForegroundColor Green
        }
    }
}

if ($pathUpdated) {
    [Environment]::SetEnvironmentVariable('PATH', $userPath, 'User')
    Write-Host "  ✓ PATH actualizado" -ForegroundColor Green
    Write-Host "  ⚠ Reinicia tu terminal para que los cambios surtan efecto" -ForegroundColor Magenta
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Verificacion final" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

foreach ($tool in $tools) {
    $cmd = Get-Command $tool.Name -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Host "  ✓ $($tool.Name) -> $($cmd.Source)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $($tool.Name) no encontrado" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Listo! Recarga tu perfil con: . `$PROFILE" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan