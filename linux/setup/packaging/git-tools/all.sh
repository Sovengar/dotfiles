# Git and VCS tools all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/git.sh"
run_logged "$_PHASE_DIR/git-lfs.sh"
run_logged "$_PHASE_DIR/git-worktree.sh"
run_logged "$_PHASE_DIR/gh.sh"
run_logged "$_PHASE_DIR/lazygit.sh"
run_logged "$_PHASE_DIR/jj.sh"
