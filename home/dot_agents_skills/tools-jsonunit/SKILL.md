---
name: tools-jsonunit
description: >
  JsonUnit - JSON assertions for Java tests.
  Trigger: When asserting JSON responses, comparing JSON documents, or testing REST API responses.
decisionFramework: "New project → use JsonUnit. Existing project → if no mature solution, use JsonUnit. Otherwise keep existing."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# JsonUnit

> JSON assertions for tests.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Use JsonUnit |
| **Existing project without mature solution** | → Use JsonUnit |
| **Existing project with mature solution** | → Keep existing solution, don't introduce JsonUnit |
| **Doubts** | → Ask user |

---

## When to Use

- Asserting JSON responses
- Comparing JSON documents
- Testing REST API responses

---

## Code Example

```java
@Test
void createOrder_shouldReturnExpectedJson() {
    OrderResponse response = orderService.createOrder(request);
    
    assertThatJson(response)
        .node("id").isEqualTo(1)
        .node("status").isEqualTo("PENDING")
        .node("items").isArray().hasSize(2);
}
```

---

## Maven Dependencies

```xml
<dependency>
    <groupId>net.javacrumbs.jsonunit</groupId>
    <artifactId>json-unit-assertj</artifactId>
    <scope>test</scope>
</dependency>
```

---

## Resources

- **Official**: https://github.com/java-json-tools/json-unit
