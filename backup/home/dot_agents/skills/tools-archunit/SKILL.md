---
name: tools-archunit
description: >
  ArchUnit - enforce architecture rules in Java tests.
  Trigger: When enforcing architecture constraints, layer dependencies, or naming conventions in code.
decisionFramework: "New project → use ArchUnit. Existing project → if no mature solution, use ArchUnit. Otherwise keep existing."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# ArchUnit

> Enforce architecture rules in tests.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Use ArchUnit |
| **Existing project without mature solution** | → Use ArchUnit |
| **Existing project with mature solution** | → Keep existing solution, don't introduce ArchUnit |
| **Doubts** | → Ask user |

---

## When to Use

- Enforcing layer dependencies
- Naming conventions
- Package structure rules
- Preventing cyclic dependencies

---

## Code Examples

```java
@ArchTest
class ArchitectureTest {
    
    @ArchTest
    static final ArchRule servicesShouldNotAccessControllers = 
        noClasses()
            .that().resideInAPackage("..service..")
            .should().accessClasses()
            .that().resideInAPackage("..controller..");
    
    @ArchTest
    static final ArchRule domainModelsShouldBeImmutable = 
        classes()
            .that().haveNameMatching(".*Entity")
            .should().beImmutable();
}
```

---

## Maven Dependencies

```xml
<dependency>
    <groupId>com.tngtech.archunit</groupId>
    <artifactId>archunit-junit5</artifactId>
    <scope>test</scope>
</dependency>
```

---

## Resources

- **Official**: https://www.archunit.org/
