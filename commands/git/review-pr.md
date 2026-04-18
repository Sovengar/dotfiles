---
name: review-pr
description: >
  Revisa un Pull Request usando contexto del PR + skill code-review.
  Obtiene metadata, archivos, diff resumido y checks antes de lanzar la revisión adversarial.
agent: general
skills: git-pr, code-review
triggers: [review-pr, revisar pr, revisar pull request, review pull request, auditar pr, code review pr]
---

## Cuándo Usar

- Cuando querés revisar un PR antes de merge
- Cuando necesitás contexto técnico + revisión adversarial
- Cuando el usuario pasa una URL de GitHub, un número de PR o quiere revisar el PR actual

## Flujo de Ejecución

### Paso 1: Resolver el PR objetivo

El usuario puede proporcionar:
- URL del PR (`https://github.com/owner/repo/pull/123`)
- Número del PR (`123`) si estamos en el repo correcto
- O usar el PR actual si hay uno asociado a la rama activa

### Paso 2: Obtener contexto del PR

Usar `gh` para recolectar contexto estructurado:

```bash
# Metadata del PR
gh pr view {PR} --json title,author,body,state,headRefName,baseRefName,commits,files

# Diff resumido
gh pr diff {PR} --stat

# Estado de checks
gh pr checks {PR}
```

### Paso 3: Resumir alcance antes del review

Mostrar al usuario:

**Título:** [título del PR]
**Autor:** @usuario
**Estado:** open/merged/closed
**Rama:** feature → main
**Commits:** N commits
**Archivos:** N archivos cambiados

Además:
- Lista de archivos modificados
- Resumen de líneas añadidas/eliminadas
- Estado de checks
- Riesgos visibles o áreas de atención si corresponden

### Paso 4: Confirmar scope del juicio

Antes de invocar la skill `code-review`, confirmar:
- si se revisa **todo el PR**
- o si se limita a ciertos archivos/componentes dentro del PR

> La skill `code-review` requiere un target claro. Si el scope no está claro, hay que preguntarlo antes de lanzar jueces.

### Paso 5: Invocar skill `code-review`

Una vez confirmado el scope:
- ejecutar la skill `code-review`
- usar como target los archivos del PR o el subconjunto confirmado
- incluir el contexto del PR en el prompt de revisión

La skill manejará:
- Skill Resolution
- Judge A + Judge B en paralelo
- síntesis de findings
- fix + re-judge si aplica
- estado final APPROVED o ESCALATED

---

## Notas

- Este comando es un **wrapper**: primero prepara contexto del PR, después delega el review a `code-review`
- `explain-pr.md` aporta el patrón de inspección con `gh`
- `code-review` aporta el protocolo adversarial completo
- Si no hay `gh` disponible, intentar resolver desde URL web o pedir más contexto al usuario
- Si el PR es muy grande, conviene proponer revisión por scope para evitar un juicio difuso