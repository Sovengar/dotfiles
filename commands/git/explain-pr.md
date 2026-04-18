---
description: Explica un Pull Request — su contenido, cambios y contexto arquitectónico.
agent: general
skills: git-pr
---

## Cuándo Usar

- Cuando el usuario quiere entender qué hace un PR
- Para revisar el contexto de un PR antes de hacer merge
- Para entender cambios en un repositorio externo

## Flujo de Ejecución

### Paso 1: Obtener PR

El usuario proporciona:
- URL del PR (https://github.com/owner/repo/pull/123)
- Número del PR (123) — si estamos en el repo
- O usar el PR actual (si hay uno activo)

### Paso 2: Obtener datos con gh (usando skill git-pr)

```bash
# Ver detalles del PR (JSON para parsing)
gh pr view {PR} --json title,author,body,state,headRefName,baseRefName,commits,files

# Ver diff resumido
gh pr diff {PR} --stat

# Ver checks/status del PR
gh pr checks {PR}
```

### Paso 3: Mostrar resumen estructurado

**Título:** [título del PR]
**Autor:** @usuario
**Estado:** open/merged/closed
**Rama:** feature → main
**Commits:** N commits
**Archivos:** N archivos cambiados

### Paso 4: Análisis del explorer

- **Archivos modificados**: lista con líneas añadidas/eliminadas
- **Patrones detectados**: qué cambios hay (nuevo archivo, refactor, fix)
- **Contexto arquitectónico**: cómo se integra con el diseño del proyecto
- **Calidad del código**: observación de patrones (aplicando design-clean-code)

---

## Notas

- Requiere **gh CLI** instalado y autenticado
- El agente explorer añade análisis de arquitectura y calidad usando sus skills
- Si no hay gh disponible → intentar parsing de URL web
- Este comando puede ejecutarse en cualquier repositorio (local o foráneo)