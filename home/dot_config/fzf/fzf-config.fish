# fzf customization (sourced by fish)
set -gx FZF_DEFAULT_COMMAND "fd --hidden --follow --exclude .git --exclude node_modules --exclude .cache --exclude .venv"
set -gx FZF_CTRL_T_COMMAND "fd --hidden --follow --exclude .git --exclude node_modules --exclude .cache --exclude .venv --type f"
set -gx FZF_ALT_C_COMMAND "fd --hidden --follow --exclude .git --exclude node_modules --exclude .cache --exclude .venv --type d"
set -gx FZF_DEFAULT_OPTS "\
  --layout=reverse \
  --height=80% \
  --info=inline \
  --cycle \
  --border \
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
  --color=selected-bg:#45475a \
  --bind=ctrl-u:page-up,ctrl-d:page-down,ctrl-space:toggle-preview"
set -gx FZF_CTRL_T_OPTS "--preview='bat --color=always --style=numbers {}' --preview-window=right:60%"
set -gx FZF_ALT_C_OPTS "--preview='eza --icons --tree --level=2 {}' --preview-window=right:60%"
set -gx FZF_CTRL_R_OPTS "--preview='echo {}' --preview-window=down:3:hidden:wrap --bind=ctrl-/:toggle-preview"
