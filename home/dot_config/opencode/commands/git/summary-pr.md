---
name: summary-pr
description: >
  Resumen ejecutivo de una PR: qué es, quién lo hizo,
  qué cambia y en qué estado está. Sin juicio, sin profundidad técnica.
agent: general
skills: git-pr
triggers: [summary-pr, resumir pr, resumen pr, summarize pr, qué hace este pr, de qué trata el pr]
---

## Cuándo Usar

- Cuando necesitás entender rápidamente de qué trata un PR sin revisarlo en detalle
- Antes de decidir si vale la pena analizarlo o revisarlo
- Para compartir contexto con alguien que no conoce el PR

## Flujo de Ejecución

### Paso 1: Resolver el PR objetivo

El usuario puede proporcionar:
- URL del PR (`https://github.com/owner/repo/pull/123`)
- Número del PR (`123`) si estamos en el repo correcto
- O el PR actual asociado a la rama activa

### Paso 2: Obtener metadata mínima

```bash
gh pr view {PR} --json title,author,body,state,headRefName,baseRefName,commits,files,additions,deletions
```

### Paso 3: Generar el resumen

Producir un snapshot compacto con este formato:

**Título:** [título]
**Autor:** @usuario · **Estado:** open/merged/closed
**Rama:** `feature` → `main`
**Cambios:** N commits · N archivos · +X / -Y líneas

**Qué hace:**
[2-3 líneas en lenguaje natural describiendo el propósito del PR, extraído del título + body]

**Archivos principales afectados:**
- `ruta/archivo.ext` — [qué tipo de cambio]
- ...

---

## Notas

- Este comando **no emite juicio** ni evalúa calidad
- Si el body del PR está vacío, inferir propósito desde título + archivos cambiados
- Para profundidad técnica usar `explain-pr`, `analyze-pr` o `review-pr`