---
name: java-usecase-testing
description: >
  Java test conventions for use case testing with DSL pattern, Object Mothers, and Data Builders.
  Trigger: When creating tests following the project's use case-based test structure.
tags: [java, testing, usecase, dsl, object-mothers, data-builders]
triggers: [java-usecase-testing, java-usecase-test, dsl-testing, java-testing]
---

# Java Test Conventions: Use Case Testing with DSL Pattern

This skill provides testing conventions organized by test scope, following progressive disclosure.
Load specific references based on the type of test you're writing.

---

## Test Scopes

| Scope | Reference | Description |
|-------|-----------|-------------|
| **General** | [references/structure.md](references/structure.md) | Naming conventions, @Nested classes, key principles |
| **Test Data** | [references/arrange.md](references/arrange.md) | Object Mothers, Data Builders, Fixtures |
| **Integration** | [references/system-test.md](references/system-test.md) | System tests with real DB |
| **Web Layer** | [references/web-test.md](references/web-test.md) | HTTP Controller, Contract, Validation |
| **Service** | [references/service-test.md](references/service-test.md) | Application Service tests |
| **Domain** | [references/domain-test.md](references/domain-test.md) | Domain model tests |

---

## Quick Start

1. **Start here**: Read [references/structure.md](references/structure.md) for naming and organization patterns
2. **Build test data**: Use [references/arrange.md](references/arrange.md) for Object Mothers and Data Builders
3. **Choose your scope**: Select the appropriate reference from the table above

---

## Test Scope Structure

Each use case is tested at multiple levels, following the testing pyramid:

| Test Type | Suffix | Scope | Description | Speed |
|-----------|--------|-------|-------------|-------|
| **System** | `*SystemTest.java` | Full integration | Tests entire flow with real DB, mocked external services | Slow |
| **HTTP Controller** | `*HttpControllerTest.java` | Web layer | Tests REST endpoint with mocked service | Fast |
| **Application Service** | `*Test.java` | Application layer | Tests use case logic with mocked dependencies | Fast |
| **Domain** | `*Test.java` in `domain/model/` | Domain model | Tests domain logic, validation, invariants | Fastest |

---

## Test File Naming Convention

```
src/test/java/{package}/{layer}/
├── application/
│   └── {usecase}/
│       ├── {Usecase}SystemTest.java      # Integration test
│       ├── {Usecase}HttpControllerTest.java  # Web layer test
│       └── {Usecase}Test.java            # Application service test
├── queries/
│   └── {query}/
│       ├── {Query}SystemTest.java        # Query integration test
│       ├── {Query}HttpControllerTest.java # Query HTTP test
│       └── {Query}Test.java              # Query handler test
└── domain/
    └── model/
        └── {entity}/
            └── {Entity}Test.java          # Domain model tests
```

---

## Commands

```bash
# Run only fast tests (unit tests)
mvn test -Dgroups=fast

# Run only integration tests
mvn test -Dgroups=integration

# Run tests excluding robustness/fuzz
mvn test -Dgroups='!robustness'

# Run specific use case tests
mvn test -Dtest="*Usecase*SystemTest"
```

---

## Resources

- **Reference Tests**: See `src/test/java/{package}/{module}/` for working examples from this project
