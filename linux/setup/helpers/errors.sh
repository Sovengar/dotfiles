# Error handling — traps, run_logged

if [[ -z "${_ERRORS_LOADED:-}" ]]; then
_ERRORS_LOADED=1

_ERROR_SCRIPT=""
_ERROR_LINE=0

_error_trap() {
  _ERROR_LINE=$1
  _ERROR_SCRIPT="${2:-unknown}"
  err "Error in ${_ERROR_SCRIPT} at line ${_ERROR_LINE}"
  err "Check the log above for details. Run the failing script manually to debug."
}

run_logged() {
  local script="$1"
  local name
  name="$(basename "$script")"

  log "Running ${name}..."

  # Source the script in current shell so helpers are available
  # but trap errors with context
  local old_trap
  old_trap="$(trap -p ERR 2>/dev/null || true)"

  trap '_error_trap $LINENO "'"$name"'"' ERR
  source "$script"
  # shellcheck disable=SC2064
  trap "${old_trap#trap -- }" ERR 2>/dev/null || trap - ERR

  success "${name} done"
}

fi
