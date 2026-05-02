New-Alias g goto
New-Alias op opencode
New-Alias lgit lazygit
New-Alias lvim lazyvim

function goto {
    param ($location)

    Switch ($location) {
        "pr" { Set-Location -Path "$HOME/OneDrive/DEV/Projects" }
        default { echo "Invalid location" }
    }
}

# Configura EDITOR para que abra VS Code con --wait
$env:EDITOR = "code --wait"

#[[
#============================
#Starlship
#============================
##]]

$ENV:STARSHIP_CONFIG = "$HOME\.starship\starship.toml"
$ENV:STARSHIP_DISTRO = "者 xcad"
Invoke-Expression (&starship init powershell)

#[[
#============================
#Kubernetes
#============================
##]]
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

#============================
# Maven Wrapper mvnw
#============================
function mvnw {
    & ".\mvnw.cmd" $args
}

#[[
#============================
#WezTerm OSC 7 Shell Integration
#============================
##]]

$PromptOld = $function:prompt
function prompt {
    $loc = Get-Location
    if ($loc.Provider.Name -eq "FileSystem") {
        $uri = [System.Uri]::new($loc.Path).AbsoluteUri
        Write-Host -NoNewLine "`e]7;${uri}`e\"
    }
    & $PromptOld
}

#[[
#============================
#CLI Completions & Tools
#============================
##]]

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

# fzf fuzzy finder (module must be installed first)
# Install-Module PSFzf -Scope CurrentUser
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+T' `
                    -PSReadlineChordReverseHistory 'Ctrl+R' `
                    -EnableAliasFuzzyGitStatus
}

# Cargar completion de Datree
$datreeCompletion = Join-Path $PSScriptRoot 'DatreeCompletion.ps1'
if (Test-Path $datreeCompletion) { . $datreeCompletion }


# Cargar comandos tipo Linux
$linuxAliases = Join-Path $PSScriptRoot 'LinuxAliases.ps1'
if (Test-Path $linuxAliases) { . $linuxAliases }
