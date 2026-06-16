#!/usr/bin/env zsh

# All environment variables, organized by domain.
# Shell environment shared by Hyprland tools and interactive zsh sessions.

# XDG Base Directory
PATH="$HOME/.local/bin:$PATH"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_DATA_DIRS="${XDG_DATA_DIRS:-$XDG_DATA_HOME:/usr/local/share:/usr/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

if command -v xdg-user-dir >/dev/null 2>&1; then
  XDG_DESKTOP_DIR="${XDG_DESKTOP_DIR:-$(xdg-user-dir DESKTOP)}"
  XDG_DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$(xdg-user-dir DOWNLOAD)}"
  XDG_TEMPLATES_DIR="${XDG_TEMPLATES_DIR:-$(xdg-user-dir TEMPLATES)}"
  XDG_PUBLICSHARE_DIR="${XDG_PUBLICSHARE_DIR:-$(xdg-user-dir PUBLICSHARE)}"
  XDG_DOCUMENTS_DIR="${XDG_DOCUMENTS_DIR:-$(xdg-user-dir DOCUMENTS)}"
  XDG_MUSIC_DIR="${XDG_MUSIC_DIR:-$(xdg-user-dir MUSIC)}"
  XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$(xdg-user-dir PICTURES)}"
  XDG_VIDEOS_DIR="${XDG_VIDEOS_DIR:-$(xdg-user-dir VIDEOS)}"
fi

LESSHISTFILE="${LESSHISTFILE:-/tmp/less-hist}"
PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
SCREENRC="$XDG_CONFIG_HOME/screen/screenrc"
TERMINFO="$XDG_DATA_HOME"/terminfo
TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo
WGETRC="${XDG_CONFIG_HOME}/wgetrc"
PYTHON_HISTORY="$XDG_STATE_HOME/python_history"

export PATH \
  XDG_CONFIG_HOME XDG_DATA_HOME XDG_DATA_DIRS XDG_STATE_HOME XDG_CACHE_HOME \
  XDG_DESKTOP_DIR XDG_DOWNLOAD_DIR XDG_TEMPLATES_DIR XDG_PUBLICSHARE_DIR \
  XDG_DOCUMENTS_DIR XDG_MUSIC_DIR XDG_PICTURES_DIR XDG_VIDEOS_DIR \
  LESSHISTFILE PARALLEL_HOME SCREENRC TERMINFO TERMINFO_DIRS WGETRC PYTHON_HISTORY

# History
HISTFILE="${HISTFILE:-$ZDOTDIR/.zsh_history}"
HISTSIZE=${HISTSIZE:-10000}
SAVEHIST=${SAVEHIST:-10000}
export HISTFILE HISTSIZE SAVEHIST

# Starship
export STARSHIP_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/starship"
export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"

# Man pages
export MANROFFOPT='-c'
if [[ -x "$HOME/.local/bin/manpager" ]]; then
  export MANPAGER="$HOME/.local/bin/manpager"
fi

# Kubernetes
export KUBECONFIG='.kube/prod-k8s-clcreative-kubeconfig.yaml;.kube/civo-k8s_test_1-kubeconfig;.kube/k8s_test_1.yml'

# Machine-local secrets — do not commit.
export OPENCODE_GO_WORKSPACE_ID="wrk_01KPRTA44GVQD63142WX91W7XK"
export OPENCODE_GO_AUTH_COOKIE="Fe26.2**cb217838513dcff0eb516adb87ed820592b7007c7151039737d6c7c0b3a65986*goVwAFpWRlvktcDgs8pjgQ*crWCeTmLGGQ-wPhn-Ec9KytrInlVR2yVssmg4pUArCLDuNEmZY7-gREcTGfOZP1R2_pE5a7ZuDR0x8vPcuToKR9fqS1I4_i3SQmcCvsTVC0KwvXEv2yYnwYO8hGTqPxATRNQ6Lf6G05H51Ju117JzzaFryNi1OiQAnfOo32SPY74shVzYHHZeE9LzEml0GQK6ux7EL_BDP8qDLxHoLMJpnVln5rW5hNnSHoKKRvCWGM2QPrKukNrhz4fVTrZcGUc8tc1f9DorefmCgof2k-eXJTlYmmnirnAuPVnaZiLYndIBdwkdiIOLu70zf9rGFAZlJn7A3P8bQjCvFkJVzP37w*1810670822349*186ebc43da50e689ad2b8c2c93440913ce7691d56024018a554e37373f365289*37IZkmAmnqtqjHnGZwCig9r-CURO2mahhpieWnkujMo"
