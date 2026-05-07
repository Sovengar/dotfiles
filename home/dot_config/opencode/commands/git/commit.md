---
description: Makes a commit with the unstaged and staged files
agent: general
model: opencode-go/deepseek-v4-flash
subtask: true
skills: git-commit
---

## Flujo de Ejecución

### Paso 1: Verificar cambios

```bash
git status --porcelain
git diff --stat
```

Si no hay cambios → informar al usuario y terminar.

### Paso 2: Stagear todos los archivos

```bash
git add -A
```

### Paso 3: Invocar skill git-commit

La skill git-commit maneja:
- Análisis del diff
- Generación de mensaje (conventional commits)
- Ejecución del commit

*(La skill ya tiene toda la lógica interna: análisis → staging → mensaje → commit)*

---

## Notas

- Este comando es un **wrapper** — solo prepara el staging y luego invoca la skill
- La skill `git-commit` maneja todo el flujo de conventional commits
- Si el usuario quiere solo stagear → usar `git add` directamente
- Si el usuario quiere un mensaje específico → puede pasarlo como parámetro