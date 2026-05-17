# Add user configurations here
# For HyDE to not touch your beloved configurations,
# we added a config file for you to customize HyDE

#  eza (sobrescribe los de HyDE) 
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias lla='eza -la --icons --group-directories-first'
alias lah='eza -lah --icons --group-directories-first'

#  Aliases personales 
alias op='opencode'
alias lgit='lazygit'
alias k='kubectl'
alias g='git'

#  Kubernetes 
set -gx KUBECONFIG ".kube/prod-k8s-clcreative-kubeconfig.yaml;.kube/civo-k8s_test_1-kubeconfig;.kube/k8s_test_1.yml"

function kn
    if test "$argv[1]" = "default" -o "$argv[1]" = "d"
        kubectl config set-context --current --namespace=default
    else
        kubectl config set-context --current --namespace=$argv[1]
    end
end

#  Zoxide 
if type -q zoxide
    zoxide init fish | source
end

#  connect (wezterm) 
function connect
    switch $argv[1]
        case jon
            wezterm connect jon
        case '*'
            echo "Unknown target: $argv[1]"
    end
end

#  EDITOR 
set EDITOR code

#  aurhelper 
set aurhelper paru
