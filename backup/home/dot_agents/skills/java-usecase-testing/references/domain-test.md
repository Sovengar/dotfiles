# Domain Model Tests

Domain model tests verify entity logic, value objects, embedded objects, invariants, and business rules at the domain layer.

---

## What to Test at Domain Level

| Type | Description | Examples |
|------|-------------|----------|
| **Entities** | Objects with identity | `Solicitud`, `Actuacio`, `Persona` |
| **Value Objects** | Immutable objects without identity | `Email`, `PhoneNumber`, `Address`, `Money` |
| **Embedded Objects** | Objects embedded in entities | `DadesContacte`, `Familia`, `PerfilInfant` |
| **Aggregates** | Cluster of related objects | `SolicitudInfancia` with its components |

---

## Entity Test Example

Entities have identity and can change state over time.

```java
class {Entity}Test {

  @Test
  void should_{action}_{entity}_when_{condition}() {
    // Given
    var {entity} = a{Entity}()
      .thatHas{State}()
      .with{Field}({value})
      .build();

    // When
    {entity}.{action}({params});

    // Then
    assertThat({entity}.get{StateField}()).isEqualTo({expectedState});
  }

  @Test
  void should_fail_when_{invalid_condition}() {
    // Given
    var {entity} = a{Entity}()
      .thatHas{State}()
      .with{Field}({invalidValue})
      .build();

    // When & Then
    assertThatThrownBy(() -> {entity}.{action}({params}))
      .isInstanceOf({DomainException}.class)
      .hasMessage("{expected error message}");
  }
}
```

---

## Value Object Test Example

Value Objects are immutable and compared by value, not identity.

```java
class {ValueObject}Test {

  @Test
  void should_create_{value_object}_with_valid_{field}() {
    // When
    var {vo} = {ValueObject}.of("{validValue}");

    // Then
    assertThat({vo}.get{Field}()).isEqualTo("{validValue}");
  }

  @Test
  void should_be_equal_to_another_{value_object}_with_same_value() {
    // Given
    var {vo1} = {ValueObject}.of("{value}");
    var {vo2} = {ValueObject}.of("{value}");

    // Then
    assertThat({vo1}).isEqualTo({vo2});
    assertThat({vo1}.hashCode()).isEqualTo({vo2}.hashCode());
  }

  @ParameterizedTest(name = "{index} => {1}")
  @MethodSource("invalidValueProvider")
  void should_fail_when_{field}_is_invalid({String} {invalidValue}, String expectedMessage) {
    assertThatThrownBy(() -> {ValueObject}.of({invalidValue}))
      .isInstanceOf(IllegalArgumentException.class)
      .hasMessageContaining(expectedMessage);
  }

  static Stream<Arguments> invalidValueProvider() {
    return Stream.of(
      Arguments.of(null, "{field} cannot be null"),
      Arguments.of("", "{field} cannot be empty"),
      Arguments.of("invalid-format", "{field} has invalid format")
    );
  }
}
```

---

## Embedded Object Test Example

Embedded objects are part of an entity but have their own validation logic.

```java
class {EmbeddedObject}Test {

  @Test
  void should_create_{embedded}_with_all_required_fields() {
    // When
    var {embedded} = {Embedded}.create(
      {field1},
      {field2},
      {field3}
    );

    // Then
    assertThat({embedded}.get{Field1}()).isEqualTo({field1});
    assertThat({embedded}.get{Field2}()).isEqualTo({field2});
  }

  @Test
  void should_fail_when_required_{field}_is_null() {
    assertThatThrownBy(() -> {Embedded}.create(
      null,  // Required field
      {field2},
      {field3}
    )).isInstanceOf(NullPointerException.class);
  }

  @Test
  void should_normalize_{field}_on_creation() {
    // When
    var {embedded} = {Embedded}.create("  John  ", {field2}, {field3});

    // Then - whitespace should be trimmed
    assertThat({embedded}.get{Field1}()).isEqualTo("John");
  }
}
```

---

## Parameterized Tests for Multiple Scenarios

Use parameterized tests for multiple input scenarios:

```java
@ParameterizedTest
@CsvSource({
  "{value1}, {expected1}, true",
  "{value2}, {expected2}, true",
  "{invalidValue}, {expectedError}, false"
})
void should_validate_{field}_{scenario}(
    String {input},
    String {expected},
    boolean isValid
) {
  if (isValid) {
    var result = {validator}.validate({input});
    assertThat(result).isEqualTo({expected});
  } else {
    assertThatThrownBy(() -> {validator}.validate({input}))
      .isInstanceOf(ValidationException.class);
  }
}
```

---

## Test Location

```
src/test/java/{package}/domain/model/{entity}/
├── {Entity}Test.java
├── {ValueObject}Test.java
└── {Embedded}Test.java
```

---

## Key Characteristics

1. **No External Dependencies**: Pure domain logic testing
2. **Fastest Tests**: No framework context, no mocks needed
3. **Focused on Invariants**: Verify business rules and constraints
4. **Use Parameterized Tests**: Multiple scenarios with same test method
5. **Domain-Driven**: Tests model the domain behavior

---

## Related References

- [structure.md](structure.md) - Naming conventions and @Nested patterns
- [arrange.md](arrange.md) - Test data building (Object Mothers, Data Builders, DSLs)
- [system-test.md](system-test.md) - System/Integration tests
- [web-test.md](web-test.md) - HTTP Controller tests
- [service-test.md](service-test.md) - Application Service tests
