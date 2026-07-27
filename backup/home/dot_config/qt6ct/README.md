# qt6ct Configuration — Static vs Dynamic

## Archivos

| Archivo | Naturaleza | Ubicación |
|---------|-----------|-----------|
| `qt6ct.conf` | **Estático** (configurado por el usuario via GUI o manual) + 3 claves dinámicas | `~/.config/qt6ct/qt6ct.conf` |
| `colors/wallbash.conf` | **Dinámico** (generado por wallbash en cada cambio de wallpaper) | `~/.local/state/qt6ct/colors/wallbash.conf` |

## Detalle de qt6ct.conf

### 🟢 Estático (configuración del usuario, no se regenera)

- `[Appearance]`: `custom_palette`, `standard_dialogs`, `style`
- `[Interface]`: clicks, scroll, tooltips, shortcuts
- `[Troubleshooting]`: widgets, apps ignoradas
- `[SettingsWindow]`: geometría de ventana

### 🔴 Dinámico (se regenera automáticamente en cada theme switch)

- `[Appearance]` → `icon_theme` — escrito por `theme.switch.sh`
- `[Fonts]` → `general`, `fixed` — escrito por `theme.switch.sh`

## Pipeline de generación del archivo de colores

```
wallpaper change
  → wallbash.sh procesa qtct.dcol (template con placeholders)
  → genera ~/.cache/hyde/wallbash/qtct.conf (colores sustituidos)
  → qtct.sh copia a ~/.local/state/qt6ct/colors/wallbash.conf
  → qtct.sh crea symlink desde ~/.config/qt6ct/colors/wallbash.conf
```

Qt6CT lee `color_scheme_path` de `qt6ct.conf` que apunta a `.config/`,
y el symlink resuelve al archivo real en `.local/state/`.

## Limitación de Qt6CT

Qt6CT **no soporta variables de entorno como `$XDG_STATE_HOME`** ni
directivas `include` en su formato INI.

Por eso:
- **`colors/wallbash.conf`** se externaliza via symlink ✅
  (funciona porque es una referencia indirecta desde `color_scheme_path`)
- **`icon_theme` y `[Fonts]`** no se pueden externalizar ❌
  (son claves inline en `qt6ct.conf` y Qt6CT no soporta includes)

Las 3 claves dinámicas que conviven en `qt6ct.conf` son menores y se
regeneran automáticamente en cada cambio de tema sin pérdida de
información. No hay riesgo.
