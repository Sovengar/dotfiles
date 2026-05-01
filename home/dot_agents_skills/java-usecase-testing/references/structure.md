# Test Structure: Naming Conventions and Organization

This reference covers the fundamental test structure patterns: naming conventions, `@Nested` class organization, and key principles.

---

## Test Naming Conventions

### Golden Rule: Technology-Agnostic Names

Test names must describe **business behavior**, NOT technical details like HTTP status codes or protocol names.

| ❌ WRONG (HTTP-specific) | ✅ CORRECT (Business Language) |
|--------------------------|-------------------------------|
| `should_return_ok_status()` | `a_non_closed_{entity}()` |
| `should_return_201_created()` | `{entity}_is_created()` |
| `should_return_404_not_found()` | `{entity}_not_found()` |
| `should_return_400_bad_request()` | `{field}_has_no_value()` |
| `should_be_rejected_because_invalid_genere()` | `{field}_is_invalid()` |

The JUnit 5 plugin (or similar) transforms method names like `a_non_closed_solicitud_infancia` into readable text.

---

## @Nested Test Class Structure

### Pattern: Should{Action}Given (Happy Path)

For successful scenarios, use nested classes with `Should{Action}Given`:

```java
@Nested
class Should{Action}Given {
  @BeforeEach
  void setUp() {
    when(catalogRepo.get{catalog}ByCodi(any())).thenReturn({catalog}());
  }

  @Test
  void a_non_closed_{entity}() {
    // Given
    var {entity} = a{Entity}()
      .thatHasArrived()
      .thatIsPersistedIn(repo);

    // When
    when.{action}({DEFAULT_EXPEDIENT}, "{code}");

    // Then
    thenVerifyIs{State}({entity});
  }
}
```

### Pattern: ShouldFailGiven (Error Cases)

For failure scenarios:

```java
@Nested
class ShouldFailGiven {
  @Test
  void an_unexisting_{field}_code() {
    // Given
    var {entity} = a{Entity}()
      .thatHasArrived()
      .thatIsPersistedIn(repo);

    // When & Then
    assertThatThrownBy(() -> when.{action}(DEFAULT, "INVALID"))
      .isInstanceOf(IllegalArgumentException.class);
  }

  @Test
  void an_unexisting_{entity}() {
    // Given & When & Then
    assertThatThrownBy(() -> when.{action}("XXXXX", "CODE"))
      .isInstanceOf({Entity}NotFound.class);
  }
}
```

### Standalone Tests (Not Nested)

Not all scenarios fit into happy path or fail categories. Use standalone tests with full business-language names:

```java
@Test
void do_nothing_when_{action}_on_closed_{entity}() {
  var {entity} = a{Entity}()
    .thatHasArrived()
    .thatIsPersistedIn(repo);

  when(catalogRepo.get{catalog}ByCodi(any())).thenReturn({catalog}());

  when.{action}(DEFAULT, "CODE");
  when.{action}(DEFAULT, "CODE"); // Second call should do nothing

  thenVerifyIs{State}({entity});
}

@Test
void should_generate_{field}_when_not_given() {
  // Test behavior that doesn't fit nested pattern
  var generatedKey = when.{action}(requestBuilder.withoutId().build());
  assertThat(generatedKey).isNotNull();
}
```

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

## Key Principles

1. **Technology-agnostic names**: Test names describe business behavior, not HTTP codes
2. **DSL over technical code**: Tests should read like business specifications
3. **Share DSLs between scopes**: Same DSL works for system and unit tests
4. **Fixed + Random data**: Use fixed for deterministic tests, random for robustness
5. **Composition over inheritance**: DSLs compose smaller DSLs
6. **Verify behavior, not implementation**: Test outcomes, not internal calls
7. **Nested for grouping**: Use `@Nested` for happy path (`Should{Action}Given`) and errors (`ShouldFailGiven`)
8. **Standalone for edge cases**: Tests that don't fit nested patterns get full business names

---

## Related References

- [arrange.md](arrange.md) - Test data building (Object Mothers, Data Builders, DSLs)
- [system-test.md](system-test.md) - System/Integration tests
- [web-test.md](web-test.md) - HTTP Controller tests
- [service-test.md](service-test.md) - Application Service tests
- [domain-test.md](domain-test.md) - Domain model tests
