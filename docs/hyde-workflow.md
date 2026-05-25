# Flujo de Trabajo HyDE ↔ Hyprland — Resumen de Alto Nivel

## Arquitectura en 3 Capas

```
┌─────────────────────────────────────────────────────────────────────┐
│  ~/.config/          ← Configuración del usuario (punto de entrada) │
│  hypr/, kitty/, rofi/, dunst/, gtk-3.0/, waybar/                    │
├─────────────────────────────────────────────────────────────────────┤
│  ~/.local/share/hyde/ ← Plantillas estáticas (dcol, t2) + recursos │
│  wallbash/, env-theme, theme-env, emoji.db, glyph.db               │
│  ~/.local/share/waybar/ ← Módulos y estilos estáticos de waybar    │
│    modules/*.jsonc, styles/defaults.css, layouts/hyprdots/         │
├─────────────────────────────────────────────────────────────────────┤
│  ~/.local/state/hypr/   ← Estado dinámico Hyprland (NO editar)     │
│  colors.conf, wallbash.conf, animations.theme.conf, etc.           │
│  ~/.local/state/waybar/ ← Estado dinámico Waybar (NO editar)       │
│  generated/{config.jsonc, style.css, theme.css, includes/}         │
│  staterc (layout/style/scale vars)                                 │
└─────────────────────────────────────────────────────────────────────┘
        Motor: ~/.local/lib/hyde/ (API Lua + scripts shell)
```

---

## 1. Punto de Entrada: `hyprland.lua`

`~/.config/hypr/hyprland.lua` es el archivo principal que Hyprland carga. Carga módulos en orden estricto:

1. **Base HyDE**: `primary_apps` → `variables` → `env` → `hardware/*` → `style.opacity` → `layout` → `misc` → `gestures` → `startup`
2. **Estilo dinámico**: `style.theme` ← lee estado generado en `~/.local/state/hypr/`
3. **Animaciones/Shaders**: `style.animations` ← lee `animations.theme.conf` del state
4. **Workflows**: `selected_workflow_loader` ← lee `HYPR_WORKFLOW` del `staterc`
5. **Keybindings**: `keybindings`

Los módulos Lua usan `~/.local/lib/?.lua` como path, ahí vive la **API de HyDE** (`hl.config()`, `hl.on()`, `hl.exec_cmd()`, `hl.curve()`, `hl.animation()`).

---

## 2. Estado Dinámico: `~/.local/state/hypr/`

Archivos **autogenerados**, NO editar manualmente (se sobreescriben en cada `hyprctl reload`):

| Archivo | Contenido | Quién lo genera |
|---|---|---|
| `staterc` | Variables de estado: `HYDE_THEME`, `HYPR_ANIMATION`, `HYPR_WORKFLOW`, `HYPRLOCK_LAYOUT`, `HYPR_SHADER` | HyDE theme switcher |
| `colors.conf` | 4 grupos de colores wallbash (`$wallbash_pry1`..`$wallbash_4xa9`) en hex + rgba | wallbash |
| `wallbash.conf` | Variables Hyprlang derivadas del theme (`$HYDE_THEME`, `$GTK_THEME`, `$ICON_THEME`, etc.) | wallbash |
| `hyprland.theme.lua` | Tabla Lua con gaps, borders, blur, rounding, colores activo/inactivo | theme.switch.sh |
| `animations.theme.conf` | Bloques de animación Hyprlang (bezier curves + animation rules) | wallbash desde `.dcol` |
| `waybar.theme.conf` | `rounding = 10` (legacy, usado por Hyprland) | theme.switch.sh |
| `shaders.conf` | Shader activo (`$SCREEN_SHADER`) y ruta al `.frag` compilado | shaders.sh |
| `hyprlock` | Path al layout de hyprlock activo | hyprlock.sh |
| `hyprsunset` | Config de temperatura de pantalla | hyprsunset |
| `metadata.conf` | Snapshot legible del theme actual (fuentes, iconos, cursor, etc.) | metadata_generator.lua |

### 2b. Estado Dinámico Waybar: `~/.local/state/waybar/`

Archivos **autogenerados**, NO editar manualmente (se sobreescriben en cada cambio de layout/theme):

| Archivo | Contenido | Quién lo genera |
|---|---|---|
| `staterc` | Variables: `WAYBAR_LAYOUT_PATH`, `WAYBAR_LAYOUT_NAME`, `WAYBAR_STYLE_PATH`, `WAYBAR_SCALE` | waybar layout switcher |
| `generated/config.jsonc` | Config JSON completa de waybar (módulos, grupos, layout) | theme.switch.sh |
| `generated/style.css` | CSS maestro: importa defaults, border-radius, wallbash colors, theme, user overrides | theme.switch.sh |
| `generated/theme.css` | Colores del theme activo (`bar-bg`, `main-bg`, `main-fg`, `wb-act-bg/fg`, `wb-hvr-bg/fg`) | wallbash via `waybar.dcol` |
| `generated/includes/includes.json` | Lista de módulos disponibles + overrides de tamaño de iconos | theme.switch.sh |
| `generated/includes/border-radius.css` | Border-radius dinámico por forma (leaf, pill) sincronizado con Hyprland rounding | theme.switch.sh |
| `generated/includes/global.css` | `font-family`, `font-size`, `border-radius` base | theme.switch.sh |

**Jerarquía de carga CSS en waybar** (orden de `style.css`):
1. `~/.local/share/waybar/styles/defaults.css` — estilos base estáticos
2. `includes/border-radius.css` — rounding dinámico por forma
3. `includes/global.css` — fuentes y tamaño base
4. `~/.cache/hyde/wallbash/gtk.css` — colores wallbash (@define-color)
5. `theme.css` — colores del theme activo (sobreescribe wallbash)
6. `~/.config/waybar/user-style.css` — overrides del usuario (vacío por defecto)

**Layouts**: Los layouts JSON viven en `~/.config/waybar/layouts/` (usuario) y `~/.local/share/waybar/layouts/hyprdots/` (estáticos). El staterc apunta al layout activo. Backups en `layouts/backup/`.

---

## 3. Plantillas Estáticas: `~/.local/share/hyde/wallbash/`

Esta es la única fuente canónica de plantillas Wallbash. Los templates antiguos de `~/.config/hyde/wallbash` fueron migrados aquí para evitar capas duplicadas.

Contiene **plantillas** con placeholders `<wallbash_*>` que wallbash rellena con los colores del wallpaper/theme activo. Dos categorías:

### 3.1 `always/` — Se aplican SIEMPRE, independientemente del theme

| Plantilla | Salida | Formato |
|---|---|---|
| `hyprcolors.dcol` | `colors.conf` en state | Hyprlang (`$var = value`) |
| `code.dcol` | `~/.cache/hyde/wallbash/code.json` | JSON (VSCode theme) |
| `gtk-css.dcol` | `~/.cache/hyde/wallbash/gtk.css` | CSS (`@define-color`) |
| `scss.dcol` | `~/.cache/hyde/wallbash/colors.scss` | SCSS variables |
| `shell-colors.dcol` | `~/.cache/hyde/wallbash/shell-colors` | Shell vars |
| `pywal-colors.Xcol` | `~/.cache/wal/colors` | pywal format (16 colores) |
| `qtct.dcol` | `~/.cache/hyde/wallbash/qtct.conf` | Qt config |
| `dunst.dcol` | `~/.cache/hyde/wallbash/dunst.conf` | dunst config |
| `hyprshaders.dcol` | `~/.cache/hyde/wallbash/colors.inc` | GLSL `#define` |
| `hyprlock_background.dcol` | Genera fondo de hyprlock | — |
| `rasi.dcol` | Config rofi (estilos CSS) | rasi |
| `cava.dcol` | Sección Wallbash en `~/.config/cava/config` | cava config |
| `chrome.dcol` | Tema Chrome/Chromium en cache | Chrome theme |
| `discord.dcol` | CSS para clientes Discord compatibles | CSS |
| `spotify.dcol` | `~/.cache/hyde/wallbash/spotify-color.ini`, copied by `spotify.sh` into Spicetify Sleek | ini |
| `vim.dcol` | `~/.config/vim/colors/wallbash.vim` | Vim colorscheme |
| `00-icons/*.dcol` | Iconos SVG con colores wallbash | SVG |
| `00-palette/*.t2` | Paleta visual SVG | SVG |

### 3.2 `theme/` — Se aplican según el THEME activo (Rosé Pine en este caso)

| Plantilla | Salida | Formato |
|---|---|---|
| `hypr.dcol` | `~/.cache/hyde/wallbash/hypr.themes` | Hyprlang theme |
| `kitty.dcol` | `~/.config/kitty/autogenerated_theme.conf` | kitty conf |
| `rofi.dcol` | `~/.config/rofi/theme.rasi` | rasi |
| `swaync.dcol` | `~/.config/swaync/theme.css` | CSS |
| `animations.dcol` | `animations.theme.conf` en state | Hyprlang |
| `hyprlock.dcol` | Config de lock screen | Hyprlang |
| `waybar.dcol` | Estilos waybar | CSS |
| `gtk/` (gtk2/3/4 `.dcol`) | Themes GTK | CSS |

**Formato `.dcol`**: Línea 1 = ruta de destino (opcionalmente con pipe a script post-procesador). El resto = contenido con placeholders `<wallbash_*>`.

**Formato `.Xcol`**: Como `.dcol` pero para pywal-compat (salida a `~/.cache/wal/`).

**Formato `.t2`**: Como `.dcol` pero para archivos binarios/estructurados (SVG).

---

## 4. Sistema de Colores Wallbash

### Paleta de 4 Grupos

Wallbash extrae **4 colores primarios** del wallpaper, cada uno con:
- **pry** (primary): color base del grupo
- **txt** (text): color de texto sobre ese primary
- **xa1..xa9** (accent 1-9): 9 tonos de accent desde oscuro → claro

```
Grupo 1: wallbash_pry1, wallbash_txt1, wallbash_1xa1..1xa9  (fondo principal)
Grupo 2: wallbash_pry2, wallbash_txt2, wallbash_2xa1..2xa9  (accent secundario)
Grupo 3: wallbash_pry3, wallbash_txt3, wallbash_3xa1..3xa9  (highlight)
Grupo 4: wallbash_pry4, wallbash_txt4, wallbash_4xa1..4xa9  (contraste/emphasis)
```

### Flujo de generación

```
Wallpaper (imagen)
       │
       ▼
  wallbash (API en ~/.local/lib/hyde/)
       │  Extrae 4 colores dominantes → genera paleta 4×(1+1+9) = 44 colores
       │  Cada color disponible en: hex, rgba, rgb
       ▼
  Plantillas .dcol/.Xcol/.t2 en ~/.local/share/hyde/wallbash/
       │  <wallbash_pry1> → 292749    (reemplazo en tiempo real)
       ▼
  Archivos finales en ~/.local/state/hypr/ y ~/.cache/hyde/wallbash/
       │
       ▼
  Apps consumen estos archivos
```

### Modos wallbash

El campo `HYPR_ANIMATION` en `staterc` indica el modo actual (`theme`), que determina si se usan las plantillas `always/`, `theme/`, o ambas.

---

## 5. Cómo se Aplica el Theme a Cada App

### Hyprland (compositor)
- `hyprland.lua` → carga `style/theme.lua` → lee `hyprland.theme.lua` del state → aplica gaps, borders, blur, colores de borde activo/inactivo
- `colors.conf` se sourcea como variables Hyprlang (`$wallbash_pry1`, etc.)
- Shaders: `shaders.conf` → compila `.frag` a cache → `decoration.screen_shader`

### Kitty (terminal)
- Plantilla `kitty.dcol` → genera `~/.config/kitty/autogenerated_theme.conf`
- `defaults_from_hyde.conf` hace `include autogenerated_theme.conf`
- Colores: foreground, background, cursor, 16 colores ANSI, tabs

### VSCode / Code Editors
- Plantilla `code.dcol` → genera `~/.cache/hyde/wallbash/code.json`
- JSON completo con ~530 propiedades de color (editor, sidebar, terminal, etc.)
- `$CODE_THEME=Wallbash` en `wallbash.conf` indica que se usa el theme autogenerado

### GTK (apps nativas: Dolphin, Nautilus, etc.)
- Plantillas `gtk/gtk2.dcol`, `gtk3.dcol`, `gtk4.dcol` → themes GTK
- `gtk-css.dcol` → `~/.cache/hyde/wallbash/gtk.css` con `@define-color` wallbash
- `settings.ini` → `gtk-theme-name=Rose-Pine`, `gtk-icon-theme-name=Tela-circle-pink`
- Variables env: `GTK_THEME=Wallbash-Gtk`

### Waybar (barra) — dos capas de estado dinámico
- **Estado Hyprland** (`~/.local/state/hypr/waybar.theme.conf`): rounding value legacy (leído por Hyprland)
- **Estado Waybar** (`~/.local/state/waybar/`): toda la config dinámica de waybar
  - `staterc`: `WAYBAR_LAYOUT_PATH`, `WAYBAR_LAYOUT_NAME`, `WAYBAR_STYLE_PATH`, `WAYBAR_SCALE`
  - `generated/config.jsonc`: layout de módulos, grupos, posiciones
  - `generated/style.css`: CSS maestro que importa en cascada:
    1. `defaults.css` (estáticos)
    2. `border-radius.css` (sync con Hyprland rounding)
    3. `global.css` (fuentes/tamaño)
    4. `gtk.css` wallbash (@define-color)
    5. `theme.css` (colores del theme activo)
    6. `user-style.css` (overrides del usuario)
  - `generated/theme.css`: colores concretos (`bar-bg`, `main-bg/fg`, `wb-act-*`, `wb-hvr-*`)
  - `generated/includes/`: módulos disponibles + icon-size overrides
- Plantilla `waybar.dcol` → genera los CSS con colores wallbash
- Layouts: `~/.config/waybar/layouts/` (usuario) + `~/.local/share/waybar/layouts/hyprdots/` (estáticos)
- `user-style.css` → overrides del usuario (vacío por defecto)

### Rofi (launcher)
- Plantilla `rofi.dcol` → `~/.config/rofi/theme.rasi`
- Variables: `main-bg`, `main-fg`, `main-br`, `main-ex`, `select-bg`, `select-fg`

### Dunst (notificaciones)
- Plantilla `dunst.dcol` → `~/.cache/hyde/wallbash/dunst.conf`
- Script post-procesador: `dunst.sh` copia y recarga dunst
- Colores para urgencia low/normal/critical

### SwayNC (centro de notificaciones)
- Plantilla `swaync.dcol` → `~/.config/swaync/theme.css`
- Importa `gtk.css` wallbash + define colores CSS propios

### Hyprlock (lock screen)
- Plantilla `hyprlock.dcol` → config de lock screen
- `hyprlock_background.dcol` → genera imagen de fondo
- Layout seleccionado via `HYPRLOCK_LAYOUT` en `staterc` (ej: "SF Pro")

### Qt Apps (Dolphin, etc.)
- Plantilla `qtct.dcol` → `~/.cache/hyde/wallbash/qtct.conf`
- Script post-procesador: `qtct.sh` aplica colores Qt

### Kvantum (Qt theming engine)
- Plantillas `kvantum/kvantum.dcol` + `kvantum/kvconfig.dcol` → theme SVG

### Shell / Scripts
- `shell-colors.dcol` → variables de shell para uso en scripts
- `pywal-colors.Xcol` → formato pywal (`~/.cache/wal/colors`) para compatibilidad

### Shaders GLSL
- `hyprshaders.dcol` → `#define` en GLSL para uso en fragment shaders
- Shaders en `~/.local/share/hypr/shaders/*.frag` (ej: `vibrance.frag`)
- Compilados a `~/.cache/hypr/shaders/.compiled.cache.glsl`

---

## 6. Flujo de Arranque

### 6.1 UWSM (bootstrap)

[UWSM](https://github.com/Vladimir-csp/uwsm) arranca Hyprland como unidad systemd user, antes de que `hyprland.lua` se ejecute:

```
login → PAM → uwsm sets env → shell init (sobreescrito por uwsm) → hyprland starts
```

Implicaciones:
- Variables de entorno las fija UWSM (PAM → systemd), no el shell init. Por eso `env_if_unset()` en `hyde/env.lua` puede recibir valores ya bloqueados.
- Servicios de `startup.lua` usan systemd scopes con `Wants=uwsm-mainston.service` implícito para orden de arranque.
- `dbus-update-activation-environment` en startup.lua es parcialmente redundante bajo UWSM (pero inofensivo).

### 6.2 Secuencia de arranque

```
1. UWSM arranca Hyprland (systemd user unit)
2. Hyprland carga hyprland.lua
3. Lua carga módulos base (variables, env, hardware, etc.)
4. Lua carga estilo desde ~/.local/state/hypr/ (autogenerado)
5. startup.lua ejecuta servicios systemd:
   - waybar, dunst, hypridle, hyprsunset, clipboard, wallpaper
   - polkit, nm-applet, blueman, udiskie, batterynotify
6. hypr.scripts.wallbash_metadata_loader genera metadata.conf
7. Al cambiar wallpaper/theme:
   a. wallbash extrae colores del wallpaper
   b. Genera paleta 4×(1+1+9) = 44 colores
   c. Rellena plantillas .dcol/.Xcol/.t2 → archivos finales
   d. Scripts post-procesadores (dunst.sh, qtct.sh, reload_kitty.sh) recargan apps
   e. hyprctl reload aplica cambios en Hyprland
8. staterc persiste: HYDE_THEME, HYPR_ANIMATION, HYPR_WORKFLOW, etc.
```

---

## 7. Workflows

Los workflows viven en `~/.config/hypr/workflows/` y son scripts Lua que pueden sobreescribir configuración:

| Workflow | Propósito |
|---|---|
| `default.lua` | Sin cambios (vacío) |
| `editing.lua` | Optimizado para edición |
| `gaming.lua` | Optimizado para gaming |
| `powersaver.lua` | Ahorro de energía |
| `snappy.lua` | Animaciones rápidas |

El workflow activo se lee de `staterc` → `HYPR_WORKFLOW`.

---

## 8. Resumen de Directorios Clave

| Directorio | Rol |
|---|---|
| `~/.config/hypr/` | Config de entrada Hyprland (Lua) |
| `~/.config/kitty/` | Config kitty (incluye autogenerated_theme.conf) |
| `~/.config/rofi/` | Config rofi (theme.rasi autogenerado) |
| `~/.config/dunst/` | Config dunst (dunstrc autogenerado + dunst.conf manual) |
| `~/.config/gtk-3.0/` | Settings GTK |
| `~/.config/waybar/` | Config waybar (layouts manuales, user-style.css para overrides) |
| `~/.local/share/hyde/` | Plantillas estáticas + recursos (dcol, t2, scripts) |
| `~/.local/share/waybar/` | Módulos estáticos waybar (modules/*.jsonc, styles/defaults.css, layouts/hyprdots/) |
| `~/.local/state/hypr/` | Estado dinámico Hyprland autogenerado (NO editar) |
| `~/.local/state/waybar/` | Estado dinámico Waybar autogenerado: config.jsonc, style.css, theme.css, includes/ (NO editar) |
| `~/.local/lib/hyde/` | API Lua + scripts shell (motor de HyDE) |
| `~/.cache/hyde/wallbash/` | Cache de archivos generados (code.json, gtk.css, etc.) |
| `~/.cache/wal/` | Cache pywal-compat |

---

## 9. Convención de Nombres de Plantillas

- **`.dcol`** = plantilla de color wallbash → línea 1 = ruta destino, resto = contenido con `<wallbash_*>`
- **`.Xcol`** = variante pywal-compat → línea 1 = ruta destino, formato 16 colores
- **`.t2`** = plantilla binaria/estructurada (SVG, etc.) → línea 1 = ruta destino
- Si línea 1 tiene `| script.sh` → se ejecuta el script post-generación (ej: `| dunst.sh`, `| qtct.sh`, `| reload_kitty.sh`)
