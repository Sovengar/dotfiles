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

#============================
#Starship
#============================
$ENV:STARSHIP_CONFIG = "$HOME\.starship\starship.toml"
$ENV:STARSHIP_DISTRO = "者 xcad"
Invoke-Expression (&starship init powershell)

#============================
#Kubernetes
#============================
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
