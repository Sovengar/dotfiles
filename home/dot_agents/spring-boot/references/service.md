# Spring Boot - Service Layer Best Practices

> ⚠️ **Note:** For comprehensive logging best practices, see [logging skill](../../logging/SKILL.md).

## When to Use

- Implementing business logic
- Transaction management
- Service-to-service communication

---

## Critical Patterns

### 1. Constructor Injection (Mandatory)

**DO:** Use constructor injection with `@RequiredArgsConstructor` (Lombok) or explicit constructors.

```java
// GOOD: Explicit dependencies, immutable, testable
@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final OrderRepo orderRepo;
    private final PaymentService paymentService;
    private final InventoryService inventoryService;
    private final NotificationService notificationService;
}
```

**Why:**
- Dependencies are explicit and visible
- Supports immutability
- Easy to test with mocks
- Catches circular dependencies at compile time

### 2. Component Stereotypes

**Use the right stereotype for each layer:**

| Annotation | Use For | Example |
|------------|---------|---------|
| `@Component` | Generic Spring-managed beans | Utility classes, helpers |
| `@Service` | Business logic layer | `OrderService`, `PaymentService` |
| `@Repository` | Data access layer | `UserRepo`, `SpringUserRepo` |
| `@Controller` / `@RestController` | Web layer | `OrderController`, `UserController` |
| `@Configuration` | Configuration beans | `AppConfig`, `SecurityConfig` |
| `@ApplicationService` | Usecase feature | `PlaceOrder` |
| `@DomainService` | Domain service | `PlaceOrderValidator` |

**Create ApplicationService and DomainService if it does not exists**

```java
@Component
@Validated
public @interface ApplicationService {}
```


```java
// Component - Generic bean
@Component
public class DateUtils {
    public LocalDateTime now() { return LocalDateTime.now(); }
}

// Service - Business logic
@Service
@RequiredArgsConstructor
public class OrderService {
    private final OrderRepo orderRepo;
}

// Repository - Data access (already covered in data-layer.md)
@Repository
public interface UserRepo extends JpaRepository<User, Long> { }

// Configuration - Spring configuration
@Configuration
public class AppConfig {
    @Bean
    public RestTemplate restTemplate() { ... }
}
```

### 3. Stateless Services

**DO:** Services should be stateless. Don't store state in instance fields.

```java
// GOOD: Stateless service
@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final OrderRepo orderRepo;  // Only dependencies, no state
    
    @Transactional
    public Order createOrder(CreateOrderRequest request) {
        // Each call is independent
        return orderRepo.save(request.toOrder());
    }
}
```

**DON'T:** Store state in services.

```java
// BAD: Stateful service - will cause bugs in concurrent scenarios
@Service
public class BadOrderService {
    
    private final OrderRepo orderRepo;
    private List<Order> cachedOrders;  // BAD: Mutable state!
    
    public List<Order> getCachedOrders() {
        if (cachedOrders == null) {
            cachedOrders = orderRepo.findAll();
        }
        return cachedOrders;
    }
}
```

### 5. Transaction Management in Service Layer

**DO:** Place `@Transactional` on service methods.

```java
// GOOD: Transactional boundaries at service layer
@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final OrderRepo orderRepo;
    private final InventoryService inventoryService;
    
    @Transactional(rollbackFor = Exception.class)
    public OrderResponse createOrder(CreateOrderRequest request) {
        // All operations in ONE transaction
        inventoryService.reserveItems(request.items());
        Order order = orderRepo.save(request.toOrder());
        return toResponse(order);
    }
    
    // Read-only transaction for queries
    @Transactional(readOnly = true)
    public List<OrderResponse> findOrdersByUser(Long userId) {
        return orderRepo.findByUserId(userId);
    }
}
```

### 7. No Logging for Normal Flow in Services

**DON'T:** Log every operation in services. Only log errors and abnormal flows.

```java
// BAD: Too much logging
@Slf4j
@Service
public class BadOrderService {
    
    public Order createOrder(OrderRequest request) {
        log.info("Creating order");
        log.debug("Validating items: {}", request.getItems());
        log.info("Saving to database");
        Order order = orderRepo.save(request.toOrder());
        log.info("Order created: {}", order.getId());
        return order;
    }
}
```

**DO:** Only log errors or unusual situations.

```java
// GOOD: Minimal logging - only errors and abnormal flows
@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final OrderRepo orderRepo;
    
    @Transactional
    public Order createOrder(OrderRequest request) {
        Order order = orderRepo.save(request.toOrder());
        
        // Only log abnormal situations
        if (order.getTotal().compareTo(BigDecimal.ZERO) == 0) {
            log.warn("Order created with zero total: orderId={}", order.getId());
        }
        
        if (order.getItems().size() > 100) {
            log.warn("Large order created: orderId={}, items={}", order.getId(), order.getItems().size());
        }
        
        return order;
    }
}
```

### 8. Don't Catch and Swallow Exceptions

**DON'T:** Catch exceptions without rethrowing or proper handling.

```java
// BAD: Swallowing exceptions prevents rollback
@Service
public class BadOrderService {
    
    @Transactional
    public Order createOrder(OrderRequest request) {
        try {
            return orderRepo.save(request.toOrder());
        } catch (Exception e) {
            log.error("Error saving order", e);
            return null;  // BAD: Silent failure, no rollback
        }
    }
}
```

**DO:** Let exceptions propagate or rethrow with context.

```java
// GOOD: Proper exception handling
@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final OrderRepo orderRepo;
    
    @Transactional(rollbackFor = Exception.class)
    public Order createOrder(OrderRequest request) {
        try {
            return orderRepo.save(request.toOrder());
        } catch (DataIntegrityViolationException e) {
            log.error("Data integrity violation: {}", e.getMessage());
            throw new BusinessException("Invalid order data", "INVALID_DATA", e);
        }
    }
}
```

---

## Anti-Patterns to Avoid

### ❌ God Service (Too Many Responsibilities)

```java
// BAD: Service doing everything
@Service
public class GodService {
    
    @Autowired
    private OrderRepo orderRepo;
    
    @Autowired
    private UserRepo userRepo;
    
    @Autowired
    private PaymentService paymentService;
    
    @Autowired
    private EmailService emailService;
    
    @Autowired
    private FileService fileService;
    
    // 100+ methods...
}
```

---

## Service Design Principles

### Single Responsibility

Each service should:
- Have one clear responsibility
- Be named after what it does
- Have focused public methods

### Dependency Direction

```
Controller → Service → Repository → Entity
     ↓
  DTOs
```

### Testing Services

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
    
    @Mock
    private OrderRepository orderRepository;
    
    @Mock
    private InventoryService inventoryService;
    
    @InjectMocks
    private OrderService orderService;
    
    @Test
    void createOrder_shouldSaveOrder() {
        // Given
        CreateOrderRequest request = new CreateOrderRequest(List.of(
            new OrderItemRequest(1L, 2)
        ), 1L, "address");
        
        when(orderRepo.save(any())).thenAnswer(inv -> {
            Order o = inv.getArgument(0);
            o.setId(1L);
            return o;
        });
        
        // When
        OrderResponse response = orderService.createOrder(request);
        
        // Then
        assertThat(response.id()).isEqualTo(1L);
        verify(inventoryService).reserveItems(any());
    }
}
```

---

## Commands

```bash
# Enable transaction debug logging
logging.level.org.springframework.transaction=DEBUG

# Enable SQL logging (dev only)
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE
```

---

## Resources

- **Spring Transactions**: https://docs.spring.io/spring-framework/docs/current/reference/html/data.html#transaction
- **Spring Data JPA**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/
