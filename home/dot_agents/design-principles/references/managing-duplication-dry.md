# Referencia: DRY - Don't Repeat Yourself

> *"This principle promotes reducing code duplication. Each piece of knowledge must have a unique, unambiguous representation in the system. This facilitates maintenance and code evolution."*

## El Acoplamiento y DRY a Veces Van de la Mano

> *El acoplamiento y DRY a veces van de la mano.*

---

## Tipos de Duplicación

Hay 2 tipos de código duplicado, el **real** y el **accidental**.

### Duplicación Real

Es cuando realmente es el mismo código copiado y pegado en 2 o más sitios, y un cambio debe aplicarse en todos los sitios donde esté.

### Duplicación Accidental

Es cuando tienes, por ejemplo, 2 pantallas muy parecidas (p.e. alta y editar). El código que necesites **ahora** puede que sea el mismo, pero seguro que dentro de **5-10 años** serán muy diferentes.

> *Este tipo de duplicación está permitida.*

---

## Duplicación de Capas (Duplication of Layers)

> *By the same token, when you are separating layers horizontally, you might notice that the data structure of a particular database record is very similar to the data structure of a particular screen view. You may be tempted to simply pass the database record up to the UI, rather than to create a view model that looks the same and copy the elements across.*

**Cuidado**: Esta duplicación es casi certamente accidental.

> *Creating the separate view model is not a lot of effort, and it will help you keep the layers properly decoupled.*

---

## Duplicación de Casos de Uso (Duplication of Use Cases)

> *When you are vertically separating use cases from one another, your temptation will be to couple the use cases because they have similar screen structures, or similar algorithms, or similar database queries and/or schemas.*

**Cuidado**. Resiste la tentación de cometer el pecado de eliminación impulsiva de duplicación.

> *Make sure the duplication is real, not accidental.*

---

## Importante: Código Repetido No Siempre Es Código Duplicado

> *Código repetido no significa código duplicado siempre. `precio * 0.21` puede tener diferentes significados según el contexto:*
> - *Para un vendedor puede ser IVA*
> - *Para un mecánico puede ser su comisión de mano de obra*

**Es decir**: No te fijes en que sean las mismas líneas de código, sino que sean el **mismo concepto** o no, si se aplican en el **mismo contexto** o no.

> *El código puede literalmente ser el mismo, pero no se considera duplicado porque es accidentalmente similar y es probable que conforme evolucione el sistema, terminen divergiendo estos caminos.*

---

## The Cost of Duplication

| Aspect | Duplication | Abstraction |
|--------|-------------|-------------|
| Change | Update in multiple places | Update in one place |
| Bug fixing | Fix in multiple places | Fix in one place |
| Understanding | Repeated mental effort | Single concept |
| Vocabulary | None | Rich domain language |

## Duplication is an Opportunity

> *"Whenever you see duplicated code, it represents a missed opportunity for abstraction. That duplication could become a subroutine or perhaps another class."*

## Abstraction Enriches the Domain

> *"The fact that eliminating duplication with abstraction indirectly increases your domain's vocabulary, enriches it. Other programmers can use the abstractions you create, coding becomes faster, and there is less probability of creating new bugs because you have raised the level of abstraction."*

## When to Apply DRY

| Duplication Type | Action | Example |
|------------------|--------|---------|
| Exact same code | Extract to method | `formatDate()` |
| Similar logic, same intent | Extract to class | `OrderValidator` |
| Same business rule | Extract to domain | `Money.add()` |
| Same data structure | Extract to type | `Address` value object |

## When to Ignore DRY

- When the "duplication" is actually independent concepts
- When abstraction would make the code less clear
- When the cost of abstraction exceeds the benefit

## Applying DRY Wrong

> *"DRY eliminates duplication but also increases coupling. If you abstract the same function and it is used 12 times, if you change it, it will affect 12 things."*

### The Single Source of Truth Trap

> *"Under the obsession of avoiding code duplication and centralizing business logic in one place (single source of truth), we achieve code without duplication but more implicit and coupled. This helps for the first 2-3 use cases, but after that it gets drastically worse."*

### The Frankenstein Code Problem

> *"When this happens, the code or entity becomes a super coupled and confusing frankenstein. It can't be touched because it can change for a thousand reasons - it doesn't follow SRP, there's no functional cohesion."*

### Don't Repeat Concepts, Not Code

> *"The most obvious example is that the same thing, which appears to be the same, for example the Trailer entity, depending on the context will have a different value. DON'T REPEAT CONCEPTS, not code, CONCEPTS, IDEAS, CONTEXTS."*

| Concept A | Concept B | Should Be |
|-----------|-----------|-----------|
| Unhook a trailer | Dispatch Order with trailer | Different concepts! |
| Product in Warehouse context | Product in Sales context | Different contexts! |
| Customer in Billing | Customer in Support | Different contexts! |

> *"They can be shared because it's more convenient, but as it scales it will have to be separated."*

## How to Apply DRY Correctly

### Wait for 3 Repetitions

> *"Wait for something to repeat 3 times before abstracting it. Before abstracting it, check that it's real duplication and not temporary duplication."*

### Apply DRY at Different Levels

| Level | Rule |
|-------|------|
| **Within module/file** | Max 2 lines of duplication allowed |
| **Cross-module** | Think carefully - maybe we need to duplicate |
| **Microservices** | Duplication is acceptable |

### DRY in Microservices

> *"Within a module, class or file I don't allow more than 2 lines of duplication of code. With broader concepts that cross modules, think carefully because maybe we need to duplicate."*

**Solutions for cross-service duplication:**

| Solution | When to Use |
|----------|--------------|
| **Same repo** | Both services in same repo, deploy together |
| **Shared library** | Use with caution - coupling issues |
| **Duplicate** | Simplest solution, acceptable in microservices |

## Summary: DRY Done Right

| Rule | Guidance |
|------|----------|
| **Wait** | Wait for 3 repetitions before abstracting |
| **Check** | Ensure it's real duplication, not temporary |
| **Context matters** | Trailer in logistics ≠ Trailer in shipping |
| **Behavior > Data** | Expose behaviors, not data structures |
| **Separate use cases** | Don't use boolean flags for different use cases |
| **Explicit > Generic** | If making code less explicit, think twice |
| **Microservices** | Duplication is often acceptable |

> *"DONT REPEAT CONCEPTS, not code, CONCEPTS, IDEAS, CONTEXTS."*
