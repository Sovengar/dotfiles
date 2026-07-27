# Custom JUnit Extensions

This document describes the custom JUnit 5 extensions available for testing.

## @ConcurrentTest

**Purpose:** Enable concurrent test execution at class or method level.

**Usage:**
```java
@ConcurrentTest
public class MyConcurrentTests {
    // Tests run in parallel
}
```

**Source Code:** See [`assets/extensions/concurrent-test.java`](assets/extensions/concurrent-test.java)

---

## @CaptureSystemOutput

**Purpose:** Capture System.out and System.err during test execution, useful for verifying console output.

**Usage:**
```java
@CaptureSystemOutput
public class OutputCaptureTest {
    
    @Test
    void testWithOutputCapture(OutputCapture capture) {
        System.out.println("Hello");
        assertThat(capture.toString()).contains("Hello");
    }
}
```

**Source Code:** See [`assets/extensions/capture-system-output.java`](assets/extensions/capture-system-output.java)

---

## @TimeTravel

**Purpose:** Mock `LocalDate`, `LocalTime`, and `LocalDateTime` for time-dependent tests. Uses Mockito's static mocking under the hood.

**Usage:**
```java
@TimeTravel(instant = "2026-01-11T12:00:00Z")
public class TimeSensitiveTest {
    
    @Test
    void testWithFixedTime() {
        // LocalDate.now() returns 2026-01-11
        // LocalTime.now() returns 12:00:00
        // LocalDateTime.now() returns 2026-01-11T12:00:00
    }
}
```

**Options:**
| Option | Type | Default | Description |
|--------|------|---------|--------------|
| `instant` | String | (required) | ISO-8601 timestamp with timezone |
| `strict` | boolean | false | If true, prevents class-level override |

**Source Code:** See [`assets/extensions/time-travel.java`](assets/extensions/time-travel.java)

---

## Meta-annotations for @TimeTravel

Pre-configured `@TimeTravel` annotations for common scenarios:

| Annotation | Instant | Description |
|------------|---------|--------------|
| `@FrozenAtStartOfYear2026` | 2026-01-01T00:00:00Z | Start of year 2026 |
| `@FrozenAtNoonUTC` | 2030-01-01T12:00:00Z | Noon UTC in 2030 |
| `@FrozenAtEpoch` | 1970-01-01T00:00:00Z | Unix epoch |

**Usage:**
```java
@FrozenAtStartOfYear2026
public class Year2026Test {
    // LocalDate.now() returns 2026-01-01
}
```

**Source Code:** See [`assets/extensions/frozen-annotations.java`](assets/extensions/frozen-annotations.java)

---

## @DisableTimeTravel

**Purpose:** Disable `@TimeTravel` for specific tests when it's applied at class level but you want one test to use real time.

**Usage:**
```java
@TimeTravel(instant = "2026-01-01T00:00:00Z")
public class MixedTimeTest {
    
    @Test
    void testWithMockedTime() {
        // Uses mocked time (2026-01-01)
    }
    
    @DisableTimeTravel
    @Test
    void testWithRealTime() {
        // Uses actual system time
    }
}
```

**Source Code:** See [`assets/extensions/frozen-annotations.java`](assets/extensions/frozen-annotations.java)

---

## Requirements

All extensions require:
- JUnit 5 (junit-jupiter)
- Mockito (for `@TimeTravel` static mocking)
- SLF4J + Logback (for `@TimeTravel` logging)
