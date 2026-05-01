---
name: tools-jqwik
description: >
  JQwik - property-based testing for Java.
  Trigger: When doing property-based testing, generating test cases, or testing mathematical properties.
decisionFramework: "New project → use JQwik. Existing project → if no mature solution, use JQwik. Otherwise keep existing."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# JQwik

> Property-based testing for Java.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Use JQwik |
| **Existing project without mature solution** | → Use JQwik |
| **Existing project with mature solution** | → Keep existing solution, don't introduce JQwik |
| **Doubts** | → Ask user |

---

## When to Use

- Property-based testing
- Generating hundreds of test cases
- Testing mathematical properties

---

## Code Example

```java
@Property
void addNumbers_shouldBeCommutative(@ForAll int a, @ForAll int b) {
    assertThat(a + b).isEqualTo(b + a);
}

@Property
void orderQuantity_shouldBePositive(@ForAll("randomPositiveInt") int qty) {
    assumeThat(qty).isGreaterThan(0);
    Order order = new Order(qty, "PENDING");
    assertThat(order.getQuantity()).isEqualTo(qty);
}
```

---

## Maven Dependencies

```xml
<dependency>
    <groupId>net.jqwik</groupId>
    <artifactId>jqwik-junit5</artifactId>
    <scope>test</scope>
</dependency>
```

---

## Resources

- **Official**: https://jqwik.net/
