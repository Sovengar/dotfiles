# Custom Sync

Sincroniza `.agents` al repo de sync.

## Usage

Este script sincroniza la carpeta `.agents` al repo de opencode-synced.

## Solución

El plugin `custom-sync` debería ejecutarse al iniciar opencode. Verifica:
1. Está en el array `plugin` de `opencode.jsonc`
2. Tiene `package.json` con `main` apunta al archivo correcto

La configuración actual está en `opencode.jsonc`:
```json
"plugin": [
  ...
  "C:\\Users\\buble\\.config\\opencode\\plugins\\custom-sync"
]
```

Reinicia opencode para que se ejecute el plugin.

## Archivos creados

- `plugins/custom-sync/custom-sync.ts` - Plugin principal
- `plugins/custom-sync/package.json` - Configuración npm
- `scripts/manual-sync-agents.ts` - Script manual de respaldo