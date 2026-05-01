# Referencia: Gestión del Acoplamiento

**The 90% of the work is learning to deal with coupling, not eliminating it.**
Some coupling can be reduced, but most types cannot be eliminated. The goal is to **manage** it effectively.

## Best Practice: Bounded Contexts

The most effective way to manage coupling is establishing **logical boundaries** with well-defined Bounded Contexts.

```java
// Well-defined boundary between contexts
// banking/domain/... - only cares about banking logic
// order/domain/... - only cares about order logic
// _shared/domain/... - explicit shared contracts
```

**Why this works:**

- When change is needed due to coupling, it affects the **smallest amount of code possible**
- Each bounded context is a **change boundary**
- Dependencies between contexts are explicit and limited

## Coupling CAN Be Reduced

| Type | Can Reduce? | How |
|------|-------------|-----|
| Temporal (timing dependencies) | ✅ Yes | Event-driven, async patterns |
| Data format (DTOs) | ✅ Yes | Standardized contracts |
| Communication style | ✅ Yes | REST vs Events vs RPC |

## Coupling CANNOT Be Reduced (Only Managed)

These patterns **move** coupling but don't eliminate it:

| Pattern | What It Does | Why It's Not Reduction |
|---------|---------------|------------------------|
| **DTOs** | Converts between formats | Still coupled, just in different layer |
| **Mappers** | Maps entity ↔ DTO | Still coupled, just hidden |
| **Data Access Layer** | Abstracts DB | Still coupled to DB schema |
| **Repository Pattern** | Abstracts storage | Still coupled to storage |

> *"Examples that only move the coupling from one side to another: DTOs, Mappers vs Specific Queries, Data Access Layer…"*

## Evolvability Patterns

Useful patterns with **low cost** to make your system evolvable:

| Pattern | Benefit | Cost |
|---------|---------|------|
| **Explicit Interfaces** | Clear contracts between contexts | Low |
| **Domain Events** | Decouple producers from consumers | Low |
| **Anti-Corruption Layer** | Translate external APIs | Medium |
| **Specific Queries** | Projections instead of full entities | Low |
| **Module Boundaries** | Clear ownership, limited blast radius | Low |

> **Best way to manage coupling**: Establish clear Bounded Context boundaries so that when changes happen due to coupling, the impact is contained.

The goal is not eliminating coupling — it's **containing** its blast radius.
