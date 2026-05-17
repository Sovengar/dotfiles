# Error handling — traps, run_logged

if [[ -z "${_ERRORS_LOADED:-}" ]]; then
_ERRORS_LOADED=1

_ERROR_SCRIPT=""
_ERROR_LINE=0

_RUN_TOTAL=0
_RUN_FAILED=0

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
  local exit_code=0

  log "Running ${name}..."

  local old_trap
  old_trap="$(trap -p ERR 2>/dev/null || true)"

  trap '_error_trap $LINENO "'"$name"'"' ERR
  source "$script" || exit_code=$?
  trap "${old_trap#trap -- }" ERR 2>/dev/null || trap - ERR

  _RUN_TOTAL=$((_RUN_TOTAL + 1))

  if [[ $exit_code -eq 0 ]]; then
    success "${name} done"
  else
    _RUN_FAILED=$((_RUN_FAILED + 1))
    if [[ -t 0 ]] && [[ "${CI:-}" != "true" ]]; then
      warn "Continue despite failure? [Y/n] "
      read -r _continue || true
      if [[ "${_continue:-y}" =~ ^[Nn] ]]; then
        err "Aborted by user"
        exit 1
      fi
    fi
  fi

  return 0
}

reset_run_stats() {
  _RUN_TOTAL=0
  _RUN_FAILED=0
}

fi
