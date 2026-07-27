#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Setting OpenCode Go quota env vars..."

if ! _cmd_present sops; then
  err "sops not found — cannot decrypt opencode-quota secrets"
  return
fi

CHEZMOI_SOURCE="${CHEZMOI_SOURCE:-$HOME/.local/share/chezmoi}"
SOPS_FILE="$CHEZMOI_SOURCE/secrets/opencode-quota.sops.yaml"

if [[ ! -f "$SOPS_FILE" ]]; then
  err "opencode-quota secrets not found at $SOPS_FILE"
  return
fi

WORKSPACE_ID=$(sops -d --extract '["opencode_go_workspace_id"]' "$SOPS_FILE" 2>/dev/null)
AUTH_COOKIE=$(sops -d --extract '["opencode_go_auth_cookie"]' "$SOPS_FILE" 2>/dev/null)

if [[ -z "$WORKSPACE_ID" || -z "$AUTH_COOKIE" ]]; then
  err "Failed to decrypt opencode-quota secrets"
  return
fi

# ── fish ────────────────────────────────────────────────────────

if _cmd_present fish; then
  FISH_CONFIG="$HOME/.config/fish/config.fish"
  mkdir -p "$(dirname "$FISH_CONFIG")"

  if [[ -f "$FISH_CONFIG" ]] && grep -q "OPENCODE_GO_WORKSPACE_ID" "$FISH_CONFIG" 2>/dev/null; then
    log "opencode-go vars already in fish config"
  else
    cat >> "$FISH_CONFIG" << EOF

# OpenCode Go quota (opencode-quota plugin)
set -gx OPENCODE_GO_WORKSPACE_ID "$WORKSPACE_ID"
set -gx OPENCODE_GO_AUTH_COOKIE "$AUTH_COOKIE"
EOF
    success "Opencode Go quota vars added to fish config"
  fi
fi

# ── zsh ─────────────────────────────────────────────────────────

if _cmd_present zsh; then
  ZSHRC="$HOME/.zshrc"
  if [[ -f "$ZSHRC" ]] && grep -q "OPENCODE_GO_WORKSPACE_ID" "$ZSHRC" 2>/dev/null; then
    log "opencode-go vars already in $ZSHRC"
  else
    cat >> "$ZSHRC" << EOF

# OpenCode Go quota (opencode-quota plugin)
export OPENCODE_GO_WORKSPACE_ID="$WORKSPACE_ID"
export OPENCODE_GO_AUTH_COOKIE="$AUTH_COOKIE"
EOF
    success "Opencode Go quota vars added to $ZSHRC"
  fi
fi

# ── bash (just in case) ─────────────────────────────────────────

if _cmd_present bash; then
  BASHRC="$HOME/.bashrc"
  if [[ -f "$BASHRC" ]] && grep -q "OPENCODE_GO_WORKSPACE_ID" "$BASHRC" 2>/dev/null; then
    log "opencode-go vars already in $BASHRC"
  else
    cat >> "$BASHRC" << EOF

# OpenCode Go quota (opencode-quota plugin)
export OPENCODE_GO_WORKSPACE_ID="$WORKSPACE_ID"
export OPENCODE_GO_AUTH_COOKIE="$AUTH_COOKIE"
EOF
    success "Opencode Go quota vars added to $BASHRC"
  fi
fi

success "OpenCode Go quota env vars configured for all shells"
