# Mocking Guidelines

> When and how to use mocks in tests.

---

## When to Use Mocks

Use mocks for:

| Scenario | Example | Why |
|----------|---------|-----|
| **External dependencies** | API calls, DB queries | Isolate from external systems |
| **Slow services** | HTTP calls, file I/O | Keep tests fast |
| **Unreliable systems** | Third-party APIs | Avoid flakiness |
| **Non-deterministic** | Random generators, time | Control test environment |
| **Expensive setup** | Large data loading | Reduce test setup time |

---

## When NOT to Use Mocks

Avoid mocks for:

| Scenario | Example | Why |
|----------|---------|-----|
| **Domain logic** | Business rules, calculations | Test real behavior, not mock |
| **Simple cases** | Basic CRUD operations | Real implementation is simple enough |
| **When real implementations exist** | In-memory repositories | Real is better than mock |
| **Internal classes** | Utility classes, helpers | Implementation details change often |

---

## Where to Place Mocks (CRITICAL)

### The Stable API Layer Rule

> **Mock at the boundary where the contract is stable, NOT at unstable internal classes.**

```
┌─────────────────────────────────────────────────────────┐
│                    YOUR CODE                             │
├─────────────────────────────────────────────────────────┤
│  Controller (stable API)  ←───────────────── MOCK HERE │
│        ↓                                               │
│  Service (business logic)  ← internal, avoid mocking   │
│        ↓                                               │
│  Repository (data access) ← internal, avoid mocking   │
│        ↓                                               │
│  Database (external)      ← MOCK HERE                 │
└─────────────────────────────────────────────────────────┘
```

### ❌ Wrong: Mocking Internal Classes

```java
// ❌ BAD: Mocking unstable internal class
class UserServiceTest {
    @Mock
    private UserValidator validator; // Internal class - unstable
    
    @Test
    void testValidate() {
        when(validator.validate(any())).thenReturn(true);
        // This test breaks when implementation changes
    }
}
```

### ✅ Correct: Mocking Stable Boundaries

```java
// ✅ GOOD: Mock at stable API boundary
class UserControllerTest {
    @Mock
    private UserService userService; // Stable API interface
    
    @Mock
    private ExternalEmailService emailService; // External dependency
    
    @Test
    void testCreateUser() {
        when(userService.create(any())).thenReturn(user);
        // Test the behavior, not the implementation
    }
}
```

---

## Mocking Rules

### Rule 1: Don't Mock What You're Testing

```java
// ❌ BAD
@Test
void test_service() {
    when(repository.findById(1)).thenReturn(entity); // Mocking the thing under test
    Service service = new Service(repository);
    // This tests nothing
}

// ✅ GOOD - Test real behavior
@Test
void test_service() {
    Service service = new Service(realRepository);
    // Tests actual implementation
}
```

### Rule 2: Mock Interfaces, Not Implementations

```java
// ❌ RISKY - Mocking concrete class
@Mock
private UserRepositoryImpl repository;

// ✅ BETTER - Mock interface
@Mock
private UserRepository repository;
```

### Rule 3: Use Test Doubles When Possible

| Type | Use When | Example |
|------|----------|---------|
| **Dummy** | Fill parameters | Empty objects for unused params |
| **Fake** | Simple implementation | InMemoryRepository |
| **Stub** | Provide responses | Stubbed responses |
| **Mock** | Verify interactions | Verify method called |
| **Spy** | Partial mocking | Wrap real object |

---

## Alternatives to Mocks

### Use Real Implementations (In-Memory)

```java
// ✅ BETTER than mocking: Real in-memory implementation
@Test
void test_with_real_repository() {
    InMemoryUserRepository repo = new InMemoryUserRepository();
    UserService service = new UserService(repo);
    
    service.create(user);
    assertThat(repo.findAll()).hasSize(1);
}
```

### Use Test Containers

```java
// ✅ GOOD: Real database in container
@Test
void test_with_real_db() {
    PostgreSQLContainer db = new PostgreSQLContainer();
    UserRepository repo = new PostgresUserRepository(db.getJdbcUrl());
    // Test against real database
}
```

---

## Summary

| DO | DON'T |
|----|-------|
| Mock external dependencies | Mock domain logic |
| Mock at stable API boundaries | Mock internal classes |
| Use test doubles when possible | Mock everything |
| Use in-memory alternatives | Replace all implementations |
| Test behavior, not mocks | Assert on mock interactions |
