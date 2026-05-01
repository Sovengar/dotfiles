# Referencia: Leyes de Arquitectura

## Conway's Law

> *"The organization of your company will be materialized in the applications they build. If in your company they only know how to do CRUPs, although you want it, a CRUD will come out."*

### The Reality

| Company Culture | Application Style |
|-----------------|-------------------|
| Siloed departments | Monolithic apps with boundaries matching org structure |
| CRUD-focused teams | REST endpoints exposing data, behavior-poor |
| Feature factories | Many small services, each doing one thing |
| Domain experts | Behavior-rich services, explicit capabilities |
| Communication-heavy | Event-driven, loosely coupled |

### The Implication

> *"The way your organization structures communication will be reflected in your software architecture."*

**If your company:**

- Has teams that don't talk to each other → You'll get integration problems
- Only knows CRUD → You'll get data-centric, behavior-poor APIs
- Values speed over design → You'll get technical debt
- Encourages domain knowledge → You'll get behavior-rich models

### How to Use It

1. **Understand your organization's strengths** → Build on them
2. **Identify gaps** → The code will reflect them
3. **Change the org** → If you want to change the code
4. **Hire for skills you need** → Conway's law works both ways

> *"If in your company they only know how to do CRUDS, although you want it, a CRUD will come out."*

---

## Postel's Law (Robustness Principle)

> *"It suggests that systems should 'be liberal in what they accept and conservative in what they send'. This principle aims to improve system resilience by allowing for flexibility in input formats while maintaining strict standards for output."*

### The Core

| Direction | Principle |
|-----------|-----------|
| **Accept** | Be liberal in what you accept (flexible inputs) |
| **Send** | Be conservative in what you send (stable outputs) |

### How to Apply

> *"Basicamente, consiste en exponer lo justo y necesario, esto lo conseguimos con expose behavior not data. Y aceptar diferentes opciones."*

#### Expose Only What's Necessary

```java
// ❌ BAD - Exposing too much (data-centric)
public class Account {
    public String name;
    public String email;
    public String phone;
    public String address;
    public BigDecimal balance;
    public Currency currency;
    public LocalDate createdAt;
    public LocalDate updatedAt;
    // ... 20 more fields
}
// ✅ GOOD - Expose behavior, not data
public class Account {
    public void deposit(money amount) { ... }
    public void withdraw(money amount) { ... }
    public Money getBalance() { ... }
    public AccountSummary getSummary() { ... }  // Only what's needed
}
```

### Public Contracts Freeze

> *"Todo lo que sea publico, se congela en mayor o menor medida, ya que al estar expuesto, se convierte en un contrato."*

#### Where Contracts Form

| Level | What Becomes Contract |
|-------|----------------------|
| **Method** | Method name + parameters |
| **DTO** | Field structure |
| **Events** | Event schema |
| **Interface** | Abstract method signatures |

### Think From the Consumer's Perspective

> *"Una vez que somos conscientes de lo que implica exponer un metodo publico, podemos pensar desde el punto de vista del cliente/consumidor de dicho metodo."*
> *"Esto nos va a ayudar a diseñar objetos mejor diseñados, con menos metodos publicos y con mas SRP."*

### Controlled vs Uncontrolled Consumers

> *"Si es un contrato que aunque esté expuesto, controlamos los consumidores, entonces podemos mas o menos cambiarlo, pero sino es muy dificil."*

| Scenario | Can Change? |
|----------|-------------|
| Internal consumers (same codebase) | ✅ Can refactor |
| Frontend (you control) | ⚠️ Can change, but coordination needed |
| Third-party services | ❌ Very difficult |

### Summary: Postel's Law in Practice

| Rule | Guidance |
|------|----------|
| **Expose behavior** | Not data - "expose only what's necessary" |
| **Accept flexibly** | Different input options when reasonable |
| **Send conservatively** | Stable, minimal contracts |
| **Think consumer** | Design from the consumer's perspective |
| **Use interfaces** | When conditions meet - replaceable in code and tests |
| **Behavior > data** | More stable, more evolution-friendly |

> *"Siempre piensa en el contrato que vas a hacer y su estabilidad, intenta que sea lo mas estable posible, esta mentalidad te dará un mejor diseño. Sera mas estable cuanto mas lo orientes al behavior en vez de a los datos."*
