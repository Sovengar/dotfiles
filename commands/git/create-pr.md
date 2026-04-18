---
description: Creates a PR of the current branch
agent: general
model: opencode/minimax-m2.5-free
subtask: true
skills: git-pr
---

## Flujo de Ejecución

Invocar la skill git-pr

---

## Notas

- Este comando es un **wrapper** — solo prepara el staging y luego invoca la skill
- La skill `git-pr` maneja todo el trabajo.