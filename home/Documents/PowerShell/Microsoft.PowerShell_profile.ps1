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

# cdx - CD Vitaminado (zoxide jump + ripgrep+fzf search)
$cdxScript = Join-Path $PSScriptRoot 'Cdx.ps1'
if (Test-Path $cdxScript) { . $cdxScript }

# cdx2 - CD Interactivo (fzf directory browser)
$cdx2Script = Join-Path $PSScriptRoot 'Cdx2.ps1'
if (Test-Path $cdx2Script) { . $cdx2Script }

# cdx3 - CD Interactivo v3 (fd + lazy zoxide)
$cdx3Script = Join-Path $PSScriptRoot 'Cdx3.ps1'
if (Test-Path $cdx3Script) { . $cdx3Script }

#[[
#============================
#CLI Completions & Tools
#============================
##]]

#[[
#============================
# Others
#============================
##]]

# mise-en-place
if (Get-Command mise -ErrorAction SilentlyContinue) {
    (&mise activate pwsh) | Out-String | Invoke-Expression
}