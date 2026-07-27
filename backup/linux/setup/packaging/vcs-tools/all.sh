# VCS and dotfiles tools all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/git.sh"
run_logged "$_PHASE_DIR/git-flow.sh"
run_logged "$_PHASE_DIR/chezmoi.sh"
run_logged "$_PHASE_DIR/git-lfs.sh"
run_logged "$_PHASE_DIR/git-worktree.sh"
run_logged "$_PHASE_DIR/gh.sh"
run_logged "$_PHASE_DIR/lazygit.sh"
run_logged "$_PHASE_DIR/jj.sh"
run_logged "$_PHASE_DIR/gh-dash.sh"
run_logged "$_PHASE_DIR/worktrunk.sh"
run_logged "$_PHASE_DIR/delta.sh"
run_logged "$_PHASE_DIR/git-absorb.sh"
run_logged "$_PHASE_DIR/git-machete.sh"
run_logged "$_PHASE_DIR/ec.sh"
run_logged "$_PHASE_DIR/git-wip.sh"
run_logged "$_PHASE_DIR/hunkdiff.sh"
