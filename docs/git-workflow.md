# Git Workflow Tools

> Herramientas y flujo de trabajo git. Para configuración e instalación por fases, ver `git-workflow-implementation.md`.

## Installed Tools

| Tool | Purpose | Install |
|------|---------|---------|
| lazygit | TUI git | brew/curl |
| jj | Git-compat VCS | brew/curl |
| worktrunk | Git worktree manager (`wt`) | system |
| delta | Syntax-highlighted pager | pacman |
| git-absorb | Auto fixup commits | pacman |
| git-machete | Branch hierarchy manager | AUR |
| ec | 3-pane conflict resolver | AUR |
| diffview.nvim | Neovim diff & history viewer | lazy.nvim |
| hunkdiff (hunk) | TUI diff viewer with AI/agent annotations | npm |

## Tool Ecosystem

Valor de cada herramienta en el contexto del flujo actual, y cómo se relacionan entre sí.

### delta — Syntax-Highlighted Pager

Reemplaza diff-so-fancy. Aporta syntax highlighting lenguaje-aware (no solo colores ANSI), side-by-side view en dos columnas, line numbers en diffs, navegación `n`/`N` entre hunks y blame annotations integradas. Es el pilar visual del flujo — lazygit lo usa para colorear diffs y `g d` lo usa en terminal.

Se complementa con **hunkdiff** (interactivo TUI con AI) y **diffview.nvim** (análisis profundos en Neovim).

### zdiff3 — Conflict Style Mejorado

Controla cómo se representan los conflictos de merge en los marcadores. Añade una tercera sección `||||||| merge base` que muestra el código original antes de que cada lado lo modificara. Sin zdiff3 solo ves HEAD vs branch y debes inferir qué cambió cada quién. Con zdiff3 ves HEAD, base y branch — sabes exactamente qué introdujo cada lado.

**Relación con otras herramientas**:
- **rerere** (ya activo): resuelve conflictos que ya viste; zdiff3 te da contexto para conflictos **nuevos** que rerere no ha visto.
- **ec**: parsea los 3 lados del conflicto que zdiff3 expone en los marcadores y los muestra en paneles separados.

### ec (Easy Conflict) — 3-Pane Conflict Resolver

TUI que muestra HEAD, base y branch en 3 paneles para resolver conflictos visualmente (similar a IntelliJ). Sirve para conflictos que rerere no pudo resolver y que son demasiado complejos para resolver inline en lazygit. Seleccionas qué versión mantener por sección, editas si hace falta, y guardas.

**Escalón de resolución de conflictos**:
1. `g syncº` → conflicto
2. Si es simple (1 sección, clara) → resuelves inline en lazygit (marcadores zdiff3)
3. Si es moderado (varias secciones) → `ec` (TUI 3-pane)
4. Si es complejo (requiere reestructurar lógica) → code (editor completo)

ec se sitúa en el escalón medio — más visual que marcadores de texto, menos pesado que abrir el editor.

### git-absorb — Auto Fixup Commits

Examina cambios sin commitear, identifica automáticamente a qué commit anterior pertenece cada línea, y crea `fixup!` commits individuales. Luego `rebase -i --autosquash` (vía `g polish`) los fusiona en los commits originales.

**Comparado con lo que ya tienes**:
- `g amend`: agrega cambios al último commit. Sirve cuando el cambio pertenece a HEAD.
- `git commit --fixup <hash>`: crea fixup para un commit específico. Requiere identificar manualmente el hash.
- `git absorb`: encuentra los commits automáticamente. Sirve cuando los cambios están repartidos entre varios commits anteriores.

**Flujo**: haces cambios → `g absorb` (crea fixups automáticos) → `g polish` (rebase -i con autosquash). Sin absorb tenías que buscar cada hash manualmente.

### git-machete — Branch Hierarchy Manager

Rastrea la jerarquía entre ramas (qué rama está basada en cuál) y permite operar sobre la cadena completa: rebasear todo en orden secuencial, eliminar ramas mergeadas, visualizar el árbol.

**Aporta valor cuando mantienes 3+ ramas en cadena (stacked branches)**:
```
main → feat/base → feat/sub → feat/sub-sub
```
Sin machete: `g syncº` rama por rama manualmente desde la hoja hasta la base.
Con machete: `git machete traverse` — rebasea toda la cadena en la secuencia correcta.

**Relación con worktrunk**: no compiten. worktrunk gestiona worktrees en **paralelo** (múltiples workspaces); machete gestiona ramas en **cadena** (jerarquía). Resuelven problemas distintos, se complementan si haces stacked PRs.

Para 1-2 ramas paralelas, `g syncº` es suficiente. Para cadenas de features complejos, machete añade automatización.

### diffview.nvim — Neovim Diff & History Viewer

Plugin de Neovim con side-by-side diff de rangos de commits (`:DiffviewOpen HEAD~3..HEAD`), file history panel (`:DiffviewFileHistory %`), y comparación de ramas completas. Sirve para análisis profundos donde terminal/lazygit se quedan cortos.

**Flujo**: lazygit para navegación general → `e` abre archivo en Neovim → `:DiffviewFileHistory %` para historial completo del archivo.

**Relación con delta y hunkdiff**: mismo problema (visualizar cambios), distinta profundidad y enfoque. delta es para diffs rápidos y lectura; hunkdiff es interactivo con anotaciones AI; diffview es análisis profundo con edición.

### git-wip — (Evaluación)

Herramienta externa que guarda snapshots automáticos en referencias separadas (`refs/wip`), con historial de múltiples WIPs y auto-save via hooks.

**Lo que ya tienes**: `gwip`/`gunwip` en fish que hacen WIP commits en la rama actual con `--wip-- [skip ci]`. `rebase.autostash=true` cubre el stash automático antes de rebase.

**Diferencia clave**: gwip aguanta 1 snapshot (el último), se ve en `git log`, es manual. git-wip aguanta N snapshots, solo se ve en reflog, es automático via hooks.

Para la mayoría de los casos, `gwip` + `autostash` es suficiente. Considerar git-wip solo si las sesiones largas con múltiples puntos de guardado son frecuentes.

### hunkdiff (hunk) — TUI Diff Viewer con AI/Agent Annotations

Terminal diff viewer construido sobre OpenTUI. Proporciona una interfaz interactiva multi-archivo para revisar changesets completos, con sidebar de navegación, modo split/stack responsivo, y anotaciones inline de agentes/AI.

**Modos de uso**:
- `hunk diff` — revisar working tree (incluye untracked files por defecto)
- `hunk show [ref]` — revisar commits (HEAD, HEAD~N, o cualquier ref)
- `hunk diff before.ts after.ts` — comparar dos archivos directamente
- `hunk patch -` — revisar un patch desde stdin (`git diff --no-color | hunk patch -`)
- `hunk pager` — modo pager, configurable como `core.pager` de git
- `--watch` — auto-reload al cambiar los archivos

**Integración con AI/Agentes**:
- `hunk skill path` — devuelve ruta del skill file para cargar en el agente
- Agente puede inspeccionar sesión viva: listar archivos/hunks, navegar, añadir comentarios inline
- Sesión compartida: agente y humano ven el mismo diff sincronizado
- Comentarios AI/agent aparecen como anotaciones inline en la TUI

**Relación con otras herramientas**:
- **delta**: diff rápido en terminal (lectura). hunkdiff es diff interactivo multi-archivo con navegación y anotaciones. No compiten — delta para glances rápidos, hunk para revisiones profundas.
- **diffview.nvim**: análisis en Neovim con edición. hunkdiff es terminal, más ligero, con foco en review de AI agents.
- **lazygit**: gestión general de git. hunkdiff se usa para la revisión profunda del diff cuando lazygit se queda corto.

**Valor en el flujo**: hunkdiff cierra el gap entre delta (rápido, lectura) y diffview.nvim (profundo, editor). Añade una capa interactiva media con el bonus único de integración con agentes AI.

### weave — (Nota conceptual)

Weave merge **no está disponible en git**. Es un concepto de algoritmo de merge (usado en BitKeeper, predecesor de git). git 2.54 usa `ort` como algoritmo por defecto, que maneja renames y conflictos mejor que el antiguo `recursive`. Si el objetivo es reducir conflictos falsos, la combinación **zdiff3 + rerere + ec** cubre ese terreno sin necesitar weave.

---

## Context-Aware Workflow

### Capas del ecosistema

Las herramientas se organizan en capas complementarias — no son reemplazos entre sí:

| Capa | Terminal | Lazygit | Neovim |
|------|----------|---------|---------|
| Navegación | `g swº`, `g syncº`, `g h` | lazygit (paneles) | :Telescope |
| Visualización | `g d` (delta) / `hunk diff` | hunkdiff (TUI) | diffview.nvim |
| Conflictos | `ec` (TUI) | inline (zdiff3) | editor |
| Commits | `g absorb`, `g amend` | custom cmds | :Git |
| Ramas | `git machete traverse` | branch mgmt | |

### Cómo se relacionan

```
                              ┌── rápido → delta
              ┌─ Visualizar ──┼── interactivo → hunkdiff
              │               └── profundo → diffview.nvim
              │
              │               ┌── simple → inline (lazygit + zdiff3)
Cambios ──────┼─ Resolver ────┼── medio → ec (3-pane TUI)
              │   conflicto   └── complejo → editor (code --wait)
              │
              │               ┌── último → g amend
              ├─ Arreglar ────┼── intermedios → g absorb + g polish
              │   commits     └── manual → g polish (rebase -i)
              │
              │               ┌── paralelo → worktrunk
              └─ Gestionar ───┤
                   ramas      └── cadena → git machete
```

### Flujos integrados

**Review de cambios** (delta + lazygit):
```
lazygit → archivo modificado → space (stage) → delta colorea el diff
n/N para navegar entre hunks → espacio para stage selectivo
c para commit → se ve el diff verbose (commit.verbose=true)
```

**Conflicto en rebase** (zdiff3 + ec + rerere):
```
g syncº → conflicto
  ├─ rerere lo reconoce → resuelve automático (revisas con git rerere diff)
  ├─ conflicto simple → lazygit muestra zdiff3 → resuelves inline
  └─ conflicto complejo → :ec → 3 paneles → seleccionas → guardas
git add . → g rebase --continue
```

**Arreglar commits anteriores** (git-absorb + g polish):
```
# Descubres un bug en código que commiteaste hace 3 commits
# Arreglas el bug (sin commitear aún)
g absorb        # crea fixup! commits para cada commit afectado
g polish 4      # rebase -i HEAD~4 → autosquash los fixups
# Los fixups ya están marcados como fixup en el rebase, solo :wq
g fp            # force push si ya habías pusheado
```

**Stacked branches** (git-machete):
```
git machete update        # registrar jerarquía actual
# ... trabajas en feat/sub y feat/sub-sub ...
git machete traverse      # rebasea feat/sub-sub → feat/sub → feat/base
git machete slide-out     # eliminar ramas ya mergeadas
```

### ¿Cuándo usar cada herramienta?

| Situación | Herramienta | Por qué esta y no otra |
|-----------|-------------|----------------------|
| Diff rápido (1-2 archivos) | delta en terminal/lazygit | Sin contexto pesado |
| Review interactivo multi-archivo | hunkdiff (TUI) | Navegación con sidebar + IA |
| Review de changeset de AI agent | hunkdiff (TUI) | Anotaciones inline, el agente participa |
| Analizar historial de archivo | diffview.nvim | Navegación entre commits del mismo archivo |
| Conflicto nuevo y simple | Marcadores zdiff3 inline | Sin herramienta externa |
| Conflicto con varias secciones | ec | 3 paneles > marcadores de texto |
| Conflicto que ya resolviste | rerere | No vuelves a hacerlo |
| Cambios que van a commits viejos | git-absorb | Encuentra los commits solo |
| Último commit necesita cambios | g amend | Directo, sin rebase |
| 1-2 ramas, sincronizar | g syncº | FZF selector, suficiente |
| 3+ ramas en cadena | git-machete | Rebasea toda la cadena automáticamente |

---

## Fish Git Abbreviations (`qol-git.fish`)

`g` wraps git. `checkout` está deshabilitado — usar `switch` (ramas) o `restore` (archivos). `g commands` lista todo.

### Esenciales
| Abbr | → | Uso |
|------|---|-----|
| `g u` | `pull --rebase --autostash` | Actualizar branch |
| `g syncº` | `fetch --prune --all; rebase` (fzf) | Sincronizar contra target |
| `g c` | `commit -m "..."` | Commit con mensaje |
| `g ia` | `add --patch` | Stage interactivo |
| `g p` | `push` | Push (auto --set-upstream) |
| `g fp` | `push --force-with-lease` | Safe force push |
| `g swº` | `switch` (fzf) | Cambiar de rama |
| `g cbr` | `switch -c` | Crear rama |
| `g aa` | `add -A` | Stage todo |
| `g absorb` | `git absorb` | Absorbe cambios en fixup commits |
| `g amend` | `commit -a --amend --no-edit` | Amend rápido |
| `g polish` | `rebase -i HEAD~!` | Rebase interactivo N commits |
| `g rbº` | `rebase` (fzf) | Rebase contra rama |
| `g mgº` | `merge` (fzf) | Merge con selector |
| `g br-nuke` | fzf → `branch -d` multi | Borrar ramas merged |
| `g undo` | `revert --no-edit HEAD` | Deshacer último commit |
| `g uncommit` | `reset --soft HEAD~!` | Uncommit N commits |
| `g gwip` | WIP commit `--wip-- [skip ci]` | Snapshot temporal |
| `g gunwip` | Undo WIP | Deshacer snapshot |
| `g prw` | `gh pr create --web` | Crear PR en browser |
| `g st` / `g sta` | `status --short` / `status` | Status rápido / completo |
| `g diff` / `g d` | `diff -w` | Diff sin whitespace |
| `g d s` | `diff --staged -w` | Staged diff |
| `g sh` | `show -w HEAD` | Ver HEAD commit |
| `g hunk` / `g hd` | `hunk diff` | Review interactivo working tree |
| `g hunk show` | `hunk show` | Review interactivo de commit |
| `g hunk show~` | `hunk show HEAD~1` | Review de commit anterior |
| `g h` | `git-h` (log graph coloreado) | Log fancy |
| `g fe` | `fetch --prune --all` | Fetch todo |
| `g dbrº` | `branch -d` (fzf) | Borrar rama |
| `g clear` | `reset --hard HEAD` | Reset total |

### Funciones útiles
| Función | Uso |
|---------|-----|
| `gst` / `gd` / `gwch` | Status/diff/whatchanged con snip (paginación) |
| `g commands` | Lista todas las abbr agrupadas |
| `abbrv` | Lista raw de abbr definitions |

### Context-Aware FZF (º)
| Secuencia | Hace |
|-----------|------|
| `g swº` / `g dbrº` | FZF selector de ramas |
| `g mgº` / `g ffmgº` / `g smgº` | FZF selector para merge |
| `g rbº` / `g syncº` | FZF selector para rebase target |
| `g rollbackº` | FZF selector de commits (últimos 50) |

---

## Custom Scripts

### `git-h` — Fancy Log (`~/.local/bin/git-h`)
Git log with graph, colored output, and parent info only for merge commits:
```
git log --graph --color=always \
  --format="%C(cyan)%h %C(green)(%cr) %s %C(yellow)%d %C(blue)[%an] %C(red)(%G?){%p}"
```
- Shows: hash, relative date, message, refs, author, GPG status
- Parent hashes omitted for non-merge commits (cleaner output)
- Piped through `less -FRSX`
- Supports `--all` flag

### `lazygit-cwd` — Context-Aware Lazygit (`~/.config/pypr/scripts/lazygit-cwd`)
Opens lazygit in the git root of the active window's working directory:
1. Discovers active window PID via `hyprctl`
2. Walks child processes to find deepest cwd
3. Resolves git root via `git rev-parse --show-toplevel`
4. Falls back to `~/.local/share/chezmoi` if not in a git repo
5. Opens terminal (wezterm/kitty fallback) with `lazygit -p <cwd>`

---

## FZF Git Integration

### `__fzf_git_prefix.fish` — CTRL-G Key Bindings
| Binding | Action |
|---------|--------|
| `CTRL-G f` | Files |
| `CTRL-G b` | Branches |
| `CTRL-G t` | Tags |
| `CTRL-G h` | Commit hashes |
| `CTRL-G s` | Stashes |
| `CTRL-G r` | Remotes |
| `CTRL-G l` | Reflogs |
| `CTRL-G e` | Each ref (`git for-each-ref`) |
| `CTRL-G w` | Worktrees |
| `CTRL-G ?` | Show binding list |

Powered by `fzf-git.sh` via `SHELL=bash bash fzf-git.sh --run <mode>`.

---

## OpenCode Git Commands (`~/.config/opencode/commands/git/`)

| File | Purpose |
|------|---------|
| `commit.md` | Git commit with conventional commit format |
| `create-pr.md` | Create PR from current branch |
| `review-pr.md` | Review open PR |
| `review-last-changes.md` | Review last changes before commit |
| `review-uncommited-changes.md` | Review uncommitted changes |
| `explain-pr.md` | Explain a PR in natural language |
| `summary-pr.md` | Summarize PR changes |
| `analyze-pr.md` | Analyze PR for issues |
| `discard.md` | Discard changes |

---

## Practical Examples

### Branch Strategy
- Default branch: `dev` (not `main`). Prevents accidental `main` creation.
- Feature branches: `feat/<name>`. `g cbr` to create, `g sw` (º) to switch.

### 🔍 fzf-git: Quick Navigation via CTRL-G

From anywhere in the terminal, type `CTRL-G` then a letter to launch fzf on the fly:

```bash
# Find a file and paste its path
CTRL-G f   # fzf lists all tracked files → pick one → path pasted in terminal

# Find a branch and check it out
CTRL-G b   # fzf lists branches → pick one → branch name pasted
g sw       # expands to "git switch" ← now you have the branch name ready

# Jump to a commit
CTRL-G h   # fzf log of commits → pick one → hash pasted

# Browse stashes
CTRL-G s   # fzf stash list → pick one → stash ref pasted

# Pick a worktree
CTRL-G w   # fzf worktree list → pick one → worktree path pasted
```

The `º` key (after abbrs) does the same thing contextually:
```bash
g rbº       # fzf picks target branch → rebase onto it
g swº       # fzf picks branch → switch to it
g rollbackº # fzf picks commit → revert it
g mgº       # fzf picks branch → merge it
```

### 🚀 abbr Power: Real Scenarios

**Hotfix emergency — branch off dev, fix, PR:**
```bash
g u                                  # pull --rebase --autostash (up to date)
g cbr hotfix/critical-bug            # create + switch to branch
# ...fix code...
g ia                                 # interactive add (stage only relevant hunks)
# o revisa los cambios antes de commit con hunkdiff:
g hunk                               # review interactivo multi-archivo
g c "fix: critical bug in parser"    # commit with message
g p                                  # push (auto --set-upstream)
g prw                                # create PR and open in browser
```

**Review my last 3 commits before pushing:**
```bash
g review 3       # uncommit → changes are now staged (working tree intact)
g d s            # review all staged changes (delta, no whitespace noise)
# o review interactivo en TUI:
g hunk           # hunk diff → sidebar, navegación multi-archivo
# ...if something's wrong, fix it...
g aa             # stage the fix
g amend          # squash into the last uncommit
g polish 3       # re-order and squash with rebase -i
g review-end     # restore to ORIG_HEAD if you want to abort
g fp             # safe force push (--force-with-lease)
```

**Sync a long-lived feature branch with dev:**
```bash
g syncº          # fzf → pick "dev" → fetch --prune --all + rebase onto dev
# ...resolve conflicts if any... rerere handles repeated ones
# zdiff3 shows the merge base context
# ec available for complex conflicts
g isync          # same but interactive (squash/fixup/reword your commits)
```

**Fix bugs across multiple previous commits:**
```bash
# Make fixes across 3 previous commits without manual hash lookup
g absorb         # auto-creates fixup! commits for each affected commit
g polish 4       # rebase -i with autosquash → fixups fold into originals
g fp             # safe force push
```

**Stacked branches (with git-machete):**
```bash
git machete update    # register branch hierarchy
# ...work on feat/sub and feat/sub-sub...
git machete traverse  # rebase entire chain in sequence
git machete slide-out # remove merged branches from chain
```

**Oops, committed to the wrong branch:**
```bash
# Undo the commit without losing changes
g uncommit 1     # reset --soft HEAD~1 (changes stay staged)

# Move them to the right branch
g cbr feat/right-branch
g c "feat: this was meant for here"
```

**Bulletproof git blame — find who introduced a bug:**
```bash
git blame src/parser.rs
# Faded = old commits. Bold white = last month. Blue = last 7 days.
# "3 weeks ago" human dates. Short hashes.
```

### 🖥️ Lazygui Workflows

**Context-aware launch** — from any app, trigger the keybind for `lazygit-cwd`:
```bash
# Automatically opens lazygit in the git root of your active editor/terminal
# Falls back to ~/.local/share/chezmoi if cwd isn't a repo
```

**Inside lazygit:**
| Key | Action | When |
|-----|--------|------|
| `1` | Status pane | See what's dirty |
| `2` | File staging | Stage/unstage individual hunks (`space`) |
| `3` | Branch list | `n` new branch, `M` merge, `R` rebase |
| `4` | Log / graph | `C` cherry-pick, `s` squash |
| `5` | Diff | Review staged vs unstaged |
| `space` | Toggle staged | On a file or hunk |
| `c` | Commit | Opens commit message editor |
| `P` | Push | `p` push, `P` force push |
| `r` | Rebase options | `r` rebase branch, `i` interactive |
| `d` | Diff modes | `d` enter diff, `n` next, `p` prev |
| `Ctrl-A` | git absorb | Auto fixup commits |
| `Ctrl-M` | machete status | Branch hierarchy |
| `:` | Custom command | Run any git command |
| `+` | Open in terminal | `+` open shell at repo root |

**Conflict resolution inside lazygit:**
| Key | Action | When |
|-----|--------|------|
| `e` | Open mergetool (ec) | On a conflicted file |
| Arrow keys | Navigate conflict | In diff view |
| `z` | Undo last commit/operation | After mistake |

### ♻️ Rerere — "Reuse Recorded Resolution"

Rerere remembers how you resolved conflicts and re-applies that resolution automatically next time. Combined with **zdiff3** (shows merge base) and **ec** (visual 3-pane resolution):

```bash
# You're rebasing a feature. Conflict appears.
# If rerere has seen this → auto-resolves
# If new conflict → zdiff3 shows HEAD ||||| base ======= branch
# If complex → ec opens 3-pane visual resolver
# After resolving → rerere records it for next time
```

**When it shines:**
- **Rebasing a feature multiple times** — same conflicts auto-resolve
- **Cherry-picking across branches** — similar patches auto-resolve
- **Stashing/pop during rebase** — rerere survives stash cycles

**Managing rerere:**
```bash
git rerere status          # see what conflicts are recorded
git rerere diff            # see the recorded resolution
git rerere forget <path>   # forget a specific conflict resolution
```

### Checking git object integrity (fsckObjects)
Every fetch, push, and receive verifies object integrity:
```bash
# Corrupted objects are rejected immediately, not discovered weeks later
g fe    # fetch + verify
g p     # push + verify
```

### 🧹 Cleanup Workflows

```bash
# Delete merged local branches interactively
g br-nuke    # fzf lists merged branches (excludes main/master/develop/deploy)
             # multi-select with Tab, Enter to delete

# Check what's merged before nuking
g mergeds    # show all merged branches

# Discard everything and start fresh
g clear      # reset --hard HEAD (⚠️ destroys uncommitted work)
```

### 🔄 Review interactivo con hunkdiff

```bash
# Revisar working tree (incluye untracked)
g hunk                    # hunk diff → TUI con sidebar multi-archivo

# Revisar último commit
g hunk show               # hunk show HEAD

# Revisar commit anterior
g hunk show~              # hunk show HEAD~1

# Revisar diff entre dos ramas
hunk diff dev...feature   # changes from dev to feature

# Watch mode — auto-reload
g hd --watch              # se actualiza solo al cambiar archivos

# En la TUI:
# Tab           → alternar split/stack layout
# ↑ ↓           → navegar archivos en sidebar
# → ←           → navegar hunks dentro del archivo
# Space         → saltar al siguiente hunk
# /             → buscar en el diff
# t             → selector de temas
# q             → salir
```

### 🤖 Review de AI Agent con hunkdiff + opencode

```
1. Terminal 1: g hunk                  # abres hunk diff en una terminal
2. Terminal 2: opencode                # abres opencode para programar
3. El agente usa el skill de hunk:
   - hunk session review --json        # inspecciona estructura del diff
   - hunk session navigate ...         # navega a archivos/hunks específicos
   - hunk session comment add ...      # añade comentarios inline
```

Para que opencode use el skill:
```bash
# Obtener ruta del skill para cargar en el agente
hunk skill path
# → /home/buble/.../hunkdiff/skills/hunk-review/SKILL.md
```

### Flujo integrado delta → hunkdiff → diffview.nvim

```bash
# 1. Glance rápido — delta en terminal
g d                        # diff rápido sin whitespace

# 2. Review interactivo — hunkdiff TUI
g hunk                     # navegación multi-archivo con sidebar

# 3. Análisis profundo — diffview en Neovim (en lazygit: e → :DiffviewFileHistory %)
:DiffviewFileHistory %     # historial completo del archivo actual
```

### Daily Flow
```bash
# Start your day
g u                    # pull --rebase --autostash

# Stage & commit
g ia                   # interactive add (stage only what matters)
g c "feat: add login"  # commit with message

# Sync with target branch
g sync                 # fzf → pick "dev", rebase onto it

# Push
g p                    # push (auto --set-upstream)

# Open PR
g prw                  # create PR in browser
```

### Compaction (Local History)
```bash
g amend           # add staged changes to last commit (local/unconsumed remote)
g polish 3        # rebase -i last 3 commits (squash, reword, reorder)
g local-polish    # rebase -i commits since origin/<branch>
```

### WIP (Temporary Snapshot)
```bash
g gwip                    # commit ALL as --wip-- [skip ci] (untracked + modified)
g gunwip                  # undo last WIP commit (preserves changes)
```
