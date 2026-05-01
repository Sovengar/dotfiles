---
name: design-principles
description: >
  Software design principles and patterns.
  Trigger: When making architectural decisions, evaluating dependencies, or applying design patterns.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Design Principles

This skill captures essential design principles for building maintainable software.

## When to Use

- Making architectural decisions
- Evaluating dependencies and coupling
- Deciding where to place code
- Applying design patterns
- Understanding why patterns exist

---

## Conceptos Clave

### Cohesión y Acoplamiento

> *"Todos los principios, patrones y heurísticas son para ofrecer una o ambas opciones, aumentar la cohesión funcional y/o disminuir el acoplamiento."*

**Meta**: Poco acoplamiento + mucha cohesión = sistema flexible, testeable y mantenible.

**Ver más**: [cohesion-coupling.md](references/cohesion-coupling.md)

---

### Gestión del Acoplamiento

> *"The 90% of the work is learning to deal with coupling, not eliminating it."*

El acoplamiento no se elimina, se **gestiona**. La mejor estrategia: Bounded Contexts claros.

**Ver más**: [managing-coupling.md](references/managing-coupling.md)

---

### Cuándo Abstraer

> *"Abstractions consist of adding a level of indirection to define a contract or premise, or a more generic concept. They must be used carefully..."*

**Regla clave**: No abstraer por defecto. Dejar que el código te fuerce a ello.

**Ver más**: [abstraction.md](references/abstraction.md)

---

### DRY - Don't Repeat Yourself

> *"This principle promotes reducing code duplication. Each piece of knowledge must have a unique, unambiguous representation in the system."*

**Warning**: DRY mal aplicado = Frankenstein code. No repetir **conceptos**, no código.

**Ver más**: [managing-duplication-dry.md](references/managing-duplication-dry.md)

---

### Exponer Comportamiento, No Datos

> *"Exposing behaviors is the most essential way to avoid coupling with data and make the system evolvable/changable."*

**Core Principle**: *Encapsulate data and implementation details, expose methods with behavior.*

**Ver más**: [behavior-vs-data.md](references/behavior-vs-data.md)

---

### YAGNI y KISS

- **YAGNI**: No añadir funcionalidad hasta que sea necesaria.
- **KISS**: Mantenerlo simple. Complejidad es el enemigo.

**Ver más**: [yagni-kiss.md](references/yagni-kiss.md)

---

### Extraer Cuando Crece

> *"The intuition asks us to extract and isolate, we must listen to it. Isolation allows us to keep flexibility (optionality) high. The secret is doing it with head."*

Aplicar YAGNI y KISS primero → extraer cuando la complejidad crece y las responsabilidades se aclaran.

**Ver más**: [extract-when-grows.md](references/extract-when-grows.md)

---

## Principles Summary

| Principle | Key Message |
|-----------|-------------|
| **Context Over Rules** | Evaluate based on your specific situation |
| **Controlled Coupling** | It's OK to be coupled if impact is limited |
| **Conway's Law** | Org structure shapes the code |
| **Postel's Law** | Accept flexibly, send conservatively |
| **Triangle of Software** | Balance KISS/YAGNI based on phase |
| **Cohesion & Coupling** | All patterns serve these two goals |

---

## References

Para profundizar en cada tema, consulta los archivos en [references/](references/):

| Reference | Topic |
|-----------|-------|
| [cohesion-coupling.md](references/cohesion-coupling.md) | Fundamentos de cohesión y acoplamiento |
| [managing-coupling.md](references/managing-coupling.md) | Cómo gestionar acoplamiento efectivamente |
| [abstraction.md](references/abstraction.md) | Cuándo y cómo abstraer |
| [managing-duplication-dry.md](references/managing-duplication-dry.md) | DRY aplicado correctamente |
| [properties-of-good-software.md](references/properties-of-good-software.md) | Propiedades de buen software |
| [behavior-vs-data.md](references/behavior-vs-data.md) | Exponer comportamiento vs datos |
| [yagni-kiss.md](references/yagni-kiss.md) | YAGNI y KISS explicados |
| [extract-when-grows.md](references/extract-when-grows.md) | Cuándo extraer código |
| [architecture-laws.md](references/architecture-laws.md) | Leyes de Conway y Postel |

---

## Decision Quick Reference

| Scenario | Decision |
|----------|----------|
| Coupling acceptable? | Si impacto = 1 archivo |
| Create interface? | Si 2+ implementaciones |
| DRY? | Esperar 3 repeticiones |
| Extract? | Cuando crece y responsabilidades claras |
| Expose? | Comportamiento, no datos |

---

## Cómo Consultar Esta Skill

Esta skill está dividida en **references** para no cargar todo el contenido. Según el contexto, consulta el archivo correspondiente:

| Cuando necesitas... | Consulta |
|--------------------|----------|
| Entender cohesión vs acoplamiento | [cohesion-coupling.md](references/cohesion-coupling.md) |
| Decidir si usar una librería externa | [managing-coupling.md](references/managing-coupling.md) |
| Saber si crear una interfaz | [abstraction.md](references/abstraction.md) |
| Aplicar DRY correctamente | [managing-duplication-dry.md](references/managing-duplication-dry.md) |
| Diseñar API o exponer métodos | [behavior-vs-data.md](references/behavior-vs-data.md) |
| Decidir si abstracción temprana | [yagni-kiss.md](references/yagni-kiss.md) |
| Extraer código o renombrar | [extract-when-grows.md](references/extract-when-grows.md) |
| Leyes de arquitectura (Conway/Postel) | [architecture-laws.md](references/architecture-laws.md) |
| Evaluar calidad del diseño | [properties-of-good-software.md](references/properties-of-good-software.md) |

> **Nota**: El SKILL.md principal contiene el resumen. Los archivos en `references/` tienen la información expandida.

> **Core Insight**: Principles are guides, not laws. The goal is **maintainability through controlled coupling**, not theoretical purity.
