---
name: tools-junit
description: >
  JUnit 5 best practices, including data-driven tests and custom annotations.
  Trigger: When writing Java unit tests with JUnit 5.
tags: [java, junit, testing, junit5]
triggers: [tools-junit, java-junit, junit, unit-test]
---

# JUnit 5 Best Practices

> Best practices for writing JUnit 5 unit tests in Java.

---

## Data-Driven (Parameterized) Tests

- Use `@ParameterizedTest` to mark a method as a parameterized test.
- Use `@ValueSource` for simple literal values (strings, ints, etc.).
- Use `@MethodSource` to refer to a factory method that provides test arguments as a `Stream`, `Collection`, etc.
- Use `@CsvSource` for inline comma-separated values.
- Use `@CsvFileSource` to use a CSV file from the classpath.
- Use `@EnumSource` to use enum constants.

## Test Organization

- Group tests by feature or component using packages.
- Use `@Tag` to categorize tests (e.g., `@Tag("fast")`, `@Tag("integration")`).
- Use `@TestMethodOrder(MethodOrderer.OrderAnnotation.class)` and `@Order` to control test execution order when strictly necessary, i.e Epics or Sagas.
- Use `@Disabled` to temporarily skip a test method or class, providing a reason.
- Use `@Nested` to group tests in a nested inner class for better organization and structure.

## Assertions

- Use AssertJ (`assertThat(...).is...`).
- Group related assertions with `assertAll` to ensure all assertions are checked before the test fails.
- Use descriptive messages in assertions to provide clarity on failure.

## Custom Annotations

JUnit 5 supports custom annotations through the Extension API. See [`references/extensions.md`](references/extensions.md) for:

- `@ConcurrentTest` — Enable concurrent test execution
- `@CaptureSystemOutput` — Capture System.out/err during tests
- `@TimeTravel` — Mock time (LocalDate, LocalTime, LocalDateTime)
- Meta-annotations: `@FrozenAtStartOfYear2026`, `@FrozenAtNoonUTC`, `@FrozenAtEpoch`
- `@DisableTimeTravel` — Disable time mocking for specific tests

**Source code for extensions:** See [`assets/extensions/`](assets/extensions/)
