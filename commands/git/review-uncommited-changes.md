---
name: review-uncommitted-changes
description: >
  Wrapper para revisar cambios sin commit antes de hacer commit.
  Obtiene el estado del repositorio y ejecuta la skill code-review.
triggers: [review-uncommitted, revisar cambios sin commit, revisar pendientes, revisión antes de commit, revisar lo pendiente, échale un vistazo, revisame, revisar cambios]
---

## Cuándo Usar

- Antes de hacer `git commit`
- Auditoría de cambios pendientes en el repo
- Revisión de código antes de push

## Flujo de Ejecución

### Paso 1: Obtener cambios sin commit

```bash
# Estado general (formato limpio)
git status --porcelain

# Resumen de cambios unstaged
git diff --stat

# Resumen de cambios staged
git diff --cached --stat

# Archivos sin trackear
git ls-files --others --exclude-standard
```

### Paso 2: Mostrar resumen al usuario

**Archivos con cambios:**
- Lista de archivos modificados, staged y untracked

**Resumen de cambios (resumido):**
- Para cada archivo: número de líneas añadidas/eliminadas

### Paso 3: Confirmar alcance

Mostrar al usuario los archivos y preguntar si quiere proceder con el review.

### Paso 4: Invocar skill code-review

Después de confirmar → ejecutar la skill `code-review` con el target (los archivos con cambios).

*(La skill ya tiene toda la lógica interna: Skill Resolution → 2 judges → Verdict → Fix → Re-judge)*

---

## Notas

- Este comando es un **wrapper** — solo prepara contexto antes de invocar la skill
- La skill `code-review` maneja todo el flujo adversarial de revisión
- Si el usuario quiere solo ver qué archivos cambió → usar `git status` directamente
- Los triggers del comando activan este flujo completo