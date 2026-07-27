---
name: dotfiles-package-installer
description: >
  Dotfiles package installation workflow: whenever installing, adding, or documenting a program,
  persist it in the chezmoi Linux setup scripts, ecosystem catalog, and relevant show-*-x command indexes.
  Trigger: when the user asks to install a program, run brew/apt/pacman/dnf/npm/cargo/go install,
  add a tool, add a dependency, or make a package available on future machines.
triggers: [install, instala, instalar, package, programa, dependency, dependencia, brew, apt, pacman, dnf, npm, cargo, go-install, linux-setup, ecosystem, show-dev-x]
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When To Use

- The user asks to install a program or CLI tool.
- The user gives an install command such as `brew install ...`, `npm install -g ...`, `cargo install ...`, `go install ...`, `apt install ...`, `pacman -S ...`, `dnf install ...`, or `paru -S ...`.
- A new dependency, package, runtime, app, TUI, diagnostic tool, or developer utility is added to the dotfiles setup.
- A tool needs to be available on future machines, not just installed once on the current host.

## Critical Rule

Installing locally is not enough. Every new program must be represented in the dotfiles bootstrap system unless the user explicitly says it is temporary.

Required updates:

| Target | Required? | Purpose |
|--------|-----------|---------|
| `~/.local/share/chezmoi/linux/setup/packaging/...` | Always | Reinstall the program on future Linux machines |
| `~/.local/share/chezmoi/docs/ecosystem.md` | Always | Keep the tool catalog complete |
| `show-dev-x`, `show-hw-x`, `show-funny-x`, or related `show-*-x` index | When useful | Make the command discoverable from local menus/indexes |

## Workflow

1. Load `tools-chezmoi` when the task touches dotfiles or chezmoi state.
2. Verify whether the user wants a one-off local install or persistent dotfiles installation when unclear.
3. Install the program using the requested package manager, with non-interactive flags when needed.
4. Add or update a script under `~/.local/share/chezmoi/linux/setup/packaging/<category>/`.
5. Add that script to the category `all.sh` with `run_logged "$_PHASE_DIR/<tool>.sh"`.
6. Add an entry to `~/.local/share/chezmoi/docs/ecosystem.md` under the appropriate category.
7. Add the command to a `show-*-x` index when the tool is user-facing or helpful for discovery.
8. Verify by reading the changed files or searching for the new command name.
9. Do not commit unless the user explicitly asks.

## Packaging Category Guide

| Tool Type | Directory | Ecosystem Section | Index |
|-----------|-----------|-------------------|-------|
| General CLI utilities | `core-tools/`, `dev-tools/`, `search-tools/`, `data-tools/`, `navigation-tools/` | `CLI Tools` | `show-dev-x` |
| Git/GitHub/VCS | `vcs-tools/` | `CLI Tools` or `Dev Tools` | `show-dev-x` |
| Terminal apps/TUIs | Matching category or `dev-tools/` | `Terminal & Shell` or `CLI Tools` | `show-dev-x` |
| Hardware diagnostics | `hardware/` | `Hardware & Diagnostics` | `show-hw-x` |
| Fun/visual terminal tools | `shell-plugins/` or suitable category | `Terminal & Shell` | `show-funny-x` |
| Media tools | `media/` | `Media & Entertainment` | Usually no index unless command-focused |
| Office/document tools | `office/` | `Office` | Usually no index unless command-focused |
| AI tools | `ia/` | `AI/ML` | `show-dev-x` if command-line |
| Containers/Kubernetes | `container-tools/` | `Docker/Infra` | `show-dev-x` |
| Databases/API clients | `database-tools/`, `api-tools/` | `Dev Tools` | `show-dev-x` if command-line |

## Script Patterns

Prefer the smallest script that matches the install source already used by the repo.

System package:

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

pkg_install tool-name
```

Homebrew tap or formula that may not exist in system repos:

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing tool-name..."

if _cmd_present tool-name; then
  success "tool-name already installed"
elif command -v brew &>/dev/null; then
  brew install owner/tap/tool-name
  success "tool-name installed"
else
  warn "brew not available, skipping tool-name"
fi
```

Global npm package:

```bash
#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
npm_global_install "package-name" command-name
```

## `ecosystem.md` Entry

Use the existing table style:

```markdown
| tool-name | Short purpose | install source |
```

Keep install source concrete: `system`, `AUR`, `brew`, `brew (tap: owner/tap)`, `npm`, `cargo`, `go install`, `manual`, `winget`, or `CachyOS repo`.

## `show-*-x` Decision

Add the tool to an index when a human would benefit from discovering the command later.

| Index | Add When |
|-------|----------|
| `home/dot_local/bin/executable_show-dev-x` | Developer commands, TUIs, runtimes, API/DB tools, Git tools, network CLI |
| `home/dot_local/bin/executable_show-hw-x` | Hardware, performance, system, disks, audio, GPU, network diagnostics |
| `home/dot_local/bin/executable_show-funny-x` | Visual/fun terminal commands, ASCII art, demos, color toys |
| Other `show-*-x` files | The tool fits the existing category better than the three above |

Entry format:

```bash
"Category|command|Short Spanish description."
```

Use Spanish for descriptions because the existing indexes are Spanish.

## Verification

Use targeted checks:

```bash
grep -n "tool-name" ~/.local/share/chezmoi/docs/ecosystem.md
grep -n "tool-name" ~/.local/share/chezmoi/linux/setup/packaging/<category>/all.sh
grep -n "tool-name" ~/.local/share/chezmoi/home/dot_local/bin/executable_show-* 2>/dev/null || true
```

Prefer `Read`, `Glob`, and `Grep` tools for file inspection. Use `apply_patch` for manual edits.

## Gotchas

- Do not use `git status` alone to decide chezmoi sync state; follow `tools-chezmoi` rules when source/target ownership matters.
- Do not modify unrelated dirty files in the dotfiles repo.
- Do not run full builds after these edits.
- Do not commit or push unless explicitly requested.
- Keep scripts idempotent: check command presence or use helpers such as `pkg_install`, `npm_global_install`, `go_install_latest`, `aur_install`, or `pip_install`.
