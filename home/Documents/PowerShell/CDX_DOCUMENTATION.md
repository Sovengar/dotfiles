# cdx — CD Interactivo Unificado

## Tabla de Contenidos

- [Alto Nivel (Usuario)](#alto-nivel-usuario)
  - [¿Qué es cdx?](#qué-es-cdx)
  - [Dependencias Externas](#dependencias-externas)
  - [Guía Rápida](#guía-rápida)
  - [Modos de Uso](#modos-de-uso)
  - [Referencia de Atajos TUI](#referencia-de-atajos-tui)
  - [Listas de Exclusión](#listas-de-exclusión)
- [Bajo Nivel (IA / Desarrollador)](#bajo-nivel-ia--desarrollador)
  - [Arquitectura General](#arquitectura-general)
  - [Entry Point — Enrutamiento de 4 Vías](#entry-point--enrutamiento-de-4-vías)
  - [Sistema de Estado — Mascara de 3 Bits](#sistema-de-estado--máscara-de-3-bits)
  - [Modo Find — Listado de Directorios con fd](#modo-find--listado-de-directorios-con-fd)
  - [Modo Search — Listado de Archivos con ripgrep](#modo-search--listado-de-archivos-con-ripgrep)
  - [Integración Zoxide — Merge de Frecuencia](#integración-zoxide--merge-de-frecuencia)
  - [Sistema de Preview](#sistema-de-preview)
  - [Búsqueda Global (-g): 3 Fases](#búsqueda-global--g-3-fases)
  - [Resolución de Destino](#resolución-de-destino)
  - [Infraestructura de Archivos Temporales](#infraestructura-de-archivos-temporales)
  - [Script de Reload — Generación Dinámica de Código](#script-de-reload--generación-dinámica-de-código)
  - [Sistema de Exclusión (3 Categorías)](#sistema-de-exclusión-3-categorías)
  - [Diagrama de Flujo de la TUI](#diagrama-de-flujo-de-la-tui)
  - [Edge Cases y Gotchas](#edge-cases-y-gotchas)

---

# Alto Nivel (Usuario)

## ¿Qué es cdx?

**cdx** es un navegador interactivo de directorios para PowerShell, construido sobre `fzf`, `fd` y `ripgrep`. Reemplaza al `cd` tradicional con una interfaz TUI que permite:

- **Navegar** carpetas con fuzzy finding, preview de contenido y merges de zoxide.
- **Buscar** archivos por contenido a nivel global entre tus proyectos.
- **Alternar** entre modo carpetas (fd) y modo archivos (rg) en caliente.

Todo desde una sola función: `cdx`.

## Dependencias Externas

| Herramienta | Necesaria | Propósito |
|-------------|-----------|-----------|
| **fzf** | Sí | Motor de fuzzy-finding TUI |
| **fd** | Sí | Listado rápido de directorios |
| **ripgrep (rg)** | Sí (TUI + -g) | Listado de archivos y búsqueda de contenido |
| **zoxide** | Opcional | Merge de directorios frecuentes |
| **eza** | Opcional | `ls` con icons y colores (preview) |
| **bat** | Opcional | Syntax highlighting en preview |

Instalación rápida:
```powershell
winget install sharkdp.fd
winget install BurntSushi.ripgrep.MSVC
winget install junegunn.fzf
winget install eza-community.eza
winget install sharkdp.bat
winget install ajeetdsouza.zoxide
```

## Guía Rápida

```powershell
cdx                    # Abre TUI en el directorio actual
cdx <ruta>             # cd directo si la ruta existe
cdx <nombre>           # Busca con zoxide, fallback a TUI
cdx -g <query>         # Búsqueda global por contenido
cdx ~                  # Atajo directo a $HOME
cdx ...                # Atajo directo a $HOME
```

## Modos de Uso

### Jump (cdx `<name>`)

1. Si `<name>` es `~` o `...` → `cd` directo a `$HOME` + `ls`.
2. Si `<name>` es una ruta que existe → `cd` directo + `ls`.
3. Si no existe pero zoxide la reconoce → `cd` al resultado de zoxide + `ls`.
4. Si no se cumple nada → abre la TUI con el query pre-llenado.

Tras el `cd`, si el destino está dentro de un repositorio git, se muestra un mensaje en gris sugiriendo herramientas para abrir el proyecto.

### Browse (cdx sin argumentos)

Abre la TUI en el directorio actual, mostrando subdirectorios con merge de zoxide (marcados con ★).

### Search (cdx -g `<query>`)

Búsqueda global que escanea `~/dev`, `~/.config` y `~` en 3 fases: contenido, nombre de archivo, nombre de directorio. Resultados se presentan en fzf con preview.

## Referencia de Atajos TUI

| Tecla | Acción |
|-------|--------|
| **Enter** | En modo Find: `cd` al directorio. En modo Search: abrir archivo con `bat`. |
| **Esc** (simple) | Subir al directorio padre (`cd ..`). |
| **Ctrl+C** | Salir de la TUI (se queda en el directorio actual). Si es un repo git, sugiere herramientas. |
| **Ctrl+G** | Alternar entre modo Find (fd) y modo Search (rg). |
| **Ctrl+A** | Alternar visibilidad de dotfiles (.*). |
| **Ctrl+W** | Alternar visibilidad de directorios Windows (AppData, ProgramData). |
| **Ctrl+H** | Ir al home (`~`) inmediatamente. |
| **Ctrl+O** | `cd` al directorio seleccionado + abrir con **yazi**. Si el item es un archivo, abre su directorio padre. Equivalente a un "open" externo. |

## Listas de Exclusión

Tres categorías de exclusión configurables al inicio del script:

- **ExcludeDirs**: `node_modules`, `.git`, `.cache`, `cache`, `licenses`, `vendor`, `target`, `build`, `dist`, `Modules`, `modules`, `lib`, `platform`
- **ExcludeWinDirs**: `AppData`, `ProgramData`
- **ExcludePathGlobs**: `**/go/pkg/mod`

---

# Bajo Nivel (IA / Desarrollador)

## Arquitectura General

El sistema se compone de 5 funciones que se orquestan desde un entry point único:

```
Entry Point (cdx)
├── Search (-g) ──────> Invoke-CdxSearch ──> Resolve-CdxDestination
├── TUI (sin args) ───> Invoke-CdxTui (while-loop infinito)
├── Shortcuts (~, ...) ──> ShowResult (HOME)
├── Direct Path ──────> ShowResult
└── Zoxide ───────────> ShowResult
```

La TUI mantiene un **bucle infinito** (`while ($true)`) que:
1. Lee el estado actual (archivo temporal).
2. Genera items según el modo (fd o rg).
3. Los pasa a fzf.
4. Procesa la selección.
5. Repite hasta que el usuario sale (Esc en raíz o Ctrl+C).

## Entry Point — Enrutamiento de 5 Vías

El entry point recibe argumentos posicionales y un flag `-g`. La lógica de decisión es secuencial:

1. **Flag `-g` activo** → desvía a la función de búsqueda global (ripgrep sobre múltiples roots). Retorna inmediatamente.
2. **Sin argumentos** → abre la TUI sin query inicial. Retorna inmediatamente.
3. **Atajos a `$HOME`** → si el query es `~` o `...`, navega a `$HOME` + `ShowResult`.
4. **Con argumentos, ruta existe** → hace `Set-Location` directo + `ShowResult`.
5. **Con argumentos, ruta NO existe, zoxide disponible** → consulta zoxide. Si devuelve algo, navega ahí + `ShowResult`.
6. **Fallback** → abre la TUI con el query como `-InitialQuery`, que fzf usará como texto pre-escrito.

## Sistema de Estado — Máscara de 3 Bits

El estado de la TUI se representa con un **entero de 3 bits** almacenado en un archivo de texto (`TEMP\cdx_state.txt`). Cada bit controla un toggle independiente:

| Bit | Máscara | Control | Off | On |
|-----|---------|---------|-----|----|
| 0 | `0b001` = 1 | Modo: Find (fd) vs Search (rg) | fd (Find) | rg (Search) |
| 1 | `0b010` = 2 | Dotfiles | Ocultos | Visibles |
| 2 | `0b100` = 4 | Directorios Windows ocultos | Ocultos | Visibles |

**Valor inicial: `2`** → Find mode, dotfiles visibles, WinHidden ocultos.

**Mecanismo de toggle:** XOR bit a bit (`-bxor`). Cada atajo (Ctrl+G, Ctrl+A, Ctrl+W) hace un reload con la máscara correspondiente:
- Ctrl+G → toggle bit 0 (mask 1)
- Ctrl+A → toggle bit 1 (mask 2)
- Ctrl+W → toggle bit 2 (mask 4)

La lectura del estado se hace con AND bit a bit (`-band`):
```
rgMode       = (state -band 1) -ne 0   # bit 0
showDotfiles  = (state -band 2) -ne 0   # bit 1
showWinHidden = (state -band 4) -ne 0   # bit 2
```

Este estado se lee **cada iteración del loop** desde el archivo, lo que permite que el reload script (corriendo en un proceso hijo) modifique el estado y la siguiente iteración del loop lo recoja.

### ¿Por qué un archivo y no una variable?

- El reload script se ejecuta como proceso **hijo** de fzf. No comparte el scope de PowerShell de la TUI.
- La comunicación entre procesos padre e hijo se hace mediante el sistema de archivos (archivo temporal).
- Las variables de entorno (`CDX_CURRENT_PATH`, `CDX_PREVIEW_BASE`) también se usan para pasar contexto al hijo.

## Modo Find — Listado de Directorios con fd

Cuando el bit 0 = 0, la TUI lista **directorios**.

### Driver primario: `fd`

Herramienta `fd` con estos argumentos base:
- `--base-directory <currentPath>`
- `--type d` (solo directorios)
- Exclusiones dinámicas según estado de dotfiles/WinHidden
- Directorio actual `.`

### Manejo especial: Drive Roots

Si el path actual es una raíz de unidad (e.g., `C:\`), `fd` no funciona bien. Se usa `Get-ChildItem -Directory` como fallback. Esto también aplica los filtros de exclusión de Windows.

### Merge con Zoxide

El merge de zoxide es un **algoritmo O(n)** que recorre todo el cache de zoxide (absolutos) y extrae paths relativos que cuelgan del directorio actual:

1. Toma el cache de zoxide (lista de paths absolutos, recolectada al inicio de la TUI).
2. Por cada path, si es subdirectorio del actual, calcula el path relativo.
3. Verifica que ningún segmento intermedio esté en la lista de exclusión.
4. Si pasa, lo marca con prefijo `★ ` y lo agrega al mapa de deduplicación.
5. Los items de fd solo se incluyen si NO están ya en el mapa de zoxide (evita duplicados).

**Orden de items en fzf:**
1. Header (línea 1, consumida por `--header-lines 1`)
2. Directorios zoxide (con ★)
3. Directorios fd no duplicados

Esto permite que los directorios que visitas frecuentemente aparezcan primero en la lista.

### Cache de Zoxide

Al iniciar la TUI, se ejecuta `zoxide query --list` una sola vez y se guarda en una variable de script. El reload script (proceso hijo) no tiene acceso a esta variable, por lo que:
- El reload script lee desde un archivo (`TEMP\cdx_zoxide_cache.txt`) que se escribe al inicio.
- **Importante:** Esto significa que los nuevos directorios visitados con zoxide durante la sesión de TUI NO aparecen hasta que se reinicia cdx.

## Modo Search — Listado de Archivos con ripgrep

Cuando el bit 0 = 1, la TUI lista **archivos** en vez de directorios.

### Driver: `rg --files`

Herramienta `rg` (ripgrep) con estos argumentos:
- `--files` (lista todos los archivos, no busca contenido)
- `--smart-case`
- Condicional: `--hidden` si dotfiles o WinHidden están activos
- Exclusiones mediante `--glob !<pattern>`
- Path actual como target

### Comportamiento al seleccionar

A diferencia del modo Find (que hace cd), en modo Search al presionar **Enter**:
1. Se muestra el contenido del archivo con `bat` (o `Get-Content` como fallback).
2. No se cambia el directorio actual.
3. El loop de TUI continúa (el fzf padre reaparece).

**Esto permite "hojear" archivos sin salir de la TUI.**

## Integración Zoxide — Merge de Frecuencia

### Estrategia

Zoxide provee paths absolutos de directorios frecuentes. La TUI los convierte a paths relativos y los muestra con prioridad (marcados con ★) sobre los resultados de fd.

### Algoritmo de Merge (modo Find)

```
Input: zoxideCache (paths absolutos), currentPath, fdDirs (paths relativos)
Output: Lista combinada (zoxide first, luego fd no duplicados)

1. Para cada z en zoxideCache:
   a. Si z == currentPath → skip
   b. Si z empieza con currentPath:
      - Calcular path relativo
      - Verificar que ningún segmento intermedio está en excludeDirs
      - Verificar go/pkg/mod exclusion
      - Agregar a zoxideMap y zoxideDirs con prefijo "★ "
2. Para cada d en fdDirs:
   a. Si d no está en zoxideMap → agregar sin prefijo
3. Retornar: [header] + zoxideDirs + fdDirs sin duplicar
```

### Limitación conocida

El cache de zoxide se recolecta solo al inicio de la TUI. Si durante la sesión navegas a un directorio nuevo (y zoxide lo aprende), ese directorio no aparece con ★ hasta que reinicies cdx.

## Sistema de Preview

La TUI usa `--preview` de fzf para mostrar información contextual del item seleccionado. Hay dos modos de preview según el modo activo:

### Preview en Modo Find

Se genera un script PowerShell (`TEMP\cdx_preview.ps1`) que se ejecuta con `pwsh -NoProfile -File`. El preview incluye:

1. **Contenido del directorio** con `eza --icons --group-directories-first --color=always` (o `Get-ChildItem | Format-Table` como fallback).
2. **Árbol de directorios** hasta profundidad 2, con exclusiones aplicadas.
3. **Git status** si el directorio contiene `.git`:
   - Ejecuta `git status --short` dentro del directorio.
   - Muestra "Clean" si no hay cambios.
   - Muestra "Not a git repo" si hay error.

Si el item seleccionado es un archivo (no directorio), el preview muestra:
- Contenido del archivo (primeras 50 líneas) con `bat` o `Get-Content`.
- Git status del archivo relativo al root del repo.

### Preview en Modo Search

Usa `bat --color=always --line-range :50 --highlight-line {q}` directamente como comando de preview de fzf. Esto:
- Muestra las primeras 50 líneas.
- Resalta la línea que coincide con el query de búsqueda.
- Es rápido porque `bat` es un binario nativo, no un script PowerShell.

### Mecanismo de Path en Preview

El preview script recibe el path relativo desde fzf. Usa la variable de entorno `CDX_PREVIEW_BASE` para reconstruir el path absoluto. Si la variable no está definida, usa `Get-Location` como fallback.

## Búsqueda Global (-g): 3 Fases

La función de búsqueda (`-g <query>`) ejecuta **3 fases secuenciales** y combina los resultados:

### Fase 1: Coincidencias de Contenido

Busca archivos que contengan el query. Usa:
```
rg --files-with-matches --smart-case --hidden --max-depth N <query> <root>
```

Se ejecuta primero sobre los **priority roots** (`~/dev`, `~/.config`) con profundidad 6, luego sobre `~` completo con profundidad 5.

### Fase 2: Coincidencias de Nombre de Archivo

Busca archivos cuyo **nombre/ruta** contenga el query. Usa:
```
rg --files --hidden --max-depth N <root> | rg --smart-case <query>
```

El primer comando lista todos los archivos, el segundo filtra por el query. Misma estrategia de profundidad (priority roots: 6, HOME: 5).

### Fase 3: Coincidencias de Nombre de Directorio

Busca directorios cuyo nombre contenga el query. Usa:
```
Get-ChildItem -Directory -Recurse -Depth N | Where-Object FullName -like "*query*"
```

Con exclusión de nombres de directorio no deseados.

### Combinación y Presentación

Las 3 fases se concatenan, se filtran valores vacíos y se deduplican con `Select-Object -Unique`. Luego se pasan a fzf con preview que muestra 3 líneas de contexto alrededor de la coincidencia (usando `rg --context=3`).

### Resolución al Seleccionar

Al seleccionar un resultado, la función de resolución determina qué hacer:
- **Es un directorio**: hace `cd` directo.
- **Es un archivo**: hace `cd` al directorio padre, luego intenta navegar al **git root** (si aplica), mostrando al usuario que navegó al root del repo.

## Resolución de Destino

Cuando se selecciona un path (desde búsqueda -g o desde preview):

1. **Validación**: Si el path ya no existe, muestra error.
2. **Si es directorio**: `Set-Location` directo.
3. **Si es archivo**:
   - `cd` al directorio padre.
   - Si `git` está disponible y el path está dentro de un repo, `cd` al **git root** (`git rev-parse --show-toplevel`).
   - Si no hay git root, se queda en el directorio padre.

**Justificación del git root:** Cuando buscas un archivo específico, probablemente quieras trabajar en el contexto del repositorio completo, no en el subdirectorio profundo donde está el archivo.

## ShowResult — Display Unificado Post-Navegación

`ShowResult` es la función única que maneja todo el output después de que `cdx` finaliza su navegación. Consolida tres responsabilidades que antes estaban duplicadas en 4 lugares del código:

1. **Mostrar el path actual** en cyan (`Write-Host "ruta" -ForegroundColor Cyan`)
2. **Listar el contenido** con `eza` (o `Get-ChildItem` como fallback)
3. **Detectar si es un repo git** → sugiere herramientas a usar

### Salida típica en un repo git

```
~/dev/mi-proyecto
src/  docs/  tests/  package.json  ...
  Consider using: yazi, broot, nvim, lazygit, code .
```

### Puntos de invocación (el único punto de salida de cdx)

- `cdx <ruta>` → `Set-Location` → `ShowResult`
- `cdx <query>` (zoxide hit) → `Set-Location` → `ShowResult`
- `cdx ~` / `cdx ...` → `Set-Location $HOME` → `ShowResult`
- TUI: Ctrl+C → `ShowResult`
- TUI: Esc en raíz → `ShowResult`
- TUI: resultados vacíos → `ShowResult`

### Implementación

```powershell
function ShowResult {
    $path = (Get-Location).Path
    $display = if ($path.StartsWith($env:USERPROFILE)) {
        "~" + $path.Substring($env:USERPROFILE.Length).Replace('\', '/')
    } else {
        $path.Replace('\', '/')
    }
    Write-Host "`n$display" -ForegroundColor Cyan
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        eza --icons --group-directories-first
    } else {
        Get-ChildItem -Force | Format-Table
    }
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitRoot = git rev-parse --show-toplevel 2>$null
        if ($gitRoot) {
            Write-Host "  Consider using: yazi, broot, nvim, lazygit, code ." -ForegroundColor DarkGray
        }
    }
}

La detección del repo usa `git rev-parse --show-toplevel`. Si no hay git instalado, no se muestra el hint.

## Infraestructura de Archivos Temporales

La TUI usa **5 archivos temporales** en `$env:TEMP` para comunicación entre procesos:

| Archivo | Propósito | Contenido |
|---------|-----------|-----------|
| `cdx_state.txt` | Estado de 3 bits | Entero (0-7) |
| `cdx_reload.ps1` | Script de reload (alternar modos) | Código PowerShell generado |
| `cdx_preview.ps1` | Script de preview (modo Find) | Código PowerShell fijo |
| `cdx_zoxide_cache.txt` | Cache de zoxide para procesos hijos | Lista de paths absolutos |

### Ciclo de Vida

- Todos los archivos se crean al inicio de la TUI.
- `cdx_state.txt` y `cdx_zoxide_cache.txt` se escriben una vez al inicio.
- `cdx_state.txt` se modifica desde el reload script y se lee en cada iteración del loop.
- `cdx_reload.ps1` se genera al inicio y se ejecuta como proceso hijo desde fzf.
- `cdx_preview.ps1` se genera al inicio y se ejecuta como preview de fzf.

### Por qué archivos temporales y no variables

El proceso padre (TUI loop) y los procesos hijos (reload, preview, fzf) no comparten el mismo scope de PowerShell. Los archivos temporales son el único canal de comunicación confiable entre procesos independientes. Las variables de entorno (`CDX_CURRENT_PATH`, `CDX_PREVIEW_BASE`) complementan para datos que deben propagarse a hijos pero no necesitan persistir entre iteraciones.

## Script de Reload — Generación Dinámica de Código

El script de reload (`TEMP\cdx_reload.ps1`) es **generado dinámicamente** al inicio de la TUI y se regenera en cada invocación de `cdx`.

### Contenido

Es un script PowerShell que:
1. Recibe un parámetro `ToggleBit` (1, 2 o 4).
2. Lee el estado actual del archivo.
3. Aplica XOR con el bit correspondiente.
4. Guarda el nuevo estado.
5. Genera la lista de items según el nuevo estado:
   - **Modo Search**: Ejecuta `rg --files` con argumentos construidos dinámicamente.
   - **Modo Find**: Ejecuta `fd --type d` mergeado con zoxide.
6. Imprime los items (incluyendo header), que fzf consume vía `reload(...)`.

### Inyección de Excluidos

Las listas de exclusión se serializan **inline** dentro del script generado. Esto asegura que:
- El reload script funciona como script autónomo (sin dependencias del perfil).
- Los cambios en las listas de exclusión se reflejan al reiniciar cdx (el script se regenera).
- El reload script no necesita leer el perfil ni tener acceso a variables de script.

### Por qué es necesario

fzf permite bindings de teclas con `reload(...)` que reemplaza el input actual. Pero `reload` ejecuta un comando externo — no puede invocar funciones de PowerShell directamente. El script de reload es el puente entre fzf y la lógica de PowerShell.

## Sistema de Exclusión (3 Categorías)

Tres listas con diferentes propósitos y mecanismos:

### 1. ExcludeDirs (nombres de directorio cortos)

Directorios comunes como `node_modules`, `.git`, `vendor`, etc. Se aplican:
- En fd: `--exclude <dir>`
- En rg: `--glob !<dir>`
- En merge de zoxide: filtrado por segmentos
- En Get-ChildItem de roots: no se aplica (se usa -Exclude limitado)

### 2. ExcludeWinDirs (directorios del sistema Windows)

Directorios del perfil de usuario como `AppData`, `ProgramData`. Tienen su propio toggle (Ctrl+W) y bit de estado. Se aplican:
- Condicionalmente, solo cuando el bit 2 = 0 (WinHidden activo = ocultos).
- Mismo mecanismo que ExcludeDirs.

### 3. ExcludePathGlobs (patrones de ruta completa)

Actualmente solo `**/go/pkg/mod`. Se aplican con `--glob !**/go/pkg/mod` en fd y rg. En el merge de zoxide, se verifica con regex `(^|/)go/pkg/mod($|/)`.

### Resumen de aplicación

| Categoría | fd | rg | Zoxide merge | Roots (Get-ChildItem) |
|-----------|----|----|-------------|----------------------|
| ExcludeDirs | `--exclude` | `--glob !` | Filtro segmentos | - |
| ExcludeWinDirs | `--exclude` (toggle) | `--glob !` (toggle) | No aplica | `-Exclude` |
| ExcludePathGlobs | `--exclude` | `--glob !` | Regex check | - |

## Diagrama de Flujo de la TUI

```
Invoke-CdxTui
│
├─► Cache zoxide (una vez)
│
├─► Inicializar archivos temporales
│   ├── cdx_state.txt = 2
│   ├── cdx_esc.txt = 0
│   ├── cdx_zoxide_cache.txt = zoxide list
│   └── Generar cdx_reload.ps1
│
└─► LOOP PRINCIPAL (while true)
    │
    ├─► Leer estado de cdx_state.txt
    │
    ├─► ¿Modo Search (rg)?
    │   ├─► Sí: rg --files → items
    │   └─► No: fd --type d + merge zoxide → items
    │
    ├─► ¿Items vacíos? → ShowResult, return
    │
    ├─► Construir fzfArgs
    │   ├── header (atajos)
    │   ├── header-lines 1
    │   ├── preview (bat o preview script)
    │   └── binds (ctrl+g/a/w/h)
    │
    ├─► Ejecutar fzf con items
    │
    ├─► GESTIONAR RESULTADO
    │   ├── (empty) →
    │   │     con padre → cd .. → continue
    │   │     en raíz  → ShowResult, return
    │   ├── (selected) →
    │   │     __GOTO_HOME__ → cd ~ → continue
    │   │     __EXIT_CDX__ → ShowResult, return
    │   │     Modo Search → bat archivo → continue
    │   │     Modo Find → cd directorio → continue
    │
    └─► Repetir loop
```

## Edge Cases y Gotchas

### Procesos Hijos y Scope

- **El reload script** no tiene acceso a variables de script del perfil (ni siquiera variables globales de PowerShell). Toda la comunicación es mediante archivos temporales y variables de entorno.
- **El preview script** en modo Find es un proceso PowerShell completo que se ejecuta por cada cambio de selección en fzf. Es costoso pero necesario porque la preview requiere lógica condicional (eza vs Get-ChildItem, git status).

### Race Conditions

- **Estado del archivo:** El archivo de estado se lee y escribe desde dos procesos (loop padre y reload hijo). En teoría podría haber una race condition si el usuario presiona Ctrl+G/Ctrl+A/CtrlW extremadamente rápido. En la práctica, el tiempo de respuesta de fzf + PowerShell hace que sea improbable.

### Comportamiento de fzf

- `--header-lines 1` trata la primera línea del input como header (no seleccionable, pero visible en el preview). Esto permite que la línea de estado aparezca en la preview.
- `reload(...)` en fzf reemplaza el contenido del input. El script de reload debe imprimir los items (incluyendo la línea de header) a stdout.
- `become(...)` reemplaza el proceso actual de fzf con otro comando. Ctrl+H usa `become(echo __GOTO_HOME__)`, Ctrl+C usa `become(echo __EXIT_CDX__)`, y Ctrl+O usa `become(echo __CD_YAZI__{})` para simular items especiales. El loop padre reconoce estos strings y ejecuta la acción correspondiente. En el caso de `__CD_YAZI__`, el path se extrae del prefijo y se lanza `yazi` tras hacer `cd`.

### Modo Search en Root Drives

En modo Search en una raíz como `C:\`, `rg --files C:\` es extremadamente lento porque escanea todo el disco. No hay protección contra esto (es un bug conocido).

### Dependencia de Orden en Paths

El merge de zoxide depende de que los paths usen `\` como separador para `StartsWith` y `TrimStart`. Todo path se normaliza con `.Replace('\', '/')` para display, pero las comparaciones internas usan el path crudo de PowerShell (con `\`).

### Encoding

Se fuerza `[Console]::OutputEncoding = UTF8` para asegurar que caracteres como `★` y `✓`/`✗` se muestren correctamente en la consola.
