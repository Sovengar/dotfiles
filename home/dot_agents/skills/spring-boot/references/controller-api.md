# Spring Boot - Controller & API Best Practices

> ⚠️ **Note:** For comprehensive logging best practices, see [logging skill](../../logging/SKILL.md).

## When to Use

- Designing REST controllers
- Creating API endpoints
- Defining request/response DTOs
- Logging entry points

---

## Critical Patterns

### 1. Logging at Entry Points (Controllers & Schedulers)

**DO:** Log at entry points (controllers, schedulers, message listeners), NOT in services for normal flow. Use **@Slf4j** (Lombok).

```java
// GOOD: Logging at entry point with @Slf4j
@Slf4j
@RestController
@RequiredArgsConstructor
public class OrderController {
    
    private final OrderService orderService;
    
    @PostMapping("/orders")
    public ResponseEntity<OrderResponse> createOrder(
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            @Valid @RequestBody CreateOrderRequest request) {
        
        log.info("Creating order: requestId={}, customerId={}, items={}", 
            requestId, request.customerId(), request.items().size());
        
        try {
            OrderResponse response = orderService.createOrder(request);
            log.info("Order created: requestId={}, orderId={}", requestId, response.id());
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (BusinessException e) {
            log.warn("Order creation failed: requestId={}, reason={}", requestId, e.getMessage());
            throw e;
        } catch (Exception e) {
            log.error("Order creation error: requestId={}", requestId, e);
            throw e;
        }
    }
    
    @GetMapping("/orders/{id}")
    public ResponseEntity<OrderResponse> getOrder(
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            @PathVariable Long id) {
        
        log.info("Getting order: requestId={}, orderId={}", requestId, id);
        
        try {
            OrderResponse response = orderService.getOrder(id);
            log.info("Order found: requestId={}, orderId={}", requestId, id);
            return ResponseEntity.ok(response);
        } catch (EntityNotFoundException e) {
            log.warn("Order not found: requestId={}, orderId={}", requestId, id);
            throw e;
        }
    }
}
```

**DO:** Log in schedulers at entry points.

```java
@Slf4j
@Component
@RequiredArgsConstructor
public class ScheduledTasks {
    
    private final PaymentService paymentService;
    
    @Scheduled(cron = "0 0 2 * * ?")  // 2 AM daily
    public void processScheduledPayments() {
        log.info("Starting scheduled payment processing");
        try {
            int processed = paymentService.processPendingPayments();
            log.info("Scheduled payment processing completed: processed={}", processed);
        } catch (Exception e) {
            log.error("Scheduled payment processing failed", e);
            throw e;
        }
    }
}
```

### 3. Use DTOs for Request/Response

**DO:** Use records for immutable DTOs.

```java
// Request DTOs
public record CreateOrderRequest(
    @NotNull List<OrderItemRequest> items,
    @NotNull Long customerId,
    @NotBlank String shippingAddress
) { }

public record OrderItemRequest(
    @NotNull Long productId,
    @NotNull @Min(1) Integer quantity
) { }

// Response DTOs
public record OrderResponse(
    Long id,
    List<OrderItemResponse> items,
    BigDecimal total,
    OrderStatus status,
    LocalDateTime createdAt
) { }
```

### 4. Consistent API Response Wrapper

**DO:** Use consistent response structure.

```java
// Response wrapper
public record ApiResponse<T>(
    boolean success,
    T data,
    String errorCode,
    String errorMessage,
    LocalDateTime timestamp
) {
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(true, data, null, null, LocalDateTime.now());
    }
    
    public static <T> ApiResponse<T> error(String errorCode, String message) {
        return new ApiResponse<>(false, null, errorCode, message, LocalDateTime.now());
    }
}
```

### 5. Use @Valid Explicitly

**DO:** Always use `@Valid` on request bodies to trigger Bean Validation.

```java
// GOOD: Explicit validation
@RestController
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @PostMapping("/users")
    public ResponseEntity<UserResponse> createUser(
            @Valid @RequestBody CreateUserRequest request) {
        // @Valid triggers validation, returns 400 if invalid
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(userService.createUser(request));
    }
}

public record CreateUserRequest(
    @NotBlank @Size(min = 3, max = 50)
    String name,
    
    @NotBlank @Email
    String email,
    
    @NotBlank @Size(min = 8)
    String password
) {}
```

**DON'T:** Forget `@Valid`.

```java
// BAD: No validation triggered
@PostMapping("/users")
public ResponseEntity<User> createUser(@RequestBody CreateUserRequest request) {
    // No validation! Invalid data enters the system.
    return userService.createUser(request);
}
```

### 6. Don't Put @Transactional on Controllers

**DON'T:** Never put `@Transactional` on controllers.

```java
// BAD: Wrong layer for transaction management
@RestController
public class BadController {
    
    @Transactional  // WRONG: Controllers should not manage transactions
    @PostMapping("/orders")
    public Order createOrder(@RequestBody OrderRequest request) {
        return orderService.createOrder(request);
    }
}
```

## Anti-Patterns to Avoid

### ❌ No Logging in Controllers

```java
// BAD: No visibility into what's happening
@PostMapping("/orders")
public ResponseEntity<Order> createOrder(@RequestBody OrderRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(orderService.createOrder(request));
}
```

### ❌ Logging Everything Including Sensitive Data

```java
// BAD: Logging sensitive data
@PostMapping("/auth/login")
public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
    log.info("Login attempt: email={}, password={}", request.email(), request.password());
    // ...
}
```

---

## Resources

- **REST API Design**: https://docs.spring.io/spring-boot/docs/current/reference/web/spring-web.html
- **Spring MVC**: https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#mvc
