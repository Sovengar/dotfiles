# Ecosistema de Herramientas CLI

Cada herramienta resuelve un problema concreto. Combinadas, multiplican.

## Catalogo

### Productividad

| Herramienta | Que hace | Por que importa |
|---|---|---|
| **[opencode](https://opencode.ai)** | Agente de coding con IA. Planifica, implementa, revisa y testea. | Orquesta todo el flujo de desarrollo. Ejecuta tareas complejas con agentes especializados (architect, debugger, reviewer, etc.) mientras tu piensas en el problema, no en los pasos. |
| **[mise](https://mise.jdx.dev)** | Gestor de versiones de runtimes. Reemplaza nvm, pyenv, rbenv, etc. | Un solo archivo (`~/.config/mise/config.toml`) define node, go, rust, python, java, etc. por proyecto. `mise install` y listo. |
| **[chezmoi](https://chezmoi.io)** | Gestor de dotfiles. Sincroniza configuracion entre maquinas. | Formateas la maquina, `chezmoi init && chezmoi apply`, y en 5 minutos tienes tu entorno exacto. Templates, scripts de instalacion, todo versionado. |
| **[snip](https://github.com/anomalyco/snip)** | Sintetiza salida de comandos verbosos. | `npm install | snip` te da solo lo relevante. Ahorra tokens y ruido mental en sesiones de opencode. |
| **[bottom](https://github.com/ClementTsang/bottom)** | Monitor de sistema y procesos. Graficos TUI de CPU, RAM, disco, red, temps. | `btm` te da una visualizacion en tiempo real de que consume recursos. Mas ligero e informativo que el Task Manager. Ideal para debuggear cuellos de botella mientras corres builds o tests. |

### Navegacion y Busqueda

| Herramienta | Que hace | Por que importa |
|---|---|---|
| **[cdx](docs/cdx.md)** | CD vitaminado. Salta a directorios por nombre o busca archivos/texto con fzf. | Combina zoxide (frecuencia) + ripgrep (contenido) + fzf (seleccion visual). Si zoxide no conoce el dir, busca en `$HOME` y te lleva. |
| **[zoxide](https://github.com/ajeetdsouza/zoxide)** | `cd` inteligente que aprende tus directorios frecuentes. | `z dev` te lleva a `~/dev` sin importar donde estes. Aprende con el uso. cdx lo usa como primera opcion antes de hacer search. |
| **[fzf](https://github.com/junegunn/fzf)** | Buscador difuso interactivo. | `Ctrl+T` pega la ruta del archivo seleccionado. `Ctrl+R` busca en tu historial. `**<Tab>` en cualquier comando. |
| **[ripgrep (rg)](https://github.com/BurntSushi/ripgrep)** | Busqueda de texto ultra-rapida. Rust. | Reemplaza `grep`. 10-100x mas rapido. Respeta `.gitignore` por defecto. cdx lo usa como motor de busqueda. |

### Git

| Herramienta | Que hace | Por que importa |
|---|---|---|
| **[lazygit](https://github.com/jesseduffield/lazygit)** | TUI para git. Navega stage, diff, commits, branches, rebase con teclas. | Mas rapido que escribir `git add -p` o `git rebase -i`. Preview de diff en tiempo real. |
| **[gh dash](https://github.com/dlvhdr/gh-dash)** | Dashboard TUI para GitHub. PRs, issues, CI checks, notificaciones en una sola vista. | `gh dash` te muestra todo lo que tienes pendiente en GitHub sin abrir el navegador. Cambia entre tus PRs, los del equipo, necesitan review, CI fallido — con preview del diff. |

### Terminal y Shell

| Herramienta | Que hace | Por que importa |
|---|---|---|
| **[wezterm](https://wezfurlong.org/wezterm)** | Emulador de terminal GPU-accelerated. Lua config. | Multiplexer integrado (no necesitas tmux en Windows). Splits, tabs, ligaduras,キーバインド todo en `~/.config/wezterm/`. |
| **[starship](https://starship.rs)** | Prompt cross-shell. Minimal, rapido, informativo. | Muestra git branch, runtime version (via mise), estado de archivos modificados, duracion del ultimo comando. Una sola config para PowerShell, bash, zsh. |
| **[Neovim](https://neovim.io) + LazyVim** | Editor modal moderno. | No sales jamas de la terminal. LSP, Tree-sitter, fuzzy finder, todo integrado. Config en `~/.config/nvim/`. |

### PowerShell Utilities

| Herramienta | Que hace | Por que importa |
|---|---|---|
| **[LinuxAliases.ps1](https://github.com/Sovengar/dotfiles/blob/master/home/Documents/PowerShell/LinuxAliases.ps1)** | Aliases Linux para PowerShell. ls -la, touch, grep, head, tail, which, df -h, du -sh, uptime, ps aux, wc -l, find, rm -rf. | Musculo mental de Linux funciona en Windows sin friccion. `ls -la` hace lo que esperas, `grep` usa ripgrep si esta instalado, `ps aux` lanza bottom si existe, `find` usa fd. Auto-detection de herramientas nativas. |
| **[DatreeCompletion.ps1](https://github.com/Sovengar/dotfiles/blob/master/home/Documents/PowerShell/DatreeCompletion.ps1)** | Autocompletado de argumentos para `datree` CLI. | `datree test <Tab>` lista subcomandos y flags con descripciones. Creado via Cobra/Go auto-completion generator para PowerShell. |

---

## Casos de Uso: Como Sacar el 300%

### 1. Flujo de PR completo sin tocar GitHub en el navegador

```
# Creas rama, implementas, commiteas, creas PR
$ cdx mi-proyecto           # llegas al repo en 1s
$ lazygit                    # ves diff, stageas archivos, commiteas
$ gh pr create --fill        # crea PR con titulo/body del commit
$ opencode /review-pr 42     # opencode analiza el PR completo
```

**Combo:** `cdx` + `lazygit` + `gh` + `opencode`

No abriste el navegador. No copiaste URLs. Todo desde el terminal en < 2 min.

### 2. AI-driven development con spec-first workflow

```
$ opencode /sdd-new "sistema de notificaciones"   # opencode planifica, diseña, spec, tasks
$ opencode /sdd-apply                               # implementa paso a paso
$ lazygit                                            # revisas diff
$ opencode /sdd-verify                              # valida implementacion vs spec
$ gh pr create --fill                                # PR listo
```

**Combo:** `opencode` (SDD) + `lazygit` + `gh`

El agente hace el 80% del trabajo mecanico. Tu te concentras en las decisiones de diseño.

### 3. Busqueda y navegacion instantanea

```
$ cdx -s "function connectToServer"      # busca en TODO $HOME archivos que contengan esa funcion
                                          # fzf te muestra preview con contexto
                                          # Enter → navega al git root de ese archivo
$ nvim .                                  # ya estas en el repo correcto editando
```

**Combo:** `cdx` + `ripgrep` + `fzf` + `nvim`

De "donde esta esa funcion" a "editandola en neovim" en < 5 segundos.

### 4. Taming verbose output con snip

```
$ npm install | snip              # solo ves lo relevante, no 200 lineas de warnings
$ opencode "analiza este error"   # copias el output ya filtrado
```

**Combo:** `snip` + `opencode`

En sesiones de debug, snip reduce el ruido y opencode procesa solo la señal.

### 5. Entorno de desarrollo reproducible en maquina nueva

```
# Dia 0: formateas la maquina
$ winget install twpayne.chezmoi
$ chezmoi init https://github.com/Sovengar/dotfiles
$ chezmoi apply
# → winget instala zoxide, rg, fzf, lazygit, wezterm, etc.
# → mise install (node, go, rust, java, python, etc.)
# → starship configurado, nvim con LazyVim, alias cargados
# → opencode configurado con agentes, skills y plugins

# Dia 0 + 10 minutos: estas programando
$ cdx proyecto
$ opencode "lee AGENTS.md y continua donde lo dejamos"
```

**Combo:** `chezmoi` + `winget` + `mise` + `opencode` + `starship`

Tu dotfiles repo es tu "maquina en una caja". Cada tool, cada config, cada preferencia — versionada y reproducible.

### 6. Code review adversarial con dos jueces ciegos

```
$ opencode /review                    # lanza 2 agentes code-reviewer en paralelo
                                      # sintetiza hallazgos, aplica fixes, re-juzga
$ lazygit                             # revisas el diff de los fixes aplicados
$ git push                            # todo limpio
```

**Combo:** `opencode` + `lazygit`

Dos agentes revisan tu codigo sin sesgo, encuentran problemas que un solo reviewer pasaria por alto.

### 7. Debug sistematico con 5 Whys

```
$ cdx proyecto-bug
$ opencode "investiga por que falla X"     # opencode debugger hace 5 Whys
                                            # traza el flujo de datos, formula hipotesis
$ opencode "implementa el fix"              # aplica correccion
$ opencode /test                            # corre tests
$ lazygit && git push                       # commit + push
```

**Combo:** `opencode` (debugger agent) + `cdx` + `lazygit`

El agente de debug sigue una metodologia estructurada en lugar de parchear sintomas.

### 8. Navegacion con fzf integrada en el shell

```powershell
# Ctrl+T: buscar archivo por nombre difuso y pegar ruta
# Ctrl+R: buscar comando en historial
# **<Tab>: autocompletar cualquier argumento con fzf

$ nvim **<Tab>         # fzf te deja elegir el archivo visualmente
$ cd **<Tab>           # fzf te deja elegir directorio
$ ssh **<Tab>          # fzf sobre ~/.ssh/config
```

**Combo:** `fzf` + `PSFzf` + `starship`

El shell se vuelve navegable por patrones difusos en vez de paths exactos.

### 9. Inspeccion de proyectos desconocidos

```
$ cdx proyecto-nuevo
$ opencode "dame onboarding de este proyecto"    # reconstruye flujos funcionales desde el codigo
$ lazygit log                                      # entiendes el historial de cambios
```

**Combo:** `opencode` (onboarding agent) + `cdx` + `lazygit`

Llegas a un repo que no conoces y en 2 minutos tienes un mapa mental de la arquitectura y los flujos clave.

### 10. Loop completo: idea → issue → PR → merge

```
$ opencode /refine-idea "los usuarios necesitan exportar a CSV"
    # → crea issue con user story, acceptance criteria, tasks
$ opencode /sdd-new-from-issue 42
    # → planifica, diseña, especifica
$ opencode /sdd-apply
    # → implementa
$ opencode /review
    # → code review adversarial
$ gh pr create --fill
$ gh pr merge --squash
```

**Combo:** `opencode` (SDD completo) + `gh` + `lazygit`

De idea a main sin que escribas una linea. Tu rol es revisar decisiones y aprobar.

### 11. Dashboard de PRs: triage y accion en segundos

```
$ gh dash                        # ves todos los PRs pendientes: tuyos, del equipo, para revisar
                                 # preview inline del diff en cada PR
                                 # Enter sobre un PR → abres en el navegador
$ cdx repo-del-PR                # o saltas directo al repo con cdx para trabajar en local
$ lazygit                        # ves branches, diffs, haces checkout del branch del PR
$ opencode "analiza el PR #53"   # opencode revisa el PR con mas profundidad
```

**Combo:** `gh dash` + `cdx` + `lazygit` + `opencode`

El dashboard te da visibilidad global (¿que PRs me toca revisar? ¿cual fallo CI?). De ahi saltas a accion en 2 segundos.

### 12. Perfilado de recursos durante builds

```
$ bottom                         # dejas btm corriendo en un split/pestaña de wezterm
$ opencode /test                 # corres los tests
                                 # bottom te muestra si el build saturo CPU, si se fue la RAM,
                                 # si el disco es el cuello de botella
```

**Combo:** `bottom` + `wezterm` (splits) + `opencode`

Ejecutas tareas pesadas mientras monitoreas en tiempo real. Si algo se arrastra, bottom te dice que recurso esta al limite sin conjeturas.

### 13. Musculo mental Linux en PowerShell: zero friction

```powershell
$ cd ~/dev/proyecto
$ ls -lah                   # modo largo + ocultos + tamanos legibles. No Get-ChildItem.
$ grep -r "TODO" .          # busca en archivos con ripgrep bajo el capo (auto-detect)
$ touch new-file.ts         # crear archivo vacio o actualizar timestamp
$ head server.log -n 20     # primeras 20 lineas
$ tail -f server.log        # follow en tiempo real
$ df -h                     # espacio en disco con colores (rojo > 90%, amarillo > 70%)
$ du -sh node_modules       # cuanto pesa esa carpeta
$ ps aux                    # lanza bottom directamente si esta instalado
$ which rg                  # donde esta ripgrep?
$ uptime                    # cuanto lleva encendida la maquina
$ rm -rf temp/              # borrar sin confirmacion, como en Linux
```

**Combo:** `LinuxAliases.ps1` + `rg` + `fd` + `bottom`

El script hace auto-detection: si `rg` existe, `grep` lo usa; si `fd` existe, `find` lo usa; si `btm` existe, `ps aux` lo lanza. Escribes comandos Linux y ejecutan la herramienta mas rapida disponible.

---

## Jerarquia de Herramientas

```
                    opencode (orquestacion)
                         |
        +----------------+----------------+
        |                |                |
    lazygit (git)   cdx (nav)     mise (runtimes)
        |                |                |
  gh + gh dash    zoxide+rg+fzf   node/go/rust/...
        |                |                |
      bottom          nvim (edicion)
        |                |
    wezterm + starship (shell)
        |
  LinuxAliases + DatreeCompletion (puente Linux->PS)
        |
  chezmoi (todo esto versionado)
```

Cada capa se apoya en la inferior. `chezmoi` es la base: sin el, cada maquina nueva es empezar de cero.
