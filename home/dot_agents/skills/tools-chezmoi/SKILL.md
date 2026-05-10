---
name: tools-chezmoi
description: >
  Chezmoi dotfiles management — sync check, diff, status, apply workflow.
  Trigger: When user asks about chezmoi, dotfiles, sync status, "está sincronizado", "sube los cambios", or dotfiles repo management.
triggers: [chezmoi, dotfiles, sincronizado, sync, dotfiles-repo, config-management]
---

## ⚠️ CRITICAL: git status ≠ chezmoi diff

**`git status` solo mira el repo source**. Puede decir "clean" mientras hay cambios sin commitear en casa (modificaciones locales tras `chezmoi apply`). 
**`chezmoi diff` siempre primero** — compara source vs target real.

## Sync Check Workflow

When asked "are dotfiles in sync?", run ALL of these:

```powershell
# 1. SIEMPRE PRIMERO: chezmoi diff (source vs target real)
chezmoi diff
chezmoi status

# 2. Luego git (source repo vs remote)
git status
git --no-pager diff
git --no-pager log --oneline -3
```

## Common Commands

| Command | Purpose |
|---------|---------|
| `chezmoi status` | Show pending changes (source vs target) |
| `chezmoi diff` | Show full diff of pending changes |
| `chezmoi apply` | Apply source changes to target |
| `chezmoi update` | Pull from git + apply |
| `chezmoi add <path>` | Add a file to chezmoi management |
| `chezmoi git add .` | Stage chezmoi source changes for commit |
| `chezmoi cd` | Jump to chezmoi source directory |
| `chezmoi execute-template "{{ toJson . }}"` | Debug template data |
| `chezmoi unmanaged` | List unmanaged files in target |
| `chezmoi re-add <path>` | Re-add a file (merge target changes back to source) |

> **⚠️ `chezmoi re-add` siempre con ruta absoluta.** Rutas relativas tipo `.config/foo` pueden fallar con falsos `not managed`. Usa el path completo del target, e.g. `chezmoi re-add "C:\Users\buble\.config\wezterm\appearance.lua"`.

## Workflow: Edit + Commit + Apply

```powershell
# Edit source files directly in chezmoi dir
chezmoi cd

# After editing, check diff
chezmoi diff

# Apply to target
chezmoi apply

# Commit source changes
chezmoi cd
git add .
git commit -m "message"
git push
```

## After Pushing: Update Other Machines

After pushing to origin, suggest running on other machines:

```powershell
# Pull + apply (full sync)
chezmoi update

# Pull only, don't apply (review changes first)
chezmoi update --apply=false
# then review with chezmoi status + chezmoi diff
# then apply manually with chezmoi apply
```

## Architecture

- Source: `~/.local/share/chezmoi/` (git repo)
- Target: `~` (home directory)
- Data files: `home/.chezmoidata/*.yaml` → accessible via `{{ .data.key }}`
- Scripts: `home/.chezmoiscripts/*.ps1` → `chezmoi apply` runs `run_onchange_*` on change, `run_once_*` once only
- Config mapped from `home/` prefix in source to `$HOME/` on target

## Key Conventions

- `.chezmoiscripts/run_onchange_after_*.ps1` — runs on target after file changes detected
- `.chezmoidata/packages.yaml` — winget/manual package definitions
- Always run `chezmoi status` + `chezmoi diff` before assuming sync state
