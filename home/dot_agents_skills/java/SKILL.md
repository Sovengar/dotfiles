---
name: java
description: >
  Java development best practices with version-specific features.
  Trigger: When developing in Java or using Java-related skills.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Java Development Best Practices

This skill provides version-specific guidance for Java development. When you use a specific Java version, apply ALL features from that version AND all previous LTS versions.

## Version Loading Logic

When the user specifies or implies a Java version, apply features from that version AND all earlier LTS versions:

| Specified Version | Features to Apply |
|-------------------|-------------------|
| Java 8 | Java 8 features only |
| Java 11 | Java 8 + Java 11 features |
| Java 17 | Java 8 + Java 11 + Java 17 features |
| Java 21 | Java 8 + Java 11 + Java 17 + Java 21 features |

---

## Critical Patterns

### Always Apply

- **Constructor Injection**: Use constructor-based dependency injection
- **Immutability**: Prefer immutable objects (final fields, no setters)
- **Try-with-resources**: Always use try-with-resources for AutoCloseable
- **Effective Java Items**: Follow Effective Java (Joshua Bloch) principles
- **logging**: Use SLF4J with parameterized logging

### Version-Specific Decision Table

> **Note**: These are guidelines, NOT rules. Choose based on your specific context.
> Consider: library compatibility, team expertise, performance needs, and readability.

| Feature | Java 8 | Java 11 | Java 17 | Java 21 | When to Use |
|---------|--------|---------|---------|---------|-------------|
| **Data Objects** | | | | | |
| DTO (class with getters/setters) | ✅ | ✅ | ✅ | ✅ | Legacy systems, JPA entities, libraries needing setters |
| Lombok @Data/@Value | ❌ | ✅ | ✅ | ✅ | Quick prototyping, clean code, no reflection issues |
| Java Record | ❌ | ❌ | ✅ | ✅ | Immutable DTOs, data carriers, internal APIs |
| **Date/Time API** | | | | | |
| java.time (LocalDate, Instant, Duration) | ✅ | ✅ | ✅ | ✅ | Always prefer over Date/Calendar |
| **Collections** | | | | | |
| for loop (classic) | ✅ | ✅ | ✅ | ✅ | When you need index, need to break early, or max performance |
| forEach + lambda | ✅ | ✅ | ✅ | ✅ | Simple iteration, no early exit needed |
| Stream API | ✅ | ✅ | ✅ | ✅ | Data transformation, filtering, aggregations |
| List.of(), Set.of(), Map.of() | ❌ | ✅ | ✅ | ✅ | Small fixed collections, constants |
| Immutable Collections | ❌ | ✅ | ✅ | ✅ | When collection must not change |
| removeIf(), replaceAll(), sort() | ✅ | ✅ | ✅ | ✅ | In-place collection modifications |
| Collection.toList() | ❌ | ✅ | ✅ | ✅ | Immutable copy of collection |
| Stream.takeWhile/dropWhile | ❌ | ❌ | ✅ | ✅ | When you need early stream termination |
| Stream.ofNullable() | ❌ | ❌ | ✅ | ✅ | Avoid null in streams |
| Sequenced Collections | ❌ | ❌ | ❌ | ✅ | When order/first/last matter |
| **Functional Programming** | | | | | |
| Lambda expressions | ✅ | ✅ | ✅ | ✅ | Short callbacks, functional interfaces |
| Method references | ✅ | ✅ | ✅ | ✅ | When existing method matches signature |
| Functional interfaces (java.util.function) | ✅ | ✅ | ✅ | ✅ | Predicate, Function, Supplier, Consumer, etc. |
| Constructor references | ✅ | ✅ | ✅ | ✅ | ClassName::new for factory patterns |
| **Null Safety** | | | | | |
| Optional for return types | ✅ | ✅ | ✅ | ✅ | Use for single-value returns, NOT as field type |
| Optional orElseThrow() | ❌ | ✅ | ✅ | ✅ | When null is truly exceptional |
| Optional ifPresentOrElse() | ❌ | ✅ | ✅ | ✅ | Handle both present and empty cases |
| Optional stream() | ❌ | ✅ | ✅ | ✅ | Combine Optional with Stream operations |
| **Strings & Text** | | | | | |
| String.format() | ✅ | ✅ | ✅ | ✅ | Formatted strings, locale-aware formatting |
| StringBuilder | ✅ | ✅ | ✅ | ✅ | String concatenation in loops |
| String.join() | ✅ | ✅ | ✅ | ✅ | Join strings with delimiter |
| String.isBlank() | ❌ | ✅ | ✅ | ✅ | Check if string is empty or whitespace |
| String.strip() | ❌ | ✅ | ✅ | ✅ | Remove leading/trailing whitespace (Unicode-aware) |
| String.lines() | ❌ | ✅ | ✅ | ✅ | Split string into stream of lines |
| String.repeat() | ❌ | ✅ | ✅ | ✅ | Repeat string n times |
| Text Blocks | ❌ | ❌ | ✅ (Java 15) | ✅ | Multi-line strings (SQL, JSON, HTML) |
| **Pattern Matching** | | | | | |
| Pattern Matching for instanceof | ❌ | ❌ | ✅ | ✅ | Type checking + casting in one step |
| Record Patterns | ❌ | ❌ | ❌ | ✅ | Nested data extraction |
| Pattern Matching for switch | ❌ | ❌ | ❌ | ✅ | Complex type-based branching |
| **Control Flow** | | | | | |
| Switch Expression | ❌ | ❌ | ✅ | ✅ | Cleaner than traditional switch |
| Multi-label case | ❌ | ❌ | ✅ | ✅ | Grouping related cases |
| yield | ❌ | ❌ | ✅ | ✅ | Return value from switch expression (vs return statement) |
| **Interfaces** | | | | | |
| Default methods | ✅ | ✅ | ✅ | ✅ | API evolution, optional methods |
| Static methods in interfaces | ✅ | ✅ | ✅ | ✅ | Utility methods, factory methods |
| Private methods in interfaces | ❌ | ✅ | ✅ | ✅ | Code organization, shared logic in interfaces |
| Sealed interfaces | ❌ | ❌ | ✅ | ✅ | When you need exhaustive type matching |
| **Classes** | | | | | |
| Sealed classes | ❌ | ❌ | ✅ | ✅ | Finite type hierarchy, security |
| Permits clause | ❌ | ✅ | ✅ | ✅ | Define allowed subclasses |
| Non-sealed | ❌ | ❌ | ✅ | ✅ | Allow subclassing later |
| **I/O** | | | | | |
| Base64 encoding | ✅ | ✅ | ✅ | ✅ | Encoding/decoding binary data |
| Files.list(), walk(), find() | ✅ | ✅ | ✅ | ✅ | Directory traversal, file finding |
| Files.readString()/writeString() | ❌ | ✅ | ✅ | ✅ | Simple file read/write |
| BufferedReader.lines() | ✅ | ✅ | ✅ | ✅ | Stream lines from file |
| **Concurrency** | | | | |
| CompletableFuture | ✅ | ✅ | ✅ | ✅ | Async programming, composition |
| thenApply, thenCompose, thenCombine | ✅ | ✅ | ✅ | ✅ | Chaining async operations |
| Parallel streams | ✅ | ✅ | ✅ | ✅ | CPU-bound parallel processing |
| Virtual Threads | ❌ | ❌ | ❌ | ✅ | High-throughput IO, not CPU-bound |
| StampedLock | ✅ | ✅ | ✅ | ✅ | Optimistic read with write fallback |
| LongAdder/DoubleAdder | ✅ | ✅ | ✅ | ✅ | High-contention counters |
| **Type Inference** | | | | |
| Var (local variable) | ❌ | ✅ | ✅ | ✅ | When type is obvious from RHS |
| **Annotations** | | | | |
| Repeatable annotations | ✅ | ✅ | ✅ | ✅ | Multiple annotations of same type |
| Type annotations | ✅ | ✅ | ✅ | ✅ | Annotations on type use (e.g., @NonNull List<String>) |
| **Modules** | | | | |
| module-info.java | ❌ | ✅ | ✅ | ✅ | When you need strong encapsulation |
| requires, exports | ❌ | ✅ | ✅ | ✅ | Module declaration |
| opens (reflection) | ❌ | ✅ | ✅ | ✅ | Reflection access for frameworks |

---

## Code Examples

> See [references/](references/) for detailed code examples organized by topic.

Quick examples:
- **Data Objects**: [references/data-objects.md](references/data-objects.md) - DTOs, Lombok, Records
- **Null Safety**: [references/null-safety.md](references/null-safety.md) - Optional patterns
- **Control Flow**: [references/control-flow.md](references/control-flow.md) - Switch expressions
- **Patterns**: [references/patterns.md](references/patterns.md) - Pattern matching, Sealed classes
- **Concurrency**: [references/concurrency.md](references/concurrency.md) - CompletableFuture, Virtual Threads
- **Collections**: [references/collections.md](references/collections.md) - Stream enhancements, Sequenced Collections
- **Strings**: [references/strings.md](references/strings.md) - Text Blocks, String methods

---

## When to Use Older Features in Newer Java

| Feature | Use Even in Java 21 When... |
|---------|----------------------------|
| for loop (classic) | You need index access, need to break early, or maximum performance |
| Traditional DTO | Working with JPA, serialization frameworks, or libraries that need setters |
| Stream API | Complex data pipelines, aggregations, NOT simple iterations |
| Regular threads | You need thread locals or specific thread behavior |
| ArrayList over SequencedCollection | Working with existing APIs that expect List |

---

## Common Mistakes & Antipatterns

> Each reference file includes a "Common Mistakes" and "Antipatterns" section.

| Topic | Key Mistakes |
|-------|-------------|
| **Collections** | forEach mutation, streams for simple iteration, nested streams |
| **Null Safety** | Optional as field, isPresent()+get(), orElse() with expensive calls |
| **Data Objects** | Records as JPA entities, exposing entities to API |
| **Switch/Patterns** | Switch without default, forgetting null case |
| **Concurrency** | Virtual Threads for CPU-bound, using Thread instead of Executor, **adding async when redesign could avoid it** |

---

## Key Philosophy: Sometimes No Concurrency is Best

> "The best concurrency solution is often to not need concurrency at all."

Sometimes redesigning the workflow (e.g., deferred processing) is better than adding async code. See [references/concurrency.md](references/concurrency.md) for the course enrollment example.

---

## Commands

```bash
# Check Java version
java -version

# Compile and run
javac Main.java
java Main

# Run with specific version
java --enable-preview -jar app.jar
```

---

## Resources

- **Code Examples**: See [references/](references/) for detailed examples
- **Templates**: See [assets/](assets/) for version-specific templates
- **Documentation**: [Oracle Java Docs](https://docs.oracle.com/en/java/javase/)
- **Effective Java**: Joshua Bloch's book for best practices
