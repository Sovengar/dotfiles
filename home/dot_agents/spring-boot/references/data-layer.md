# Spring Boot - Data Layer & Repository Best Practices

## Decision Framework

> **Rule:** Apply this logic for QueryDSL/Data Layer tooling decisions:

| Scenario | Action |
|----------|--------|
| **New project** | → Use QueryDSL |
| **Existing project without mature solution** | → Use QueryDSL |
| **Existing project with mature solution** (e.g., MyBatis, company abstraction) | → Keep existing, don't introduce QueryDSL |
| **Doubts** | → Ask user |

### Priority Order

1. **1st:** Company abstraction layer (internal query builder, custom repo pattern)
2. **2nd:** MyBatis or Spring JDBC (pure SQL, no ORM)
3. **3rd (default):** QueryDSL → See [tools-querydsl skill](../tools-querydsl/SKILL.md)

> ⚠️ QueryDSL is the default when no other mature solution exists.

### Spring Data JPA: Only use as underlying implementation, never expose directly to services

---

## When to Use

- Implementing repositories
- Writing database queries
- Optimizing data access
- Avoiding N+1 problems
- Deciding between QueryDSL vs Spring Data JPA

---

## Critical Patterns

### Architecture: Domain Repository + Infrastructure Adapter

**DO:** Separate domain model repository from Spring Data JPA. Use hexagonal architecture:

```
domain/
  ├── model/
  │   └── Order.java
  └── repository/
      └── OrderRepo.java  (Port - interface only)

infrastructure/
  └── persistence/
      ├── jpa/
      │   └── SpringOrderRepo.java  (JpaRepository)
      └── adapter/
          └── PostgreOrderAdapter.java  (Implements domain interface)
```

#### 1. Domain Repository (Port - Interface)

```java
// domain/repository/OrderRepo.java
// Agnostic of infrastructure - this is the port
public interface OrderRepo {
    
    Optional<Order> findById(Long id);
    
    Order save(Order order);
    
    void deleteById(Long id);
    
    List<Order> findByStatus(OrderStatus status);
    
    // Query methods (if using QueryDSL adapter)
    List<Order> findByFilters(OrderFilter filter);
}
```

#### 2. Spring Data JPA Repository (Infrastructure)

```java
// infrastructure/persistence/jpa/SpringOrderRepo.java
@Repository
public interface SpringOrderRepo extends JpaRepository<Order, Long> {
    
    List<Order> findByStatus(OrderStatus status);
    
    // Only simple queries - complex ones go to QueryRepo
}
```

#### 3. PostgreSQL Adapter (Implementation)

```java
// infrastructure/persistence/adapter/PostgreOrderAdapter.java
@Component
@RequiredArgsConstructor
public class PostgreOrderAdapter implements OrderRepo {
    
    private final SpringOrderRepo springOrderRepo;
    private final OrderQueryRepo queryRepo;  // QueryDSL for complex queries
    
    @Override
    public Optional<Order> findById(Long id) {
        return springOrderRepo.findById(id);
    }
    
    @Override
    public Order save(Order order) {
        return springOrderRepo.save(order);
    }
    
    @Override
    public void deleteById(Long id) {
        springOrderRepo.deleteById(id);
    }
    
    @Override
    public List<Order> findByStatus(OrderStatus status) {
        return springOrderRepo.findByStatus(status);
    }
    
    @Override
    public List<Order> findByFilters(OrderFilter filter) {
        // Delegate complex queries to QueryDSL repository
        return queryRepo.findOrdersWithFilters(filter);
    }
}
```

**BENEFITS:**
- Domain layer is agnostic of infrastructure
- Easy to switch from PostgreSQL to MongoDB, etc.
- Clear separation of concerns
- Domain repository interface defines the contract
- Adapters are implementation details

---

### QueryDSL vs Spring Data JPA: When to Use Each

**PREFERENCE:** Use QueryDSL by default for queries. Only use Spring Data JPA for simple CRUD operations on AggregateRoot (Commands) or if there's no alternative already in place.

| Approach | Use For |
|----------|---------|
| **QueryDSL** (PREFERRED) | Complex queries, dynamic filters, type-safe queries, reporting |
| **Spring Data JPA** | Simple CRUD on AggregateRoot, basic finders, Commands |

#### Use QueryDSL by Default (Unless Alternative Exists)

If there's no alternative like MyBatis already in the codebase, use QueryDSL:

```java
// QueryDSL - Use this by default for queries
@Component
@RequiredArgsConstructor
public class UserQueryRepo {
    
    private final JPAQueryFactory queryFactory;
    
    public List<User> findUsersWithFilters(UserFilter filter) {
        QUser user = QUser.user;
        
        return queryFactory
            .selectFrom(user)
            .where(
                filter.getStatus() != null 
                    ? user.status.eq(filter.getStatus())
                    : null,
                filter.getNameContains() != null
                    ? user.name.contains(filter.getNameContains())
                    : null,
                filter.getCreatedAfter() != null
                    ? user.createdAt.after(filter.getCreatedAfter())
                    : null
            )
            .fetch();
    }
    
    // Count, aggregations, etc.
    public long countActiveUsers() {
        QUser user = QUser.user;
        return queryFactory
            .selectFrom(user)
            .where(user.status.eq(UserStatus.ACTIVE))
            .fetchCount();
    }
}
```

#### Spring Data JPA Only for Commands (AggregateRoot)

```java
// Only use Spring Data JPA for Command-side (AggregateRoot CRUD)
@Repository
public interface OrderCommandRepo extends JpaRepository<Order, Long> {
    // Basic save/find/delete - that's it
}
```

**If MyBatis or another query library already exists** → Keep using it (don't introduce QueryDSL just for the sake of it). But if nothing exists → QueryDSL is the default choice.

### Avoid N+1 Queries with @EntityGraph or Fetch Joins

**DO:** Use eager fetching strategies to avoid N+1.

```java
// GOOD: Using EntityGraph
@EntityGraph(attributePaths = {"items", "customer", "customer.address"})
Optional<Order> findById(Long id);

// GOOD: Using FETCH JOIN
@Query("SELECT o FROM Order o JOIN FETCH o.items JOIN FETCH o.customer WHERE o.id = :id")
Optional<Order> findOrderWithDetails(@Param("id") Long id);
```

**DON'T:** Fetch related entities in loops.

```java
// BAD: N+1 query problem
public List<OrderDTO> getOrdersWithItems() {
    List<Order> orders = orderRepo.findAll();
    
    return orders.stream()
        .map(order -> {
            // Each order triggers a separate query for items!
            List<Item> items = itemRepo.findByOrderId(order.getId());
            return new OrderDTO(order, items);
        })
        .toList();
}
```

### Use @Modifying for Update/Delete Queries

```java
@Modifying
@Query("UPDATE User u SET u.status = :status WHERE u.lastLogin < :date")
int deactivateInactiveUsers(
    @Param("status") UserStatus status, 
    @Param("date") LocalDateTime date
);

@Modifying
@Query("DELETE FROM OrderItem oi WHERE oi.order.id = :orderId")
void deleteItemsByOrderId(@Param("orderId") Long orderId);
```

### Use Projections for Specific Data

**DO:** Use projections whenever possible to fetch only needed fields. This improves performance and reduces memory usage.

#### Spring Data JPA Projections

```java
// Interface projection - Spring Boot feature
public interface UserSummary {
    String getName();
    String getEmail();
}

// Method in repository - Spring Data handles it automatically
List<UserSummary> findByStatus(UserStatus status);

// Class projection with constructor
public class OrderCount {
    private final Long userId;
    private final Long count;
    
    public OrderCount(Long userId, Long count) {
        this.userId = userId;
        this.count = count;
    }
}

// Method in repository
@Query("SELECT new com.example.OrderCount(o.customer.id, COUNT(o)) FROM Order o GROUP BY o.customer.id")
List<OrderCount> countOrdersByUser();

// Projections with @Value (SpEL)
public interface UserWithRole {
    @Value("#{target.name + ' (' + target.role + ')'}")
    String getFullInfo();
}
```

#### QueryDSL Projections

```java
// QueryDSL projection - type-safe
@Component
@RequiredArgsConstructor
public class UserQueryRepo {
    
    private final JPAQueryFactory queryFactory;
    
    // Use Projections to map to DTO
    public List<UserSummary> findUserSummaries(UserStatus status) {
        QUser user = QUser.user;
        
        return queryFactory
            .select(Projections.constructor(UserSummary.class, user.name, user.email))
            .from(user)
            .where(user.status.eq(status))
            .fetch();
    }
    
    // Class projection with @QueryProjection (generated Q-class)
    public List<OrderCountDTO> countOrdersGrouped() {
        QOrder order = QOrder.order;
        
        return queryFactory
            .select(new QOrderCountDTO(order.customer.id, order.count()))
            .from(order)
            .groupBy(order.customer)
            .fetch();
    }
    
    // Simple field mapping with Projections.bean
    public List<UserSimpleDTO> findSimpleUsers() {
        QUser user = QUser.user;
        
        return queryFactory
            .select(Projections.bean(UserSimpleDTO.class, user.id, user.name, user.email))
            .from(user)
            .fetch();
    }
}

// DTO for QueryDSL class projection
@QueryProjection  // Add this annotation before compiling
public record OrderCountDTO(Long userId, Long count) { }
```

#### When to Use Projections

| Scenario | Use Projection |
|----------|---------------|
| API response needs only some fields | ✅ Interface projection |
| Complex aggregation with multiple fields | ✅ Class projection |
| Nested object transformation | ✅ Class/Record projection |
| Full entity needed for business logic | ❌ Don't use projections |

**BENEFITS:**
- Reduced data transfer (only needed fields)
- Better performance (SELECT only necessary columns)
- Type safety with QueryDSL
- Decoupled from entity structure
```

### Pagination and Sorting

```java
// Paginated results
Page<User> findByStatus(UserStatus status, Pageable pageable);

// Usage in service
public Page<User> getUsers(int page, int size, String sortBy) {
    Pageable pageable = PageRequest.of(page, size, Sort.by(sortBy).descending());
    return userRepo.findByStatus(UserStatus.ACTIVE, pageable);
}
```

---

## Anti-Patterns to Avoid

### ❌ Business Logic in Repository

```java
// BAD: Business logic in repository
@Repository
public interface BadOrderRepo extends JpaRepository<Order, Long> {
    
    default Order createOrderWithValidation(OrderRequest request) {
        // BAD: This should be in service
        if (request.getItems().isEmpty()) {
            throw new IllegalArgumentException("No items provided");
        }
        
        Order order = new Order();
        order.setItems(request.getItems().stream()
            .map(this::toOrderItem)
            .toList());
        
        return save(order);
    }
}
```

### ❌ Native Queries Without Necessity

```java
// BAD: Unnecessary native query
@Query(value = "SELECT * FROM users WHERE status = 'ACTIVE'", nativeQuery = true)
List<User> findActiveUsersNative();

// GOOD: JPQL does the same
@Query("SELECT u FROM User u WHERE u.status = :status")
List<User> findByStatus(@Param("status") UserStatus status);
```

### ❌ Missing @Transactional on Complex Operations

```java
// BAD: No transaction for multi-operation
@Service
public class BadUserService {
    
    public void changeUserStatus(Long userId, UserStatus newStatus) {
        // BAD: Each operation in separate transaction
        User user = userRepo.findById(userId).orElseThrow();
        user.setStatus(newStatus);
        userRepo.save(user);
        
        notificationService.sendStatusChangeEmail(user);
    }
}

// GOOD: All in one transaction
@Transactional
public void changeUserStatus(Long userId, UserStatus newStatus) {
    User user = userRepo.findById(userId).orElseThrow();
    user.setStatus(newStatus);
    userRepo.save(user);
    
    notificationService.sendStatusChangeEmail(user);
}
```

### ❌ Not Using @Param or Wrong Parameter Binding

```java
// BAD: Missing @Param
@Query("SELECT u FROM User u WHERE u.email = email")  // WRONG
List<User> findByEmail(String email);

// GOOD: Proper parameter binding
@Query("SELECT u FROM User u WHERE u.email = :email")
List<User> findByEmail(@Param("email") String email);
```

---

## Query Optimization Tips

### Index Strategy

```java
// Add indexes for frequently queried fields
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_status", columnList = "status"),
    @Index(name = "idx_user_created_at", columnList = "created_at")
})
public class User { }
```

### Batch Operations

```java
// GOOD: Batch insert
@Repository
public interface UserRepo extends JpaRepository<User, Long> {
    
    @Query("SELECT u FROM User u WHERE u.id IN :ids")
    List<User> findByIds(@Param("ids") List<Long> ids);
}

// Usage
List<User> users = userRepo.findByIds(List.of(1L, 2L, 3L, 4L, 5L));
```

### Read-Only Repositories

```java
// For complex read operations, consider separate repository
@Repository
public interface UserReadRepo {
    
    @Query("SELECT u FROM User u LEFT JOIN FETCH u.orders WHERE u.id = :id")
    Optional<User> findUserWithOrders(@Param("id") Long id);
    
    @Query(value = "SELECT * FROM v_user_summary", nativeQuery = true)
    List<UserSummary> getUserSummary();
}
```

---

## Commands

```bash
# Enable SQL logging (development)
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE

# Show parameters in logs
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE

# Database connection pool monitoring
logging.level.com.zaxxer.hikari=DEBUG
```

---

## Resources

- **Spring Data JPA**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/
- **JPA Queries**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#jpa.query-methods
- **Entity Graphs**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#entity-graph
- **QueryDSL**: https://querydsl.com/