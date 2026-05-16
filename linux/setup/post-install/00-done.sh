#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

echo ""
echo -e "${C_GREEN}${C_BOLD}╔══════════════════════════════════════════╗${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}║${C_RESET}              ${C_BOLD}All done!${C_RESET}                  ${C_GREEN}${C_BOLD}║${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}╚══════════════════════════════════════════╝${C_RESET}"
echo ""

echo "Next steps:"
echo "  1. Log out and back in (Ctrl+D → login) for:"
echo "     - Docker group membership"
echo "     - Default shell (fish) to take effect"
echo ""
echo "  2. After login, authenticate cloud storage:"
echo "     - dropbox start -i"
echo "     - rclone gdrive: and onedrive: are configured"
echo "       (first mount triggers OAuth in browser)"
echo ""
echo "  3. Your dotfiles are applied via chezmoi."
echo "     To update later: chezmoi update"
echo ""

success "Bootstrap complete"
