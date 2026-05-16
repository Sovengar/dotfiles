#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing SoapUI..."
if _cmd_present SoapUI || _cmd_present soapui; then success "SoapUI already installed"; else aur_install soapui; success "SoapUI installed"; fi
