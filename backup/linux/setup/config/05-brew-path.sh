#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Adding brew to shell PATHs..."

BREW_BIN="/home/linuxbrew/.linuxbrew/bin"
BREW_SHELLENV="eval \"\$($BREW_BIN/brew shellenv)\""

# ── zsh ────────────────────────────────────────────────────────

if _cmd_present zsh; then
  ZSHRC="$HOME/.zshrc"
  if [[ -f "$ZSHRC" ]] && grep -q "brew shellenv" "$ZSHRC" 2>/dev/null; then
    log "brew already in $ZSHRC"
  else
    echo "" >> "$ZSHRC"
    echo "# Linuxbrew" >> "$ZSHRC"
    echo "$BREW_SHELLENV" >> "$ZSHRC"
    success "Added brew shellenv to $ZSHRC"
  fi
fi

# ── fish ───────────────────────────────────────────────────────

if _cmd_present fish; then
  FISH_CONFIG="$HOME/.config/fish/config.fish"
  mkdir -p "$(dirname "$FISH_CONFIG")"

  if [[ -f "$FISH_CONFIG" ]] && grep -q "$BREW_BIN" "$FISH_CONFIG" 2>/dev/null; then
    log "brew already in fish PATH"
  else
    echo "" >> "$FISH_CONFIG"
    echo "# Linuxbrew PATH" >> "$FISH_CONFIG"
    echo "fish_add_path $BREW_BIN" >> "$FISH_CONFIG"
    success "Added brew to fish PATH"
  fi
fi

success "Brew PATH configured for all shells"
