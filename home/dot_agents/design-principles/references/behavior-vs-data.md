# Referencia: Exponer Comportamiento, No Datos

> *"Exposing behaviors is the most essential way to avoid coupling with data and make the system evolvable/changable."*

This is the core principle for reducing coupling at every level:

## Level-by-Level Behavior Exposure

| Level | Principle | How to Apply |
|-------|-----------|--------------|
| **Tests** | Behavior-oriented | Test what it does, not how it does it |
| **Class** | Tell Don't Ask | Encapsulate data, expose methods to manipulate it |
| **Model** | Aggregate encapsulation | Encapsulate writes in Aggregate Root, use Tell Don't Ask |
| **Module/Service** | Data access control | Encapsulate tables/schemas, don't let anyone access directly |
| **API** | Contract-based | Expose what's necessary, use HATEOAS |

> **Summary**: *Encapsulate data and implementation details, expose methods with behavior.*

## Tell Don't Ask

> *"Encapsulate the data and expose methods to edit them."*

```java
// ❌ BAD - Ask-oriented, exposes data
if (account.getBalance().compareTo(amount) > 0) {
    account.setBalance(account.getBalance().subtract(amount));
}
// ✅ GOOD - Tell-oriented, exposes behavior
account.withdraw(money);  // Behavior, not data access
```

## At Aggregate Level

```java
// ❌ BAD - External code manipulates aggregate data
account.setBalance(account.getBalance().add(money));
account.setStatus(AccountStatus.ACTIVE);
// ✅ GOOD - Aggregate exposes behavior
account.deposit(money);
account.activate();
```

## At API Level

> *"Don't expose data in a JSON, expose what's necessary and use HATEOAS to tell the consumer what to do."*

```java
// ❌ BAD - Exposes data, CRUD-oriented
{
    "id": "123",
    "name": "John",
    "email": "john@example.com",
    "passwordHash": "...",
    "createdAt": "2024-01-01",
    "updatedAt": "2024-01-02",
    "status": "ACTIVE"
}
// ✅ GOOD - Exposes behavior/capabilities with HATEOAS
{
    "account": {
        "balance": "1000.00",
        "currency": "USD"
    },
    "actions": {
        "deposit": "/api/accounts/123/deposit",
        "withdraw": "/api/accounts/123/withdraw",
        "transfer": "/api/accounts/123/transfer"
    }
}
```

## Stability Reduces Coupling

> *"One of the best ways to fight coupling is making something stable, i.e., non-volatile, so we don't worry about that coupling."*

### How to Make Things Stable

**Define by what it DOES, not by what it IS:**

| Fragile (Data-Oriented) | Robust (Behavior-Oriented) |
|-------------------------|---------------------------|
| Exposes `Customer.name` | Exposes `Customer.rename()` |
| Exposes `Order.items` | Exposes `Order.addItem()` |
| Exposes `Account.balance` | Exposes `Account.withdraw()` |
| Returns database entities | Returns behavior capabilities |

> *"The best way to make something robust is to define it by what it does. The best way to define a robust or anti-fragile contract is to orient to business capabilities, i.e., expose behavior, not data. How we structure data is an implementation detail."*

## Summary: Behavior vs Data

| Concept | Data-Oriented (Bad) | Behavior-Oriented (Good) |
|---------|-------------------|------------------------|
| **Design** | Exposes fields | Exposes methods |
| **Tests** | Check state | Check behavior |
| **API** | Returns entities | Returns capabilities + HATEOAS |
| **Messages** | Event-carried state | Behavior events |
| **Coupling** | High | Low |
| **Evolva** | Difficult | Easy |

> **Core Principle**: *Encapsulate data and implementation details, expose methods with behavior.*
