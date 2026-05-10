# Microsoft.PowerShell_profile.ps1
# Perfil principal con lazy loading de herramientas pesadas.
# Carga la base del perfil FAST y luego anade starship, completions, etc. bajo demanda.

#============================
# Base: todo lo del perfil FAST (aliases, funciones puras, OSC7)
#============================
$fastProfile = Join-Path (Split-Path -Parent $PROFILE) 'Microsoft.PowerShell_profile.fast.ps1'
if (Test-Path $fastProfile) { . $fastProfile }

#============================
# PSReadLine (solo en perfil principal; en fast no se carga para ahorrar ~260ms)
#============================
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    $line = $null; $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    $before = $cursor
    [Microsoft.PowerShell.PSConsoleReadLine]::ForwardChar()
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($cursor -eq $before) {
        [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext()
    }
}
Set-PSReadLineKeyHandler -Key Ctrl+Shift+G -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("cdx")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

#============================
# Helper: cachear output de binarios (invalida automatico por LastWriteTime)
#============================
function Import-CachedBinaryInit {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [scriptblock] $InitScript
    )
    $bin = (Get-Command $Name -ErrorAction SilentlyContinue)?.Source
    if (-not $bin) { return }
    $cacheDir = "$HOME\.cache\pwsh-init"
    if (-not (Test-Path $cacheDir)) {
        New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    }
    # Invalidacion por LastWriteTime+Length (instantaneo vs SHA256 de un exe de 10MB)
    $fi = Get-Item $bin
    $hash = $fi.LastWriteTimeUtc.ToString("yyyyMMddHHmmss") + "-" + $fi.Length
    $cache = Join-Path $cacheDir "$Name-$hash.ps1"
    if (-not (Test-Path $cache)) {
        & $InitScript | Out-File $cache -Encoding utf8 -Force
    }
    . $cache
}

#============================
# Starship (~650ms -> ~50ms con cache)
#============================
$ENV:STARSHIP_CONFIG = "$HOME\.starship\starship.toml"
$ENV:STARSHIP_DISTRO = "者 xcad"
Import-CachedBinaryInit "starship" { starship init powershell --print-full-init }

#============================
# Zoxide (~80ms -> ~15ms con cache)
#============================
Import-CachedBinaryInit "zoxide" { zoxide init powershell }

#============================
# kubectl completion: lazy (~190ms -> 0ms en startup)
# Nota: la primera ejecucion de 'kubectl' o 'k' carga el completion.
# Si necesitas Tab-completion sin haber ejecutado kubectl, escribe 'kubectl' y dale Enter una vez.
#============================
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    function kubectl {
        Remove-Item function:kubectl
        kubectl completion powershell | Out-String | Invoke-Expression
        & kubectl @args
    }
}

#============================
# gh completion: lazy (~190ms -> 0ms en startup)
#============================
if (Get-Command gh -ErrorAction SilentlyContinue) {
    function gh {
        Remove-Item function:gh
        Invoke-Expression -Command $(& gh completion -s powershell | Out-String)
        & gh @args
    }
}

#============================
# DockerCompletion: lazy (~40ms -> 0ms en startup)
#============================
function docker {
    Remove-Item function:docker
    if (Get-Module -ListAvailable -Name DockerCompletion) {
        Import-Module DockerCompletion
    }
    & docker @args
}

#============================
# mise: lazy (~450ms -> 0ms en startup)
#============================
# Commands like opencode would not work
# if (Get-Command mise -ErrorAction SilentlyContinue) {
#     function mise {
#         Remove-Item function:mise
#         (& mise activate pwsh) | Out-String | Invoke-Expression
#         & mise @args
#     }
# }

if (Get-Command mise -ErrorAction SilentlyContinue) {
    (&mise activate pwsh) | Out-String | Invoke-Expression
}

#============================
# broot launcher: lazy (~10ms -> 0ms en startup)
#============================
function br {
    Remove-Item function:br
    $brootBr = "$HOME\AppData\Roaming\dystroy\broot\config\launcher\powershell\br.ps1"
    if (Test-Path $brootBr) { . $brootBr }
    if (Get-Command br -ErrorAction SilentlyContinue) { br @args }
}
# Auto-install de broot si no existe el launcher pero si el binario
$brootBr = "$HOME\AppData\Roaming\dystroy\broot\config\launcher\powershell\br.ps1"
if (-not (Test-Path $brootBr) -and (Get-Command broot -ErrorAction SilentlyContinue)) {
    broot --install 2>$null | Out-Null
}

#============================
# Datree completion: lazy (~7ms -> 0ms en startup)
#============================
$datreeCompletion = Join-Path (Split-Path -Parent $PROFILE) 'DatreeCompletion.ps1'
if (Test-Path $datreeCompletion) {
    function datree {
        Remove-Item function:datree
        try { . $datreeCompletion } catch { Write-Warning "Datree completion failed: $_" }
        & datree @args
    }
}

#============================
# PSFzf: DESHABILITADO por alto costo de startup (~330-390ms en Import-Module)
#
# Los handlers "nativos" con fzf directo no funcionan porque PSReadLine ScriptBlocks
# ejecutan en un contexto sin TTY accesible. fzf necesita control total del terminal
# (stdin interactivo, dibujo de UI) que solo PSFzf puede proporcionar via su propia
# gestion de pseudo-TTY.
#
# Para re-habilitar, descomenta el bloque de abajo. El modulo debe estar instalado:
#   Install-Module PSFzf -Scope CurrentUser
#
# Alternativas consideradas y descartadas:
#   - fzf directo en ScriptBlock: fzf se cuelga esperando stdin (no hay TTY)
#   - Start-Process fzf: no puede devolver el resultado al buffer de PSReadLine
#   - Out-GridView: solo Windows, no tiene preview de archivos, lento
#
# Original del backup (Microsoft.PowerShell_profile.ps1.backup.20260510-150538):
#============================
<#
# fzf fuzzy finder (module must be installed first)
# Install-Module PSFzf -Scope CurrentUser
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+T' `
                    -PSReadlineChordReverseHistory 'Ctrl+R' `
                    -EnableAliasFuzzyGitStatus
}
#>
