---
name: tools-querydsl
description: >
  QueryDSL - type-safe query building for Java. Alternative to JPQL strings.
  Trigger: When writing database queries in Java, need type-safe queries, or working with JPA.
decisionFramework: "New project → use QueryDSL. Existing project → if no mature solution, use QueryDSL. Otherwise keep existing."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# QueryDSL

> Type-safe query building for Java.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Use QueryDSL |
| **Existing project without mature solution** | → Use QueryDSL |
| **Existing project with mature solution** | → Keep existing solution, don't introduce QueryDSL |
| **Doubts** | → Ask user |

---

## When to Use

- Writing database queries in Java/JPA
- Need type-safe queries instead of JPQL strings
- Building dynamic queries based on conditions
- Working with Spring Data JPA
- Need compile-time checking of query correctness

---

## Critical Patterns

### vs JPQL Strings

| ❌ JPQL Strings | ✅ QueryDSL |
|----------------|-------------|
| `SELECT o FROM Order o WHERE o.status = :status` | `queryFactory.selectFrom(order).where(order.status.eq(status))` |
| No compile-time checking | Type-safe, IDE autocompletion |
| Error-prone (typos, refactoring) | Refactoring-safe |
| String concatenation for dynamic queries | Fluent API |

### Basic Query

```java
QOrder order = QOrder.order;

// Select all pending orders
List<Order> orders = queryFactory.selectFrom(order)
    .where(order.status.eq(OrderStatus.PENDING))
    .fetch();

// Select with multiple conditions
List<Order> orders = queryFactory.selectFrom(order)
    .where(order.status.eq(OrderStatus.PENDING)
        .and(order.createdAt.after(fiveDaysAgo)))
    .fetch();
```

### Join Queries

```java
QOrder order = QOrder.order;
QCustomer customer = QCustomer.customer;

List<Order> orders = queryFactory.selectFrom(order)
    .join(order.customer, customer)
    .where(customer.email.endsWith("@company.com"))
    .fetch();
```

### Subqueries

```java
QOrder order = QOrder.order;
QOrderItem item = QOrderItem.orderItem;

List<Product> products = queryFactory.selectFrom(product)
    .where(product.id.in(
        JPAExpressions.select(item.product.id)
            .from(item)
            .where(item.quantity.gt(10))
    ))
    .fetch();
```

---

## Maven Dependencies

```xml
<dependency>
    <groupId>com.querydsl</groupId>
    <artifactId>querydsl-jpa</artifactId>
    <version>${querydsl.version}</version>
</dependency>
<dependency>
    <groupId>com.querydsl</groupId>
    <artifactId>querydsl-apt</artifactId>
    <version>${querydsl.version}</version>
    <scope>provided</scope>
</dependency>
```

---

## Annotation Processor Configuration

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <configuration>
        <annotationProcessorPaths>
            <path>
                <groupId>com.querydsl</groupId>
                <artifactId>querydsl-apt</artifactId>
                <version>${querydsl.version}</version>
                <classifier>jpa</classifier>
            </path>
        </annotationProcessorPaths>
    </configuration>
</plugin>
```

---

## Commands

```bash
# Generate Q-classes
./mvnw compile

# Q-classes generated to:
target/generated-sources/java/com/myproject/domain/Q*.java
```

---

## Resources

- **Official**: https://querydsl.com/
- **Documentation**: https://www.querydsl.com/4.2.1/reference/html/
- **Spring Data Querydsl**: https://querydsl.com/static/querydsl/4.2.1/reference/htmlsingle/#jpa_integration
