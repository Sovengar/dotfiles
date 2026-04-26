---
description: >
  Explica una PR en profundidad: por qué existe, qué problema resuelve,
  cómo funciona la implementación y qué decisiones técnicas se tomaron.
  Sin veredicto, foco en comprensión.
agent: general
skills: git-pr
---

## Cuándo Usar

- Cuando quieres entender el razonamiento detrás de un PR, no solo qué cambia
- Cuando el PR toca una parte del sistema que no conoces bien
- Para onboardear a alguien a los cambios con contexto técnico real
- Para revisar el contexto de un PR antes de hacer merge

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

### Paso 3: Construir la explicación

Responder en orden:

**¿Por qué existe este PR?**
[Problema o necesidad que originó el cambio, basado en body + título]

**¿Qué cambia exactamente?**
[Descripción técnica de los cambios principales — no un listado de archivos, sino qué comportamiento nuevo introduce]

**¿Cómo está implementado?**
[Recorrido por las decisiones técnicas: patrones usados, flujo de datos, puntos de integración]

**¿Qué asumir para leerlo?**
[Contexto necesario: módulos involucrados, convenciones del proyecto, dependencias relevantes]

---

### Paso 4: Análisis del explorer

- **Archivos modificados**: lista con líneas añadidas/eliminadas
- **Patrones detectados**: qué cambios hay (nuevo archivo, refactor, fix)
- **Contexto arquitectónico**: cómo se integra con el diseño del proyecto
- **Calidad del código**: observación de patrones (aplicando design-clean-code)

### Paso 5: Mostrar resumen estructurado

**Título:** [título del PR]
**Autor:** @usuario
**Estado:** open/merged/closed
**Rama:** feature → main
**Commits:** N commits
**Archivos:** N archivos cambiados
**Observaciones:** Las observaciones obtenidas del paso 3 y 4.

---

## Notas

- Este comando **no evalúa** si el PR está bien o mal hecho
- El tono es pedagógico: quien lee debería poder entender el PR sin abrirlo
- Si el diff es muy grande, pedir al usuario un área de foco antes de explicar
- Para evaluación usar `review-pr`; para descomposición estructurada usar `analyze-pr`
- Requiere **gh CLI** instalado y autenticado
- Si no hay gh disponible → intentar parsing de URL web
- El agente explorer añade análisis de arquitectura y calidad usando sus skills
- Este comando puede ejecutarse en cualquier repositorio (local o foráneo)