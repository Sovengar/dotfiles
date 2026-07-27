---
description: "Close SWE workflow - genera summary, renombra spec, actualiza changelog, persiste engram, push"
agent: general
subtask: true
skills: docs-guidelines, docs-changelog
---

## Input Esperado

- **slug**: Nombre del feature
- **NNNN**: Número secuencial del plan (e.g., 0001)
- **type**: Tipo de cambio (feature, fix, refactor, chore, docs)
- **branch**: Nombre de la branch (ej: feat/<feature-name>)
- **commits**: git log --oneline de la branch
- **approved_points**: Si el usuario aprobó continuar

## Directory Structure

| State | Path | Example |
|-------|------|--------|
| Active | `docs/planning/{NNNN}-{type}-{slug}/` | `docs/planning/0001-feature-dark-mode/` |
| Completed | `docs/planning/{YYYY-MM-DD}-{type}-{slug}/` | `docs/planning/2025-04-21-feature-dark-mode/` |

## Flujo de Ejecución

### Paso 1: Verificar Branch

```bash
git branch --show-current
```

Validar que estamos en `feat/<feature-name>`.

### Paso 2: Generar Summary Estructurado

Crear `docs/planning/{NNNN}-{type}-{slug}/summary.md` con el formato:

```markdown
# Summary: {slug}

## Metadata
- **Completed:** YYYY-MM-DD HH:MM
- **Duration:** X minutes
- **Plan Number:** {NNNN}

## Tasks
| # | Status |
|---|---------|
| 1 | ✅ Completed |
| 2 | ✅ Completed |
| 3 | ✅ Completed |

## Commits
- feat(<scope>): <mensaje>

## Files
- Created: [lista]
- Modified: [lista]

## Tests
- Added: N
- System Tests: ✅ Passed / ❌ Failed

## Documentation
- Changelog: ✅ Updated
- Docs: [lista]
- ADR: ✅ Created / No required

## Code Review Issues
- Critical Found: N
- High Found: N
- User Decision: Approved to continue / Asked to fix

## Next Step
[Descripción]
```

### Paso 3: Renombrar Directorio con Fecha

```bash
Move-Item "docs/planning/{NNNN}-{type}-{slug}" "docs/planning/{YYYY-MM-DD}-{type}-{slug}"
```

No borrar tasks ni prd.

### Paso 4: Actualizar Changelog

Utiliza la skill `docs-changelog` para crear o actualizar el `CHANGELOG.md`

### Paso 5: Persistir en Engram

```json
{
  "title": "Close: {slug}",
  "type": "close",
  "content": "**What**: Workflow cerrado - summary generado, directorio renombrado con fecha, changelog actualizado\n**Where**: docs/planning/{YYYY-MM-DD}-{type}-{slug}/summary.md, CHANGELOG.md\n**Learned**: N/A"
}
```

- topic_key: `swe/{project}/{slug}/close`

### Paso 6: Git Push

```bash
git push
```

---

## Result Contract

```json
{
  "status": "success | partial",
  "executive_summary": "1-3 oraciones de qué se hizo",
  "artifacts": ["lista de archivos creados/modificados"],
  "next_recommended": "git push completado",
  "risks": "None | descripción de riesgos"
}
```

---

## Errores

| Código | Descripción |
|--------|-------------|
| SUMMARY_GENERATION_FAILED | No se pudo generar el summary |
| CHANGELOG_UPDATE_FAILED | No se pudo actualizar el changelog |
| DIRECTORY_RENAME_FAILED | No se pudo renombrar el directorio |
| GIT_PUSH_FAILED | No se pudo hacer git push |

---

## Ejemplo de Output

```
✅ Summary generado: docs/planning/0001-feature-dark-mode/summary.md
✅ Directorio renombrado: 0001 → 2025-04-21
✅ Changelog actualizado
✅ Persistido en Engram
✅ Git push completado
Status: success
```