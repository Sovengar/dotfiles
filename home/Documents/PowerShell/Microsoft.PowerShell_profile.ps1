New-Alias op opencode
New-Alias lgit lazygit
New-Alias vim nvim

# Configura EDITOR para que abra VS Code: con --wait
$env:EDITOR = "nvim"

#Starlship
$ENV:STARSHIP_CONFIG = "$HOME\.starship\starship.toml"
$ENV:STARSHIP_DISTRO = "者 xcad"
Invoke-Expression (&starship init powershell)

#Kubernetes
New-Alias k kubectl

$ENV:KUBECONFIG = ".kube/prod-k8s-clcreative-kubeconfig.yaml;.kube/civo-k8s_test_1-kubeconfig;.kube/k8s_test_1.yml"

function kn {
    param (
        $namespace
    )

    if ($namespace -in "default","d") {
        kubectl config set-context --current --namespace=default
    } else {
        kubectl config set-context --current --namespace=$namespace
    }
}

# Maven Wrapper mvnw
function mvnw {
    & ".\mvnw.cmd" $args
}

#WezTerm OSC 7 Shell Integration
$PromptOld = $function:prompt
function prompt {
    $loc = Get-Location
    if ($loc.Provider.Name -eq "FileSystem") {
        $uri = [System.Uri]::new($loc.Path).AbsoluteUri
        Write-Host -NoNewLine "`e]7;${uri}`e\"
    }
    & $PromptOld
}

# Cargar comandos tipo Linux
$linuxAliases = Join-Path $PSScriptRoot 'LinuxAliases.ps1'
if (Test-Path $linuxAliases) { . $linuxAliases }

#[[
#============================
#CLI Completions & Tools
#============================
##]]

# PSReadLine: Tab acepta predicción, si no hay hace Tab normal
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

# kubectl completion (for 'k' alias already defined above)
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    kubectl completion powershell | Out-String | Invoke-Expression
}

# GitHub CLI completion
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Invoke-Expression -Command $(gh completion -s powershell | Out-String)
}

# Docker completion (module must be installed first)
# Install-Module DockerCompletion -Scope CurrentUser
if (Get-Module -ListAvailable -Name DockerCompletion) {
    Import-Module DockerCompletion
}

# Zoxide (smart cd, learns your most-used directories)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# cdx - CD Interactivo Unificado
# Jump:    cdx <name>       → cd directo → zoxide → TUI con query
# Browse:  cdx              → TUI fd/rg (Ctrl+R toggle)
# Search:  cdx -g <query>   → ripgrep búsqueda de contenido
$cdxScript = Join-Path $PSScriptRoot 'Cdx.ps1'
if (Test-Path $cdxScript) { . $cdxScript }

# fzf fuzzy finder (module must be installed first)
# Install-Module PSFzf -Scope CurrentUser
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+T' `
                    -PSReadlineChordReverseHistory 'Ctrl+R' `
                    -EnableAliasFuzzyGitStatus
}

# rgx — fzf + ripgrep content search (rg vitaminado)
$fzfRgScript = Join-Path $PSScriptRoot 'FzfRg.ps1'
if (Test-Path $fzfRgScript) { . $fzfRgScript }

# Cargar completion de Datree
$datreeCompletion = Join-Path $PSScriptRoot 'DatreeCompletion.ps1'
if (Test-Path $datreeCompletion) { . $datreeCompletion }

#[[
#============================
# Others
#============================
##]]

# mise-en-place
if (Get-Command mise -ErrorAction SilentlyContinue) {
    (&mise activate pwsh) | Out-String | Invoke-Expression
}
. "$HOME\AppData\Roaming\dystroy\broot\config\launcher\powershell\br.ps1"
