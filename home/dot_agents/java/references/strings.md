# Strings & Text

## String.format() (Java 8+)

Use when: Formatted strings, locale-aware formatting

```java
// Basic formatting
String message = String.format("Hello, %s!", name);
String number = String.format("%d", 42);

// Width and alignment
String formatted = String.format("|%-10s|%10d|", "Hello", 123);

// Floating point
String price = String.format("%.2f", 99.99);

// Locale-aware
String localized = String.format(Locale.US, "%,d", 1000000);
```

## StringBuilder (Java 8+)

Use when: String concatenation in loops

```java
// DON'T: String concatenation in loop
String result = "";
for (String s : list) {
    result += s;  // Creates new String each iteration!
}

// DO: Use StringBuilder
StringBuilder sb = new StringBuilder();
for (String s : list) {
    if (sb.length() > 0) sb.append(", ");
    sb.append(s);
}
String result = sb.toString();
```

## String.join() (Java 8+)

Use when: Join strings with delimiter

```java
// Join with delimiter
String joined = String.join(", ", "a", "b", "c");  // "a, b, c"

// Join list
String joined = String.join(", ", names);
```

## String.isBlank() (Java 11+)

Use when: Check if string is empty or whitespace

```java
// Before (Java 11)
if (str == null || str.trim().isEmpty()) { }

// After (Java 11)
if (str == null || str.isBlank()) { }
```

## String.strip() (Java 11+)

Use when: Remove leading/trailing whitespace (Unicode-aware)

```java
// trim() only removes ASCII whitespace
// strip() removes all Unicode whitespace

String trimmed = str.strip();

// stripLeading() / stripTrailing()
String leftTrimmed = str.stripLeading();
String rightTrimmed = str.stripTrailing();
```

## String.lines() (Java 11+)

Use when: Split string into stream of lines

```java
// Returns a Stream<String>
List<String> lines = "hello\nworld".lines();
// [hello, world]

// Process line by line
"line1\nline2\nline3".lines()
    .map(String::toUpperCase)
    .forEach(System.out::println);
```

## String.repeat() (Java 11+)

Use when: Repeat string n times

```java
String dashes = "-".repeat(20);  // "--------------------"
String indent = " ".repeat(4);   // "    "
```

## Text Blocks (Java 15+)

Use when: Multi-line strings (SQL, JSON, HTML, etc.)

### Basic Usage
```java
String json = """
{
    "name": "Alice",
    "age": 30
}
""";
```

### With Formatting
```java
String sql = """
    SELECT id, name, email
    FROM users
    WHERE active = true
    ORDER BY name
    """;
```

### With Variable Substitution
```java
String html = """
    <div class="user">
        <h1>%s</h1>
        <p>%s</p>
    </div>
    """.formatted(name, description);
```

### Indentation Control
```java
// Strip leading indentation
String code = """
    public void main() {
        System.out.println("hello");
    }
    """;

// Custom strip margin
String poem = """
    |Roses are red,
    |Violets are blue,
    |Poetry is hard,
    |But so are you.
    """;
```

## Decision Matrix

| Situation | Recommended |
|-----------|-------------|
| Simple concatenation | + operator or StringBuilder |
| Join with delimiter | String.join() |
| Check empty/blank | isBlank() |
| Remove whitespace | strip() |
| Split into lines | lines() |
| Repeat string | repeat() |
| SQL/JSON/HTML | Text Blocks |
| Formatted output | String.format() or Text Blocks |

## Common Patterns

### Trim and Check
```java
if (input != null && !input.strip().isBlank()) {
    // Process non-empty input
}
```

### Build with Text Blocks
```java
String email = """
    Dear %s,
    
    Thank you for your order #%d.
    Total: $%.2f
    
    Best regards
    """.formatted(customerName, orderId, total);
```
