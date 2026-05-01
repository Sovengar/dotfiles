---
name: analyze-pr
description: >
  Descompone una PR de forma estructurada: qué cambia, impacto real,
  complejidad, dependencias, riesgos detectados y áreas de atención.
  Sin veredicto final, foco en inventario objetivo.
agent: general
skills: git-pr
---

## Cuándo Usar

- Cuando necesitas un mapa técnico del PR antes de tomar decisiones
- Cuando quieres identificar dependencias, riesgos o zonas de complejidad
- Como paso previo a una revisión profunda o a una estimación de riesgo de merge

## Flujo de Ejecución

### Paso 1: Resolver el PR objetivo

El usuario puede proporcionar:
- URL del PR (`https://github.com/owner/repo/pull/123`)
- Número del PR (`123`) si estamos en el repo correcto

### Paso 2: Recolectar datos estructurados

```bash
# Metadata + archivos
gh pr view {PR} --json title,author,body,state,headRefName,baseRefName,commits,files,additions,deletions

# Estadísticas del diff
gh pr diff {PR} --stat

# Estado de checks
gh pr checks {PR}
```

### Paso 3: Producir el análisis

Estructurar en secciones:

**Alcance del cambio**
- Archivos modificados por categoría (lógica, tests, config, docs, infra)
- Volumen: commits, líneas añadidas/eliminadas

**Mapa de impacto**
- Módulos o componentes afectados
- Superficies de integración tocadas (APIs, contratos, DB, eventos)
- Componentes que dependen de lo modificado

**Complejidad**
- Cambios simples vs. cambios con ramificaciones
- Lógica nueva vs. refactor vs. configuración

**Riesgos detectados**
- Zonas del diff de alto riesgo (sin tests, cambios en contratos, lógica crítica)
- Checks fallando o ausentes
- Dependencias externas involucradas

**Checklist de atención**
- [ ] Áreas que requieren revisión adicional
- [ ] Preguntas abiertas sobre el diseño o implementación

---

## Notas

- Este comando **no emite veredicto** — describe, no juzga
- El output es un mapa, no una evaluación de calidad
- Para juicio adversarial usar `review-pr`
- Para entender el razonamiento detrás de los cambios usar `explain-pr`