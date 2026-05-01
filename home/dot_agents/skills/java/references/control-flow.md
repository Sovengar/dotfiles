# Switch Expressions

## Traditional Switch (Java 8)

Use when: You need fall-through behavior or simple statement groups

```java
public int getDaysInMonth(String month) {
    switch (month) {
        case "January":
        case "March":
        case "May":
        case "July":
        case "August":
        case "October":
        case "December":
            return 31;
        case "February":
            return 28;
        case "April":
        case "June":
        case "September":
        case "November":
            return 30;
        default:
            throw new IllegalArgumentException("Invalid month: " + month);
    }
}
```

## Switch Expression (Java 14+)

Use when: You need to return a value, cleaner code

```java
public int getDaysInMonth(String month) {
    return switch (month) {
        case "January", "March", "May", "July", "August", "October", "December" -> 31;
        case "February" -> 28;
        case "April", "June", "September", "November" -> 30;
        default -> throw new IllegalArgumentException("Invalid month: " + month);
    };
}
```

## Switch Expression with yield (Java 14+)

Use when: You need multiple statements in a case

```java
public String getDescription(String month) {
    return switch (month) {
        case "January" -> {
            String desc = "The first month";
            yield "January: " + desc;
        }
        case "February" -> {
            yield "February: Shortest month";
        }
        default -> {
            yield month;
        }
    };
}
```

## Pattern Matching for Switch (Java 21+)

Use when: Complex type-based branching

### Type Patterns
```java
public String describe(Object obj) {
    return switch (obj) {
        case null -> "Null value";
        case Integer i -> "Integer: " + i;
        case String s -> "String with " + s.length() + " chars";
        case Number n -> "Number: " + n.doubleValue();
        default -> "Unknown: " + obj.getClass().getSimpleName();
    };
}
```

### Record Patterns
```java
public record Point(int x, int y) {}

public String describePoint(Object obj) {
    return switch (obj) {
        case Point(int x, int y) -> "Point at (" + x + ", " + y + ")";
        default -> "Not a point";
    };
}
```

### Guarded Patterns
```java
public String classify(Object obj) {
    return switch (obj) {
        case String s when s.isBlank() -> "Blank string";
        case String s when s.length() > 10 -> "Long string";
        case String s -> "String: " + s;
        case Integer i when i > 0 -> "Positive integer";
        case Integer i -> "Non-positive integer";
        default -> "Unknown type";
    };
}
```

## Decision Matrix

| Situation | Recommended |
|-----------|-------------|
| Need fall-through | Traditional switch |
| Return a value | Switch expression |
| Complex type branching | Pattern matching for switch |
| Multiple statements per case | Switch expression with yield |

## Common Mistakes

### ❌ DON'T: Switch without default when not exhaustive
```java
// BAD - may not compile in future if new types added
return switch (shape) {
    case Circle c -> c.area();
    case Rectangle r -> r.area();
    // Missing Square - won't compile if added to sealed hierarchy
};

// GOOD - use sealed class for exhaustiveness
public sealed class Shape permits Circle, Rectangle, Square { }
```

### ❌ DON'T: Using yield when arrow is clearer
```java
// Unnecessary complexity
case "a" -> {
    yield "vowel";
}

// Better with arrow
case "a" -> "vowel";
```

### ❌ DON'T: Forgetting null case
```java
// BAD - throws NullPointerException
return switch (str) {
    case "a" -> "vowel";
    default -> str.toUpperCase();
};

// GOOD - handle null explicitly
return switch (str) {
    case null -> "null input";
    case "a" -> "vowel";
    default -> str.toUpperCase();
};
```

## Antipatterns

| Antipattern | Why Bad | Better Alternative |
|-------------|---------|-------------------|
| Switch without default | Not exhaustive, NPE | Use default or sealed class |
| Complex yield blocks | Hard to read | Extract to method |
| Forgetting null case | NPE | Explicit null case |

## Null Handling

```java
// Java 17+: handle null explicitly
public String process(String input) {
    return switch (input) {
        case null -> "Null input";
        case "a", "e", "i", "o", "u" -> "Vowel";
        default -> "Consonant";
    };
}
```
