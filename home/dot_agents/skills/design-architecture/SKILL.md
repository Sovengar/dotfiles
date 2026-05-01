---
name: design-architecture
description: >
  Software architecture patterns and conventions.
  Trigger: When structuring code, organizing packages, or making architectural decisions.
tags: [design-architecture, architecture, patterns, conventions]
triggers: [design-architecture, architecture, structuring, packages, architectural]
---

# Architecture

This skill captures architectural patterns and conventions for organizing code in a Java application.

## When to Use

- Structuring packages and layers
- Organizing domain types
- Making architectural decisions
- Applying DDD patterns

---

## Design Principles

For fundamental design principles including **coupling**, **cohesion**, **SOLID**, and **context-aware decisions**, see the **design-principles** skill.

Key points from design-principles:

- **Context Over Rules**: Always evaluate based on your specific context
- **Controlled Coupling**: Being coupled is fine; being VERY coupled is the problem
- Measure coupling by: frequency of use, volatility, and distance/blast radius
- If you can swap a library by changing **one file**, the coupling is acceptable

---

## Conceptual Annotations

These annotations are useful to express **intent** and **domain concepts**. They are technology-agnostic concepts that adapt based on the underlying framework.

### Core Annotations

| Annotation | Concept | Spring Boot Adaptation |
|------------|---------|------------------------|
| `@AggregateRoot` | Marks a domain entity as the root of an aggregate | Not needed at runtime (purely semantic) |
| `@ValueObject` | Marks an immutable value type | Use `@Embeddable` + Lombok annotations |
| `@ApplicationService` | Marks a use case / command handler | Use `@Service` or `@Component` |
| `@WebAdapter` | Marks an HTTP endpoint / controller | Use `@RestController` + `@RequestMapping` |
| `@InMemoryOnlyCatalog` | Marks entities only for testing/in-memory scenarios | Not needed at runtime |

### Value Object Example

```java
@ValueObject
@Embeddable
@NoArgsConstructor(access = PACKAGE, force = true)
@RequiredArgsConstructor(staticName = "of")
public class Email implements Serializable {
    String value;
    
    static Email of(String value) {
        return new Email(requireNonNull(value));
    }
}
```

### Aggregate Root Example

```java
@AggregateRoot
@Entity
public class Account {
    
    @Id
    private UUID id;
    
    @Embedded
    private AccountNumber accountNumber;
    
    @Embedded
    private Money balance;
    
    public void withdraw(Money amount) {
        // Domain logic here
    }
}
```

### Application Service Example

```java
@ApplicationService  // Concept: this is a command handler
public class TransferMoney {
    
    private final AccountStore accountStore;
    private final TransactionStore transactionStore;
    
    @Transactional
    public void handle(final Command command) {
        // Orchestration logic
    }
    
    public record Command(...) { }
}
```

> **Note**: In Spring Boot projects, these conceptual annotations map to framework annotations:
> - `@ApplicationService` → `@Service`
> - `@WebAdapter` → `@RestController` + `@RequestMapping`
> - `@ValueObject` → `@Embeddable`

---

## Functional Cohesion

Keep related code together. Types that belong to a model should be nested within it or in the same package, not scattered across the codebase.

### When to Use

- Creating enums that belong to an entity
- Defining value objects for a specific entity
- Organizing related types in a domain model

### Enum as Inner Class

```java
// ❌ BAD - scattered across codebase
// File: com/example/enums/ProductStatus.java
public enum ProductStatus {
    DRAFT, ACTIVE, INACTIVE
}

// ✅ GOOD - nested inside entity
@Entity
public class Product {
    
    @Enumerated(EnumType.STRING)
    private ProductStatus status;
    
    @Getter
    public enum ProductStatus {
        DRAFT,
        ACTIVE,
        INACTIVE;
    }
}
```

### Why This Matters

| Aspect | Scattered | Cohesion |
|--------|-----------|----------|
| Find related code | Search across files | All in one place |
| Rename/refactor | Multiple files | One file |
| Context | Need to remember location | Always visible |
| Domain understanding | Fragmented | Complete picture |

---

## Decision Matrix

| Type | Location | Why |
|------|----------|-----|
| Status enum for Product | Inside Product | Belongs to Product domain |
| Generic Status (used everywhere) | Separate file in shared/core | Shared across entities |
| Email value object | Inside Email class | Self-contained |
| Shared value objects | `_shared/domain/vo/` or `core/domain/vo/` | Used by multiple bounded contexts |
| Role enum | Inside Role entity | Domain-specific |

---

## Examples

### ✅ Correct: Nested Status

```java
@Entity
public class Product {
    
    private String name;
    private BigDecimal price;
    
    @Enumerated(EnumType.STRING)
    private ProductStatus status;
    
    @Getter
    public enum ProductStatus {
        DRAFT,
        ACTIVE,
        INACTIVE,
        ARCHIVED
    }
}
```

### ✅ Correct: Nested with Logic

```java
@Entity
public class User {
    
    private String email;
    private UserStatus status;
    
    public boolean canLogin() {
        return status == UserStatus.ACTIVE;
    }
    
    @Getter
    public enum UserStatus {
        PENDING,
        ACTIVE,
        SUSPENDED,
        DELETED;
    }
}
```

---

## Package Organization

### Bounded Contexts with Layered Subdirectories

The recommended structure divides by bounded context, with each context containing its own layered architecture:

```
src/
├── auth/
│   ├── domain/
│   │   ├── models/
│   │   ├── store/              // Repository interfaces
│   │   ├── vo/                // Value objects (bounded-context specific)
│   │   ├── services/
│   │   ├── policies/
│   │   ├── catalogs/
│   │   ├── exceptions/
│   │   └── events/
│   ├── application/
│   │   └── CreateUser.java    // Use case
│   ├── infra/
│   │   ├── store/
│   │   │   ├── repositories/
│   │   │   │   ├── spring_jpa/
│   │   │   │   ├── postgres/
│   │   │   │   └── inmemory/
│   │   │   ├── converters/
│   │   │   └── specifications/
│   │   └── config/
│   └── queries/
│       └── FindUser.java
├── banking/
│   ├── domain/
│   ├── application/
│   ├── infra/
│   └── queries/
└── _shared/                   // Cross-cutting domain types
    ├── domain/
    │   ├── vo/                // Shared value objects (Money, Email, etc.)
    │   ├── models/           // Shared entities
    │   ├── catalogs/         // Shared enums
    │   ├── exceptions/
    │   └── events/
    └── infra/
        ├── repositories/
        └── converters/
```

### Naming Options

| Concept | Option A | Option B |
|---------|----------|----------|
| Repository interfaces | `domain/store/` | `domain/repo/` |
| Value objects | `domain/vo/` | `domain/valueObjects/` |

> **Note**: Both options are valid. Choose one and apply consistently across the project.

### Layer Definitions

| Layer | Contents | Example |
|-------|----------|---------|
| **domain/models/** | Entities (Aggregate Roots) | `Account.java`, `User.java` |
| **domain/store/** | Repository interfaces (infra-agnostic) | `AccountStore.java` |
| **domain/vo/** | Value Objects (bounded-context specific) | `AccountNumber.java` |
| **domain/services/** | Domain Services | `AccountValidator.java` |
| **domain/policies/** | Domain Policies | `AccountNumberGenerator.java` |
| **domain/catalogs/** | Enums (bounded-context specific) | `AccountStatus.java` |
| **domain/exceptions/** | Domain exceptions | `AccountNotFoundException.java` |
| **domain/events/** | Domain events (bounded context level) | `MoneyDeposited.java` |
| **application/** | Use Cases, Application Services | `TransferMoney.java` |
| **infra/** | Repository implementations, Converters | `AccountSpringJpaRepo.java` |
| **queries/** | Query handlers, DTOs (projections) | `FindAccount.java` |
| **_shared/domain/vo/** | Shared Value Objects across contexts | `Money.java`, `Email.java` |
| **_shared/domain/catalogs/** | Shared Enums across contexts | `Currency.java` |

### Shared / Core / Commons Pattern

Value objects and catalogs used by **multiple bounded contexts** should NOT be in a specific bounded context. Instead, place them in a shared module:

```
_shared/                     // or: core/, commons
├── domain/
│   ├── vo/
│   │   ├── Money.java
│   │   ├── Email.java
│   │   ├── PhoneNumber.java
│   │   ├── URLStringed.java
│   │   └── BirthDate.java
│   ├── catalogs/
│   │   └── Currency.java
│   ├── models/
│   │   └── Country.java
│   ├── exceptions/
│   │   └── OperationWithDifferentCurrenciesException.java
│   └── events/
│       └── AccountHolderDeleted.java
└── infra/
    ├── repositories/
    ├── converters/
    └── AppUrls.java
```

---

## Domain Layer Contents

| Type | Location | Purpose |
|------|----------|----------|
| **Model** (Entities) | `domain/models/` | Aggregate Roots, domain behavior |
| **Repository** (interface) | `domain/store/` | For Commands - loads full Aggregate Root |
| **Value Objects** (context-specific) | `domain/vo/` | Immutable types |
| **Value Objects** (shared) | `_shared/domain/vo/` | Immutable types used across contexts |
| **Policies** | `domain/policies/` | Business rules |
| **Domain Services** | `domain/services/` | Complex domain logic |
| **Catalogs** (context-specific) | `domain/catalogs/` | Enums for this context |
| **Catalogs** (shared) | `_shared/domain/catalogs/` | Enums used across contexts |
| **Exceptions** | `domain/exceptions/` | Domain exceptions |
| **Events** | `domain/events/` | Domain events (bounded context level) |

---

## Infrastructure Layer

The infra layer contains technology-specific implementations. Based on the codebase, here's a comprehensive structure:

```
infra/
├── store/
│   ├── repositories/
│   │   ├── spring_jpa/           // JPA/Hibernate implementations
│   │   │   └── AccountSpringJpaRepo.java
│   │   ├── postgres/             // Native PostgreSQL implementations (optional)
│   │   │   └── AccountPostgreRepo.java
│   │   └── inmemory/             // In-memory implementations (testing)
│   │       └── AccountInMemoryRepo.java
│   ├── converters/               // Entity <-> Domain converters
│   │   └── StreetTypeToCodeConverter.java
│   ├── specifications/           // JPA Specifications for complex queries
│   │   └── AccountSpecifications.java
│   └── readmodels/               // Read models / projections
│       └── TransactionsByAccountView.java
├── config/                       // Module-specific configuration
│   └── BankingConfig.java
└── internal/                     // Internal HTTP APIs
    ├── BankingApiInternal.java
    └── BankingQueryApiInternal.java
```

### Repository Pattern per Technology

```java
// Spring JPA Repository
// File: infra/store/repositories/spring_jpa/AccountSpringJpaRepo.java
@Repository
public interface AccountSpringJpaRepo extends JpaRepository<AccountEntity, UUID> {
    Optional<AccountEntity> findByAccountNumber(String accountNumber);
}

// PostgreSQL-specific Repository (optional - for native queries)
// File: infra/store/repositories/postgres/AccountPostgreRepo.java
@Repository
public class AccountPostgreRepo implements AccountStore {
    
    private final NamedParameterJdbcTemplate jdbc;
    
    @Override
    public Optional<Account> findById(UUID id) {
        // Native SQL implementation
    }
}

// In-Memory Repository (for testing)
// File: infra/store/repositories/inmemory/AccountInMemoryRepo.java
@InMemoryOnlyCatalog
public class AccountInMemoryRepo implements AccountStore {
    
    private final Map<UUID, Account> storage = new ConcurrentHashMap<>();
    
    @Override
    public Optional<Account> findById(UUID id) {
        return Optional.ofNullable(storage.get(id));
    }
}
```

### Converter Pattern

```java
// File: infra/store/converters/StreetTypeToCodeConverter.java
public class StreetTypeToCodeConverter implements Converter<String, StreetType> {
    
    @Override
    public StreetType convert(String source) {
        return StreetType.fromCode(source);
    }
}
```

---

## Repository vs Queries

> **Key distinction**: Domain repositories are for **Commands** (writes), queries folder is for **Reads**.

```java
// Domain Repository - loads full Aggregate Root for Commands
// File: domain/store/AccountStore.java
public interface AccountStore {
    Optional<Account> findById(UUID id);
    Account save(Account account);
    void delete(Account account);
}

// Query - different concern, different location
// File: queries/FindAccount.java
@WebAdapter(BANKING_MODULE_URL + ACCOUNTS_RESOURCE_URL)
public class FindAccount {
    
    private final AccountStore accountStore;
    
    public AccountDTO execute(UUID id) {
        Account account = accountStore.findById(id)
            .orElseThrow(() -> new AccountNotFoundException(id));
        return AccountDTO.from(account);
    }
}
```

> **Why?** Commands need the full Aggregate Root to execute business logic. Queries only need specific fields (DTOs/projections).

---

## Application Service Pattern

Use Cases are implemented as Application Services (not Services with business logic):

### Structure

```java
@Slf4j
@RequiredArgsConstructor
@ApplicationService  // Conceptual annotation → @Service in Spring Boot
public class TransferMoney {
    
    private final AccountStore accountStore;
    private final TransactionStore transactionStore;
    private final AccountValidator accountValidator;
    
    @Transactional
    public void handle(final @Valid Command message) {
        log.info("BEGIN TransferMoney from {} to {}", message.sourceId(), message.targetId());
        
        Account source = getAccountValidated(message.sourceId());
        Account target = getAccountValidated(message.targetId());
        
        validateDifferentAccounts(source.getAccountNumber(), target.getAccountNumber());
        
        transfer(source, target, message.amount(), message.currency());
        
        log.info("END TransferMoney from {} to {}", message.sourceId(), message.targetId());
    }
    
    private Account getAccountValidated(String accountNumber) {
        var account = accountStore.findByNumber(accountNumber);
        accountValidator.validate(account);
        return account;
    }
    
    private void validateDifferentAccounts(AccountNumber source, AccountNumber target) {
        if (source.equals(target)) {
            throw new OperationForbiddenForSameAccount();
        }
    }
    
    private void transfer(Account source, Account target, BigDecimal amount, Currency currency) {
        var money = Money.of(amount, currency);
        
        source.withdraw(money);
        target.deposit(money);
        
        accountStore.update(source);
        accountStore.update(target);
        
        var transaction = Transaction.Factory.transfer(money, source.getAccountNumber(), target.getAccountNumber());
        transactionStore.register(transaction);
    }
    
    // Command DTO as inner record
    public record Command(
            @NotEmpty String sourceId,
            @NotEmpty String targetId,
            @NotNull BigDecimal amount,
            @NotNull Currency currency) { }
}
```

### Web Adapter (Controller)

```java
@Slf4j
@RequiredArgsConstructor
@WebAdapter("BANKING_MODULE_URL + ACCOUNTS_RESOURCE_URL")  // Conceptual → @RestController
class TransferMoneyHttpController {
    
    private final TransferMoney transferMoney;
    
    @PostMapping(path = "/transfer/{sourceId}/{targetId}/{amount}/{currency}")
    public ResponseEntity<Response<Void>> transferMoney(
            @PathVariable String sourceId,
            @PathVariable String targetId,
            @PathVariable BigDecimal amount,
            @PathVariable String currency) {
        
        generateTraceId();
        
        var command = new TransferMoney.Command(
            sourceId, targetId, amount, Currency.fromCode(currency));
        
        transferMoney.handle(command);
        
        return ResponseEntity.ok(new Response.Builder<Void>().withDefaultMetadataV1());
    }
}
```

### Key Points

- **Use Case**: `TransferMoney` handles the business orchestration
- **Command DTO**: Inner record in the use case (`Command`)
- **Validator**: Separate class (`AccountValidator`) for complex validation
- **Repositories**: Domain repositories (for Commands) - loads full Aggregate Root
- **Queries**: Use `queries/` folder, NOT repositories
- **Transactional**: Use `@Transactional` on the handle method

> **Important**: Repository in `domain/store` is for **Commands** (writes). 
> Queries go in `queries/` folder and return DTOs/projections, not Aggregate Roots.

> **Note**: The Application Service should only orchestrate. Business logic belongs in the Domain (Entities, Value Objects).

---

## When NOT to Nest

- Type is used by multiple bounded contexts (use `_shared/`, `core/`, or `commons/`)
- Type is a generic utility (e.g., `Email`, `PhoneNumber` - put in shared)
- Type is a framework constant (e.g., `jakarta.persistence.GenerationType`)

### Exception: Mature Projects with Enum Folder

If the project follows a consistent convention of grouping all enums in a dedicated folder (e.g., `com.example.enums`), this is acceptable **if** the convention is applied consistently across the entire codebase.

> **Note**: This only works if the project strictly follows this convention. Mixing approaches creates confusion.

---

## More Examples of Functional Cohesion

### ✅ ID Classes

```java
@Entity
public class Order {
    
    @EmbeddedId
    private OrderId id;
    
    @Embeddable
    @ValueObject
    @NoArgsConstructor(access = PACKAGE, force = true)
    public static class OrderId implements Serializable {
        UUID orderId;
        LocalDateTime createdAt;
        
        static OrderId of(UUID orderId) {
            return new OrderId(requireNonNull(orderId), LocalDateTime.now());
        }
    }
}
```

### ✅ Factory Class Nested

```java
@Entity
public class User {
    
    private String name;
    private UserStatus status;
    
    @NoArgsConstructor(access = PRIVATE)
    public static class Factory {
        public static User createUser(String name) {
            requireNonNull(name);
            User user = new User();
            user.setName(name);
            user.setStatus(UserStatus.DRAFT);
            return user;
        }
    }
}
```

### Domain Exceptions

```java
// File: domain/exceptions/InsufficientFundsException.java
public class InsufficientFundsException extends RuntimeException {
    public InsufficientFundsException(String message) {
        super(message);
    }
}

// File: domain/models/Account.java
@AggregateRoot
@Entity
public class Account {
    
    private BigDecimal balance;
    
    public void withdraw(BigDecimal amount) {
        if (amount.compareTo(balance) > 0) {
            throw new InsufficientFundsException(
                "Cannot withdraw " + amount + " from balance " + balance
            );
        }
        this.balance = this.balance.subtract(amount);
    }
}
```

### Event Classes (Bounded Context Level)

```java
// File: banking/domain/events/MoneyDeposited.java
public record MoneyDeposited(UUID accountId, Money amount) { }

// File: banking/domain/models/Account.java
@AggregateRoot
@Entity
public class Account {
    
    public void deposit(Money amount) {
        this.balance = this.balance.add(amount);
        this.registerEvent(new MoneyDeposited(this.id, amount));
    }
}
```

> **Note**: Events are typically placed in `domain/events/` **within the bounded context**, not at project level. They may be used by multiple handlers (sagas, notifications, etc.) within that context.

### Validator Classes

```java
@Entity
public class Order {
    
    public static class Validator {
        public static void validate(Order order) {
            requireNonNull(order);
            if (order.getItems().isEmpty()) {
                throw new IllegalArgumentException("Order must have items");
            }
            if (order.getTotal().compareTo(BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException("Order total must be positive");
            }
        }
    }
}
```

> **Note**: For small validators (1-3 rules), keeping them in the entity is fine. 
> For complex logic, use the "Extract When It Grows" pattern - see below.

### Extract When It Grows Pattern

When a nested class grows too large or has multiple responsibilities, extract it to a separate class.

```java
// START: Simple validator inside entity - OK for small cases
@Entity
public class Order {
    public static class Validator {
        public static void validate(Order order) { ... }
    }
}

// EXTRACT WHEN: Validator grows beyond ~50 lines or has multiple methods
// File: domain/services/OrderValidator.java
@Service
public class OrderValidator {
    
    public void validate(Order order) {
        validateItems(order);
        validateTotal(order);
        validateCustomer(order);
    }
    
    private void validateItems(Order order) { ... }
    private void validateTotal(Order order) { ... }
    private void validateCustomer(Order order) { ... }
}
```

**Signs it's time to extract:**
- Validator has more than 3-5 validation methods
- Validator needs dependencies (e.g., other services)
- Validation logic is reused across multiple entities
- Class exceeds ~50 lines

---

## Summary: Types That Belong Together

| Type | Location | Example |
|------|----------|---------|
| Status enum | Inside entity | `Product.ProductStatus` |
| ID class | Inside entity | `Order.OrderId` |
| Value object (context-specific) | `domain/vo/` | `AccountNumber.java` |
| Value object (shared) | `_shared/domain/vo/` | `Money.java`, `Email.java` |
| Factory class | Inside entity | `User.Factory` |
| Domain exception | `domain/exceptions/` | `InsufficientFundsException` |
| DTO/Record | Application Service layer | `TransferMoney.AccountDTO` |
| Constants | Inside entity | `Payment.Limits` |
| Domain events | `domain/events/` (bounded context) | `MoneyDeposited.java` |
| Validator | Inside entity (small) or domain service | `Order.Validator` or `OrderValidator` |
| Specifications | In infra/store | `AccountSpecifications.java` |

> **Core Principle**: If a type only makes sense in the context of another type, keep them together.
> If a type is used by multiple bounded contexts, place it in the shared/common module.

---

## Common Mistakes

### ❌ DON'T: Create separate enum file for domain-specific status

```java
// File: ProductStatus.java - Don't do this!
public enum ProductStatus {
    DRAFT, ACTIVE, INACTIVE;
}
```

### ❌ DON'T: Put all enums in one file

```java
// File: Enums.java - Don't do this!
public class Enums {
    public enum ProductStatus { ... }
    public enum UserStatus { ... }
    public enum OrderStatus { ... }
}
```

### ❌ DON'T: DTOs inside entities

```java
// DON'T - DTO belongs in Application Service layer
@Entity
public class User {
    public record UserDTO(...) { }  // WRONG location!
}
```

### ❌ DON'T: Put shared value objects in a specific bounded context

```java
// DON'T - Money should be in _shared/domain/vo/, not banking/domain/vo/
// File: banking/domain/vo/Money.java ❌
```

---

## Resources

- **Related Skills**: jpa-ddd-modeling, java, design-principles