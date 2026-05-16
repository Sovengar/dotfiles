# Logging helpers — colored output, timestamps

if [[ -z "${_LOGGING_LOADED:-}" ]]; then
_LOGGING_LOADED=1

# Colors
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_CYAN='\033[0;36m'
C_BOLD='\033[1m'

_TIMESTAMP() { date '+%H:%M:%S'; }

log()     { echo -e "${C_BOLD}[$(_TIMESTAMP)]${C_RESET} ${C_CYAN}→${C_RESET} $*"; }
success() { echo -e "${C_BOLD}[$(_TIMESTAMP)]${C_RESET} ${C_GREEN}✓${C_RESET} $*"; }
warn()    { echo -e "${C_BOLD}[$(_TIMESTAMP)]${C_RESET} ${C_YELLOW}⚠${C_RESET} $*" >&2; }
err()     { echo -e "${C_BOLD}[$(_TIMESTAMP)]${C_RESET} ${C_RED}✗${C_RESET} $*" >&2; }

fi
