# Display — banner, phase orchestration

if [[ -z "${_DISPLAY_LOADED:-}" ]]; then
_DISPLAY_LOADED=1

_display_banner_shown=false

display_banner() {
  if [[ "$_display_banner_shown" == true ]]; then return; fi
  _display_banner_shown=true

  echo ""
  echo -e "${C_CYAN}${C_BOLD}╔══════════════════════════════════════════╗${C_RESET}"
  echo -e "${C_CYAN}${C_BOLD}║${C_RESET}         ${C_BOLD}Dotfiles Linux Bootstrap${C_RESET}          ${C_CYAN}${C_BOLD}║${C_RESET}"
  echo -e "${C_CYAN}${C_BOLD}╚══════════════════════════════════════════╝${C_RESET}"
  echo ""
}

_phase_heading() {
  local phase="$1"
  local label="$2"
  echo ""
  echo -e "${C_BLUE}${C_BOLD}── ${label} ──${C_RESET}"
  echo ""
}

run_phase() {
  local phase_dir="$1"
  local phase_name
  phase_name="$(basename "$phase_dir")"

  _phase_heading "$phase_name" "${phase_name^}"

  if [[ ! -f "$phase_dir/all.sh" ]]; then
    warn "No all.sh found in $phase_dir — skipping"
    return
  fi

  source "$phase_dir/all.sh"
}

print_phase_summary() {
  local label="${1:-Phase}"

  if [[ $_RUN_TOTAL -eq 0 ]]; then
    return
  fi

  echo ""
  echo -e "${C_BLUE}${C_BOLD}══════════════════════════════════════════${C_RESET}"
  echo -e "${C_BOLD}  ${label} complete${C_RESET}"
  local succeeded=$((_RUN_TOTAL - _RUN_FAILED))
  echo -e "  ${C_GREEN}${succeeded} succeeded${C_RESET}, ${C_RED}${_RUN_FAILED} failed${C_RESET} (${_RUN_TOTAL} total)"
  echo -e "${C_BLUE}${C_BOLD}══════════════════════════════════════════${C_RESET}"
  echo ""
}

fi
