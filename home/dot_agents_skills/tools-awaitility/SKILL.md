---
name: tools-awaitility
description: >
  Awaitility - testing asynchronous operations in Java.
  Trigger: When testing async code, event-driven systems, or verifying background processing completes.
decisionFramework: "New project → use Awaitility. Existing project → if no mature solution, use Awaitility. Otherwise keep existing."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Awaitility

> Test asynchronous operations with fluent DSL.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Use Awaitility |
| **Existing project without mature solution** | → Use Awaitility |
| **Existing project with mature solution** | → Keep existing solution, don't introduce Awaitility |
| **Doubts** | → Ask user |

---

## When to Use

- Testing async methods
- Verifying background processing completes
- Testing event-driven systems
- Waiting for conditions in concurrent code
- Testing scheduled tasks

---

## Code Examples

### Basic Async Test

```java
@Test
void orderProcessed_shouldCompleteAsync() {
    orderService.processOrder(orderId);
    
    await()
        .atMost(5, SECONDS)
        .until(() -> orderRepo.findById(orderId)
            .map(Order::getStatus)
            .orElse(null) == COMPLETED);
    
    Order order = orderRepo.findById(orderId).orElseThrow();
    assertThat(order.getStatus()).isEqualTo(COMPLETED);
}
```

### With Condition

```java
@Test
void shouldWaitForEvent() {
    eventPublisher.publish(new OrderCreatedEvent(orderId));
    
    await()
        .atMost(10, SECONDS)
        .pollInterval(500, MILLISECONDS)
        .untilAsserted(() -> 
            verify(eventHandler).handle(any())
        );
}
```

---

## Maven Dependencies

```xml
<dependency>
    <groupId>org.awaitility</groupId>
    <artifactId>awaitility</artifactId>
    <scope>test</scope>
</dependency>
```

---

## Resources

- **Official**: https://github.com/awaitility/awaitility
- **Documentation**: https://github.com/awaitility/awaitility/wiki
