#!/usr/bin/env bash
set -euo pipefail

# Install git workflow tools: delta, git-absorb, git-machete, ec
# Run as normal user (sudo is used internally)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../helpers/all.sh"

guard_root
guard_internet
guard_arch

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   Git Workflow Tools — Installation      ║"
echo "  ╚════════════════════════════════════════════╝"
echo ""

# Remove diff-so-fancy (replaced by delta)
if command -v diff-so-fancy &>/dev/null; then
  log "Removing diff-so-fancy (replaced by delta)..."
  npm uninstall -g diff-so-fancy 2>/dev/null || true
  success "diff-so-fancy removed"
fi

# Phase 1: delta (pacman)
log "Phase 1/4: delta (git-delta)..."
if _cmd_present delta; then
  success "delta already installed ($(delta --version 2>/dev/null || echo 'present'))"
else
  pkg_install git-delta
  success "delta installed"
fi

# Phase 2: git-absorb (pacman)
log "Phase 2/4: git-absorb..."
if _cmd_present git-absorb; then
  success "git-absorb already installed"
else
  pkg_install git-absorb
  success "git-absorb installed"
fi

# Phase 3: git-machete (pip, not AUR — AUR tests fail with non-English locale)
log "Phase 3/4: git-machete..."
if _cmd_present git-machete; then
  success "git-machete already installed"
else
  _python="$(mise which python 2>/dev/null || true)"
  if [[ -n "$_python" && -x "$_python" ]]; then
    "$_python" -m pip install --quiet git-machete
    success "git-machete installed via pip"
  else
    err "mise python not found, cannot install git-machete"
    exit 1
  fi
fi

# Phase 4: ec / easy-conflict (AUR)
log "Phase 4/4: ec (easy-conflict)..."
if _cmd_present ec; then
  success "ec already installed"
else
  aur_install easy-conflict-bin
  success "ec installed"
fi

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   Verification                           ║"
echo "  ╚════════════════════════════════════════════╝"
echo ""

fail=0
for cmd in delta git-absorb git-machete ec; do
  if _cmd_present "$cmd"; then
    success "$cmd ✓"
  else
    err "$cmd ✗ (not found in PATH)"
    fail=$((fail + 1))
  fi
done

echo ""
if [[ $fail -eq 0 ]]; then
  success "All git workflow tools installed successfully."
  echo ""
  echo "  Next: Apply git config and lazygit config from"
  echo "  docs/git-workflow-implementation.md (Phase 1-4)"
else
  err "$fail tool(s) failed to install."
  exit 1
fi