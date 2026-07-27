# Logging in Spring Boot

> ⚠️ **See [logging skill](../logging/SKILL.md)** for comprehensive logging best practices.

This reference summarizes Spring Boot-specific logging patterns.

---

## Quick Reference

| Layer | What to Log |
|-------|-------------|
| **Controllers** | "Request arrived at useCaseName" / "Request completed/failed: useCaseName" |
| **Schedulers** | "Scheduler started for ClassName/methodName" / "Scheduler completed/failed" |
| **Services** | NO logging - throw exceptions only |
| **@ControllerAdvice** | Log all exceptions (ONE place) |
| **Repositories** | No logging |

---

## Key Patterns

### Entry Points (Use @Slf4j)

```java
@Slf4j
@RestController
@RequiredArgsConstructor
public class OrderController {
    
    private final OrderService orderService;
    
    @PostMapping("/orders")
    public ResponseEntity<OrderResponse> createOrder(
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            @Valid @RequestBody CreateOrderRequest request) {
        
        log.info("Request arrived at createOrder");
        
        try {
            OrderResponse response = orderService.createOrder(request);
            log.info("Request completed: createOrder");
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            log.error("Request failed: createOrder, reason={}", e.getMessage());
            throw e;
        }
    }
}
```

### Scheduler

```java
@Slf4j
@Component
@RequiredArgsConstructor
public class PaymentScheduler {
    
    private final PaymentService paymentService;
    
    @Scheduled(cron = "0 0 2 * * ?")
    public void processScheduledPayments() {
        log.info("Scheduler started for PaymentScheduler/processScheduledPayments");
        
        try {
            int processed = paymentService.processPendingPayments();
            log.info("Scheduler completed: PaymentScheduler/processScheduledPayments, processed={}", processed);
        } catch (Exception e) {
            log.error("Scheduler failed: PaymentScheduler/processScheduledPayments, reason={}", e.getMessage());
            throw e;
        }
    }
}
```

### No Logging in Services (Normal Flow)

```java
@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final OrderRepo orderRepo;
    
    @Transactional
    public OrderResponse createOrder(CreateOrderRequest request) {
        // NO logging for normal flow - throw exceptions instead
        Order order = orderRepo.save(request.toOrder());
        
        // Only log abnormal situations
        if (order.getTotal().compareTo(BigDecimal.ZERO) == 0) {
            log.warn("Order created with zero total: orderId={}", order.getId());
        }
        
        return toResponse(order);
    }
}
```

### Global Exception Handler (ONE Place for All Exceptions)

```java
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(EntityNotFoundException e) {
        log.warn("Entity not found: {}", e.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(ErrorResponse.notFound(e.getMessage()));
    }
    
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusiness(BusinessException e) {
        log.warn("Business error: code={}, message={}", e.getCode(), e.getMessage());
        return ResponseEntity.badRequest()
            .body(ErrorResponse.business(e.getCode(), e.getMessage()));
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneral(Exception e) {
        log.error("Unexpected error: {}", e.getMessage(), e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(ErrorResponse.internal("An unexpected error occurred"));
    }
}
```

---

## Log Every Branch (Unhappy Paths Only)

```java
// OPTIONAL - log only when empty or handling absence
user.ifPresentOrElse(
    u -> { /* happy path - no logging needed */ },
    () -> log.warn("User not found for email: {}", email)
);

// IF-ELSE - log only the else branch
if (order.canBeCancelled()) {
    orderService.cancel(order);
    // No logging needed - happy path
} else {
    log.warn("Order cannot be cancelled: orderId={}, status={}", order.getId(), order.getStatus());
}
```

---

## Key Points from logging Skill

- **Use @Slf4j (Lombok)** instead of `LoggerFactory.getLogger()`
- **Parameterized logging**: `log.info("orderId={}", orderId)` instead of concatenation
- **Never log**: passwords, tokens, PII
- **Correlation ID**: Use MDC for request tracing (correlationId, customerId, orderId, etc.)
- **Exception logging**: Include stack trace `log.error(..., e)`
- **Log every branch**: Only unhappy paths (else, empty, fallback)
- **Log external calls**: Only failures

---

## Reference

For full details, see: **[logging skill](../logging/SKILL.md)**