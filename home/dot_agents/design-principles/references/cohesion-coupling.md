# Referencia: Cohesión y Acoplamiento

> *"Todos los principios, patrones y heurísticas son para ofrecer una o ambas opciones, aumentar la cohesión funcional y/o disminuir el acoplamiento."*

## The Big Picture

| Goal | Why |
|------|-----|
| **Increase Functional Cohesion** | Make code easy to understand and change |
| **Reduce Coupling** | Make changes isolated and safe |
| **Together** | Creates flexible, testable, understandable systems |

> *"Una mayor cohesión funcional para que así sea fácil de entender y cambiar, ya que a su vez esto trae bajo acoplamiento."*

## The Ideal

| Property | Benefit |
|----------|---------|
| **Low Coupling** | Changes are isolated |
| **High Cohesion** | Easy to understand |
| **Together** | Flexible, testable, clear separation of roles |

> *"Queremos poco acoplamiento y mucha cohesión, lo cual hace el sistema flexible, más fácil de testear y mayor separación de roles (lo cual lo hace más sencillo de entender porque puedes tocar una parte sin tener que entender sus colaboradores)."*

## When Coupling Is Acceptable

> *"No obstante, hay veces que es más inofensiva/lidiable o que no compensa el esfuerzo de desacoplarse, por ejemplo, el framework o instanciar cierta clase dentro de otra con new en vez de DI (en duda)."

| Scenario | Coupling Acceptable? |
|----------|----------------------|
| Framework code | ✅ Yes - unavoidable |
| Internal utilities | ✅ Often not worth decoupling |
| `new` inside class | ⚠️ Depends on context |
| Third-party with single use | ⚠️ Low impact |
| Cross-boundary (external) | ❌ Should decouple |

## How Patterns Achieve This

| Pattern | Effect |
|---------|--------|
| **DDD (Bounded Contexts)** | *"DDD se basa en definir subdomains, bounded contexts para garantizar una alta cohesión"* |
| **Microservicios/Módulos** | *"se basan en encapsular el comportamiento y los datos (tablas) necesarios para ese comportamiento, para garantizar una alta cohesión"* |
| **SRP** | *"se basa en tener el código que hace una cosa junto y separado del resto, garantizando una alta cohesión"* |
| **Eventos** | *"transforman Afferent coupling en Efferent coupling"* |

> *"Aumentar la cohesión también puede ayudar a reducir el acoplamiento, pero no eliminarlo."*
