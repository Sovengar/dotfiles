---
name: tools-lombok
description: >
  Lombok - reduce boilerplate code in Java with annotations.
  Trigger: When writing Java code, want to reduce getters/setters/constructors, or need builder patterns.
decisionFramework: "New project → use Lombok. Existing project → if no mature solution, use Lombok. Otherwise keep existing. Note: If project uses Java 17+ with Records, consider if Lombok is still necessary."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Lombok

> Reduce Java boilerplate with annotations.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Use Lombok |
| **Existing project without mature solution** | → Use Lombok |
| **Existing project with mature solution** | → Keep existing solution |
| **Using Java 17+ with Records** | → Consider if Lombok is still needed (Records may replace @Value) |
| **Doubts** | → Ask user |

---

## When to Use

- Reducing getter/setter boilerplate
- Creating builders for objects
- Need constructors with specific parameters
- Implementing logging with @Slf4j
- Creating immutable value objects

---

## Critical Patterns

### Annotations Reference

| Annotation | Generates |
|------------|------------|
| `@Getter` | getters |
| `@Setter` | setters |
| `@NoArgsConstructor` | no-arg constructor |
| `@AllArgsConstructor` | all-args constructor |
| `@RequiredArgsConstructor` | constructor with final/@NonNull fields |
| `@Data` | @Getter + @Setter + @ToString + @EqualsAndHashCode |
| `@Value` | immutable class |
| `@Builder` | builder pattern |
| `@Slf4j` | logger field |
| `@Log4j2` | logger field |
| `@BuilderDefault` | builder with default values |

---

## Code Examples

### Basic Entity

```java
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    @GeneratedValue
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    private String email;
    
    @Builder.Default
    private boolean active = true;
}
```

### Value Object (Immutable)

```java
@Value
public class Money {
    BigDecimal amount;
    Currency currency;
}

// Generates:
// - private final fields
// - private constructor
// - getters (not setters)
// - equals/hashCode/toString
// - builder (with @Builder)
```

### Service with Logging

```java
@Service
@Slf4j
public class UserService {
    
    public void createUser(User user) {
        log.info("Creating user: {}", user.getName());
        // ...
    }
}
```

---

## Maven Dependencies

```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <scope>provided</scope>
</dependency>
```

---

## Annotation Processor Configuration

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.11.0</version>
    <configuration>
        <annotationProcessorPaths>
            <path>
                <groupId>org.projectlombok</groupId>
                <artifactId>lombok</artifactId>
                <version>${lombok.version}</version>
            </path>
        </annotationProcessorPaths>
    </configuration>
</plugin>
```

---

## Commands

```bash
# No specific commands
# Lombok works at compile time
# Use IDE plugin for better experience:
# - IntelliJ: Settings → Plugins → Lombok
# - VS Code: Install Lombok extension
```

---

## Best Practices

| Do | Don't |
|----|-------|
| Use `@Data` for JPA entities | Use `@Data` on mutable entities |
| Use `@Value` for DTOs/value objects | Use `@Value` when you need setters |
| Use `@Builder.Default` for default values | Forget to initialize with `= value` |
| Use `@RequiredArgsConstructor` with `@Autowired` | Mix constructor and setter injection |

---

## Resources

- **Official**: https://projectlombok.org/
- **Cheatsheet**: https://projectlombok.org/cheatsheet
