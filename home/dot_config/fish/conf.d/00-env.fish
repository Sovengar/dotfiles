#!/usr/bin/env fish

# Environment variables — XDG, tool settings, credentials.
# XDG Base Directory — https://specifications.freedesktop.org/basedir-spec/latest/

if test -z "$XDG_CONFIG_HOME"
    set -gx XDG_CONFIG_HOME "$HOME/.config"
end

if test -z "$XDG_DATA_HOME"
    set -gx XDG_DATA_HOME "$HOME/.local/share"
end

if test -z "$XDG_DATA_DIRS"
    set -gx XDG_DATA_DIRS "$XDG_DATA_HOME:/usr/local/share:/usr/share"
end

if test -z "$XDG_STATE_HOME"
    set -gx XDG_STATE_HOME "$HOME/.local/state"
end

if test -z "$XDG_CACHE_HOME"
    set -gx XDG_CACHE_HOME "$HOME/.cache"
end

if test -z "$XDG_DESKTOP_DIR"
    set -gx XDG_DESKTOP_DIR "$HOME/Desktop"
end

if test -z "$XDG_DOWNLOAD_DIR"
    set -gx XDG_DOWNLOAD_DIR "$HOME/Downloads"
end

if test -z "$XDG_TEMPLATES_DIR"
    set -gx XDG_TEMPLATES_DIR "$HOME/Templates"
end

if test -z "$XDG_PUBLICSHARE_DIR"
    set -gx XDG_PUBLICSHARE_DIR "$HOME/Public"
end

if test -z "$XDG_DOCUMENTS_DIR"
    set -gx XDG_DOCUMENTS_DIR "$HOME/Documents"
end

if test -z "$XDG_MUSIC_DIR"
    set -gx XDG_MUSIC_DIR "$HOME/Music"
end

if test -z "$XDG_PICTURES_DIR"
    set -gx XDG_PICTURES_DIR "$HOME/Pictures"
end

if test -z "$XDG_VIDEOS_DIR"
    set -gx XDG_VIDEOS_DIR "$HOME/Videos"
end

if test -z "$LESSHISTFILE"
    set -gx LESSHISTFILE "/tmp/less-hist"
end

if test -z "$PARALLEL_HOME"
    set -gx PARALLEL_HOME "$XDG_CONFIG_HOME/parallel"
end

# Kubernetes
set -gx KUBECONFIG ".kube/prod-k8s-clcreative-kubeconfig.yaml;.kube/civo-k8s_test_1-kubeconfig;.kube/k8s_test_1.yml"

# Starship
set -gx STARSHIP_CACHE $XDG_CACHE_HOME/starship
set -gx STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/starship.toml

# Man pages
set -gx MANROFFOPT "-c"
if test -x $HOME/.local/bin/manpager
    set -gx MANPAGER $HOME/.local/bin/manpager
end

# Machine-local secrets — do not commit.
set -gx OPENCODE_GO_WORKSPACE_ID "wrk_01KPRTA44GVQD63142WX91W7XK"
set -gx OPENCODE_GO_AUTH_COOKIE "Fe26.2**cb217838513dcff0eb516adb87ed820592b7007c7151039737d6c7c0b3a65986*goVwAFpWRlvktcDgs8pjgQ*crWCeTmLGGQ-wPhn-Ec9KytrInlVR2yVssmg4pUArCLDuNEmZY7-gREcTGfOZP1R2_pE5a7ZuDR0x8vPcuToKR9fqS1I4_i3SQmcCvsTVC0KwvXEv2yYnwYO8hGTqPxATRNQ6Lf6G05H51Ju117JzzaFryNi1OiQAnfOo32SPY74shVzYHHZeE9LzEml0GQK6ux7EL_BDP8qDLxHoLMJpnVln5rW5hNnSHoKKRvCWGM2QPrKukNrhz4fVTrZcGUc8tc1f9DorefmCgof2k-eXJTlYmmnirnAuPVnaZiLYndIBdwkdiIOLu70zf9rGFAZlJn7A3P8bQjCvFkJVzP37w*1810670822349*186ebc43da50e689ad2b8c2c93440913ce7691d56024018a554e37373f365289*37IZkmAmnqtqjHnGZwCig9r-CURO2mahhpieWnkujMo"
