---
description: "Close SWE workflow - genera summary, renombra spec, actualiza changelog, persiste engram, push"
agent: general
subtask: true
skills: docs-guidelines, docs-changelog
---

## Input Esperado

- **slug**: Nombre del feature
- **branch**: Nombre de la branch (ej: feat/<feature-name>)
- **commits**: git log --oneline de la branch
- **approved_points**: Si el usuario aprobó continuar

## Flujo de Ejecución

### Paso 1: Verificar Branch

```bash
git branch --show-current
```

Validar que estamos en `feat/<feature-name>`.

### Paso 2: Generar Summary Estructurado

Crear `.specs/{slug}-summary.md` con el formato:

```markdown
# Summary: {slug}

## Metadata
- **Completed:** YYYY-MM-DD HH:MM
- **Duration:** X minutes
- **Version:** v1

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

### Paso 3: Renombrar Spec a IMPLEMENTED

```bash
Move-Item ".specs/{slug}.md" ".specs/{slug}-IMPLEMENTED.md"
```

No borrar tasks ni prd.

### Paso 4: Actualizar Changelog

Utiliza la skill `docs-changelog` para crear o actualizar el `CHANGELOG.md`

### Paso 5: Persistir en Engram

```json
{
  "title": "Close: {slug}",
  "type": "close",
  "content": "**What**: Workflow cerrado - summary generado, spec renombrado a IMPLEMENTED, changelog actualizado\n**Where**: .specs/{slug}-summary.md, .specs/{slug}-IMPLEMENTED.md, CHANGELOG.md\n**Learned**: N/A"
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
| GIT_PUSH_FAILED | No se pudo hacer git push |

---

## Ejemplo de Output

```
✅ Summary generado: .specs/{slug}-summary.md
✅ Spec renombrado: {slug}-IMPLEMENTED.md
✅ Changelog actualizado
✅ Persistido en Engram
✅ Git push completado
Status: success
```