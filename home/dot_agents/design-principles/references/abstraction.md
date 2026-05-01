# Referencia: Cuándo Abstraer

> *"Abstractions consist of adding a level of indirection to define a contract or premise, or a more generic concept. They must be used carefully because this can cause 2 things: it can be difficult to change and it can be difficult to understand. At the other extreme, no abstraction is also bad, as there would be too much code duplication and/or uncontrolled coupling."*

## The Abstraction Trap

> *"If you use them by default, you are just moving the coupling from one side to another, but it remains. Adding an abstraction doesn't reduce coupling, it just moves it from element X to your abstraction."*

```java
// ❌ ABSTRACTION TRAP - Moving coupling, not reducing it
public interface UserRepository { ... }  // Just moves coupling here
public class UserRepositoryImpl implements UserRepository { ... }  // Coupling still exists
// Use the real class instead if there's only one implementation
public class UserService {
    private final UserRepository repository;  // Just use the class!
}
```

**This point needs nuance:**

- Using an object in 100 places → changing it affects 100 places
- Having an abstraction that centralizes 100 methods → changing it affects 100 places
- **But**: With abstraction, if we change the ORM, we still have to change all 100 functions

## Let the Code Force You

> *"Let the code force you to it. If you need it later, with the IDE it's easy to refactor a class so that the code references the new interface."*

```java
// ✅ Start with concrete class
public class UserService {
    private final EmailSender emailSender;  // Direct, simple
}
// ✅ EXTRACT WHEN NEEDED - IDE refactors to interface
public interface EmailSender {
    void send(String to, String message);
}
public class UserService {
    private final EmailSender emailSender;
}
```

> *"You can also use a SHIM to make the transition."*

## When to Create Interfaces

**If you have more than one implementation, CREATE an interface (Strategy pattern):**

```java
// ✅ Multiple implementations = need interface
public interface PaymentProcessor {
    void process(Payment payment);
}
public class StripeProcessor implements PaymentProcessor { ... }
public class PayPalProcessor implements PaymentProcessor { ... }
```

**If you have only ONE implementation, DON'T create an interface:**

```java
// ❌ UNNECESSARY - Only one implementation
public interface UserService { ... }
public class UserServiceImpl implements UserService { ... }
// ✅ SIMPLE - Just use the class
public class UserService { ... }
```

## Adapter Pattern: When It Makes Sense

> *"To use this pattern, you must meet 2 conditions:*
> *1. It's to adapt a class that does I/O or communicates with something external, a library, or another bounded context.*
> *2. Consider if there really is a high degree of coupling - it's not the same to use it in 1 place as in 100."*

### Good Candidates for Abstraction (Adapter Pattern)

| Candidate | Why Abstract | Example |
|-----------|---------------|---------|
| **ORM** | Change DB without rewriting queries | `AccountStore` |
| **File I/O** | Easy testing with fakes | `PdfGenerator`, `CsvExporter` |
| **External Services** | Mocking + simplify usage + Anti-corruption | `PaymentGateway`, `ShippingAPI` |
| **Third-party Libraries** | Encapsulate, simplify usage | `LoggerAdapter`, `MapperAdapter` |
| **Cross-Boundary Communication** | Anti-corruption layer | `OrderToBillingAdapter` |

### NOT Good Candidates

| Don't Abstract | Why |
|----------------|-----|
| **Your own services** | 1:1 mapping, you'll change both anyway |
| **Single-use cases** | Just use the class directly |
| **Very opinionated libraries** | Leaky abstractions, over-engineering |
| **Already testable tools** | ORM/JPA already testable |

## Summary: When to Abstract

| Scenario | Decision |
|----------|----------|
| Only ONE implementation | ❌ Don't abstract |
| TWO+ implementations (Strategy) | ✅ Create interface |
| External/third-party library | ✅ Abstract (Adapter pattern) |
| ORM / Data layer | ⚠️ Careful - often unnecessary |
| Very opinionated library | ❌ Don't abstract - leaky |
| Single method needed | ✅ Use lambda/delegate |
| Cross-boundary (bounded contexts) | ✅ Abstract (Anti-corruption) |
| Application services | ❌ Don't abstract |
| Facade with 1 impl | ❌ Don't abstract |

> *"The purpose of abstraction is not to be vague, but to create a new semantic level in which one can be absolutely precise."*
> *"At some point you realize you are just writing contracts to talk to yourself."*
