# Microsoft.PowerShell_profile.fast.ps1
# Perfil MINIMO para quickterm/miniterm y sesiones de baja latencia.
# CERO binarios externos en startup. Solo definiciones puras.
# NO incluye: starship, completions, mise, zoxide, PSFzf, docker-completion, broot, PSReadLine custom handlers.

# Aliases esenciales (funciones puras, sin busqueda de binario en startup)
function op { opencode @args }
function lgit { lazygit @args }
function k { kubectl @args }

# Kubernetes
$ENV:KUBECONFIG = ".kube/prod-k8s-clcreative-kubeconfig.yaml;.kube/civo-k8s_test_1-kubeconfig;.kube/k8s_test_1.yml"

function kn {
    param ($namespace)
    if ($namespace -in "default","d") {
        kubectl config set-context --current --namespace=default
    } else {
        kubectl config set-context --current --namespace=$namespace
    }
}

# WezTerm OSC 7 Shell Integration
$PromptOld = $function:prompt
function prompt {
    $loc = Get-Location
    if ($loc.Provider.Name -eq "FileSystem") {
        $uri = [System.Uri]::new($loc.Path).AbsoluteUri
        Write-Host -NoNewLine "`e]7;${uri}`e\"
    }
    & $PromptOld
}

# Cargar comandos tipo Linux (puro codigo, no binarios)
$linuxAliases = Join-Path (Split-Path -Parent $PROFILE) 'LinuxAliases.ps1'
if (Test-Path $linuxAliases) { . $linuxAliases }

#============================
# cdx
#============================
$cdxBin = "$HOME\.local\bin\cdx.exe"
function cdx {
    if (-not (Test-Path $cdxBin)) {
        Write-Host "[!] cdx.exe not found at $cdxBin" -ForegroundColor Red
        Write-Host "    Build: cd ~/dev/cdx-rs; cargo build --release" -ForegroundColor DarkGray
        return
    }
    $resultFile = "$env:TEMP\cdx-rs-result.txt"
    Remove-Item $resultFile -ErrorAction SilentlyContinue
    & $cdxBin @args 2>$null
    if ($LASTEXITCODE -ne 0) { return }
    if (Test-Path $resultFile) {
        $target = Get-Content $resultFile -Raw
        Remove-Item $resultFile -Force
        $target = $target.Trim()
        if ($target -and (Test-Path $target)) {
            Set-Location $target
            Show-CdxResult
        }
    }
}
function Show-CdxResult {
    $path = (Get-Location).Path
    $display = if ($path.StartsWith($env:USERPROFILE)) {
        "~" + $path.Substring($env:USERPROFILE.Length).Replace('\', '/')
    } else { $path.Replace('\', '/') }
    Write-Host "`n$display" -ForegroundColor Cyan
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        eza --icons --group-directories-first
    } else { Get-ChildItem -Force | Format-Table }
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitRoot = git rev-parse --show-toplevel 2>$null
        if ($gitRoot) {
            Write-Host "  Consider using: yazi, broot, nvim, lazygit, code ." -ForegroundColor DarkGray
        }
    }
}

#============================
# rgx
#============================
$fzfRgScript = Join-Path (Split-Path -Parent $PROFILE) 'FzfRg.ps1'
if (Test-Path $fzfRgScript) { . $fzfRgScript }

#============================
# connect
#============================
function connect {
    param($target)
    switch ($target) {
        'jon' { wezterm connect jon }
        default { Write-Host "Unknown target: $target" }
    }
}
