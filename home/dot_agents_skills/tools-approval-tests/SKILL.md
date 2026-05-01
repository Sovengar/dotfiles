---
name: tools-approval-tests
description: >
  ApprovalTests - snapshot testing for Java.
  Trigger: When testing complex objects, serialization, or needing snapshot tests.
decisionFramework: "New project → use ApprovalTests. Existing project → if no mature solution, use ApprovalTests. Otherwise keep existing."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# ApprovalTests

> Snapshot testing.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Use ApprovalTests |
| **Existing project without mature solution** | → Use ApprovalTests |
| **Existing project with mature solution** | → Keep existing solution, don't introduce ApprovalTests |
| **Doubts** | → Ask user |

---

## When to Use

- Testing complex object serialization
- Snapshot testing
- Verifying output consistency

---

## Code Example

```java
@Test
void serializeOrder_shouldMatchApproved() {
    Order order = new Order(1L, "PENDING", List.of(item1, item2));
    Approvals.verifyJson(objectMapper.writeValueAsString(order));
}
```

---

## Maven Dependencies

```xml
<dependency>
    <groupId>com.approvaltests</groupId>
    <artifactId>approvaltests</artifactId>
    <scope>test</scope>
</dependency>
```

---

## Resources

- **Official**: https://approvaltests.com/
