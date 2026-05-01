---
name: logging
description: >
  Logging best practices, patterns, and anti-patterns across all stacks.
  Trigger: When implementing logging in any application, designing log strategies, or debugging log issues.
tags: [logging, logs, observability, debugging]
triggers: [logging, logs, observability, debug-logs, logging-patterns]
---

## When to Use

- Implementing logging in a new application
- Designing logging strategy
- Debugging production issues via logs
- Adding correlation IDs for request tracing
- Structuring logs for observability

---

## Quick Reference

| Topic | Best Practice |
|-------|---------------|
| **Framework** | SLF4J + @Slf4j (Java), stdlib (Go), logging (Python) |
| **Logging** | Parameterized over string concatenation |
| **Levels** | ERROR > WARN > INFO > DEBUG > TRACE |
| **Sensitive Data** | NEVER log passwords, tokens, PII |
| **Entry Points** | "Request arrived at X", "Scheduler started for X/Y" |
| **Services** | Only errors + throw exceptions (no logging) |
| **Controllers** | No try-catch, no logging |
| **Exceptions** | Log in @ControllerAdvice (one place) |
| **Branches** | Log only unhappy paths (else, empty, fallback) |
| **External Calls** | Log only failures |

---

## Critical Patterns

### 1. Use Structured Logging

**DO:** Use structured logging for machine-parseable logs.

```java
// Spring Boot: Use @Slf4j (Lombok)
@Slf4j
@RestController
public class OrderController {
    
    @PostMapping("/orders")
    public ResponseEntity<OrderResponse> createOrder(@Valid @RequestBody CreateOrderRequest request) {
        log.info("Order created: orderId={}, customerId={}, total={}", orderId, customerId, total);
    }
}

// With JSON structured logging
log.info("Order created: {}", 
    Map.of("orderId", orderId, "customerId", customerId, "total", total));
```

**For Spring Boot, use Lombok's @Slf4j:**
```java
@Slf4j  // Generates: private static final Logger log = LoggerFactory.getLogger(...);
public class MyClass { }
```

```go
// GOOD: Go structured logging
log.Info("Order created",
    "orderId", orderId,
    "customerId", customerId,
    "total", total,
)
```

```python
# GOOD: Python structured logging
logger.info("Order created", extra={
    "orderId": order_id,
    "customerId": customer_id,
    "total": total,
})
```

### 2. Parameterized Logging (Not String Concatenation)

**DO:** Use parameterized logging.

```java
// GOOD: Parameterized - efficient
log.info("Processing order: orderId={}, customerId={}", orderId, customerId);
log.debug("Items count: {}", items.size());
log.error("Payment failed: orderId={}, reason={}", orderId, error.getMessage());
```

**DON'T:** String concatenation.

```java
// BAD: String concatenation - creates strings even when log level is disabled
log.info("Processing order: orderId=" + orderId + ", customerId=" + customerId);
log.info("Items count: " + items.size());
```

**WHY:** Parameterized logging only constructs the message if the log level is enabled.

### 3. Log Levels by Layer

| Layer | Normal Flow | Errors | Abnormal |
|-------|-------------|--------|----------|
| **Controllers/REST** | ✅ Entry/exit | ✅ | ✅ |
| **Schedulers** | ✅ Start/end | ✅ | ✅ |
| **Services** | ❌ No logging | ✅ | ✅ |
| **Repositories** | ❌ No logging | ❌ | ❌ |

### 4. Entry Point Logging (START/END Semantics)

**DO:** Use meaningful START/END messages with context.

```java
// Spring Boot: Use @Slf4j (Lombok)
@Slf4j
@RestController
public class OrderController {
    
    // ENDPOINT - "Request arrived at useCaseName"
    @PostMapping("/orders")
    public ResponseEntity<OrderResponse> createOrder(@Valid @RequestBody CreateOrderRequest request) {
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

// SCHEDULER - "Scheduler started for className/methodName"
@Slf4j
@Component
public class PaymentScheduler {
    
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

**DON'T:** Generic "START/END" without context.

```java
// BAD: No semantics
log.info("START createOrder");
log.info("END createOrder");
```

### 5. Log Every Branch (Unhappy Paths Only)

**DO:** Log only non-happy paths (exceptions, empty results, fallbacks).

```java
// OPTIONAL - log only when empty
Optional<User> user = userRepo.findByEmail(email);
// NO: log.info("User found: {}", user);  - Happy path, don't log
// YES: Only if throwing or handling absence
if (user.isEmpty()) {
    log.warn("User not found: email={}", email);
}

// IF-ELSE - log only the else branch
if (order.canBeCancelled()) {
    orderService.cancel(order);
    // No logging needed here - happy path
} else {
    log.warn("Order cannot be cancelled: orderId={}, status={}", order.getId(), order.getStatus());
}

// MONO/REACTOR - log only on empty
mono
    .flatMap(this::process)
    .switchIfEmpty(Mono.error(new NotFoundException("No data found")))
    .subscribe();

// IF-PRESENT-OR-ELSE - log only the fallback
user.ifPresentOrElse(
    u -> log.debug("User found: id={}", u.getId()),  // Optional - debug might be ok
    () -> log.warn("User not found for email: {}", email)  // IMPORTANT: Log the fallback
);
```

**DON'T:** Log happy paths.

```java
// BAD: Logging happy path
if (user.isPresent()) {
    log.info("User found: {}", user.get());  // ❌ Don't do this
}
log.info("User saved: {}", savedUser);  // ❌ Don't do this
```

### 6. Log Every External Call

**DO:** Log external service failures.

```java
// GOOD: Log failures from external calls
try {
    PaymentResult result = paymentGateway.process(payment);
} catch (PaymentGatewayException e) {
    log.error("Payment gateway call failed: orderId={}, reason={}", orderId, e.getMessage());
    throw new PaymentException("Payment failed", e);
}
```

**DON'T:** Log every external call attempt.

```java
// BAD: Unnecessary logging
log.info("Calling payment gateway");
log.info("Payment gateway responded");
```

### 7. Exception Logging in Global Handler

**DO:** Log exceptions in `@ControllerAdvice`, not in services or controllers.

```java
// SERVICE - throw exceptions, don't log
@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepo userRepo;
    
    public User findByEmail(String email) {
        return userRepo.findByEmail(email)
            .orElseThrow(() -> new EntityNotFoundException("User not found: " + email));
    }
}

// CONTROLLER - no try-catch, no logging
@Slf4j
@RestController
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @GetMapping("/users/{email}")
    public User getUser(@PathVariable String email) {
        return userService.findByEmail(email);  // No try-catch, no logging
    }
}

// GLOBAL EXCEPTION HANDLER - ONE place for all exception logging
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

### 8. What NOT to Log

**NEVER log sensitive data:**

| Never Log | Why |
|-----------|-----|
| Passwords | Security risk |
| API keys/tokens | Security risk |
| Credit card numbers | PCI violation |
| Personal identifiable information (PII) | GDPR violation |
| Session IDs | Security risk |
| Full request/response bodies (if contains sensitive data) | Security risk |

```java
// BAD: Never do this
log.info("User login: email={}, password={}", email, password);
log.info("Request: {}", request.getBody());  // Could contain secrets
```

**DO:** Sanitize sensitive data.

```java
// GOOD: Sanitize sensitive data
log.info("User login attempt: email={}", email);  // Don't log password
log.info("Processing payment: orderId={}, maskedCard={}", 
    orderId, maskCardNumber(cardNumber));
```

### 9. Correlation IDs for Request Tracing

**DO:** Add correlation ID for tracking requests across services.

```java
// Filter to add correlation ID
@Component
public class CorrelationIdFilter extends OncePerRequestFilter {
    
    public static final String CORRELATION_ID = "X-Correlation-ID";
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, 
            HttpServletResponse response, FilterChain filterChain) {
        
        String correlationId = request.getHeader(CORRELATION_ID);
        if (correlationId == null) {
            correlationId = UUID.randomUUID().toString();
        }
        
        MDC.put("correlationId", correlationId);
        response.setHeader(CORRELATION_ID, correlationId);
        
        try {
            filterChain.doFilter(request, response);
        } finally {
            MDC.remove("correlationId");
        }
    }
}

// Use in logging
log.info("Processing request");  // Includes correlationId from MDC
```

---

## Anti-Patterns to Avoid

### ❌ Logging Without Context

```java
// BAD: No context
log.info("Processing");
log.info("Done");
```

**Solution:** Add context.

```java
// GOOD: Context included
log.info("Processing order: orderId={}", orderId);
log.info("Order processed: orderId={}, status={}", orderId, status);
```

### ❌ Logging Everything

```java
// BAD: Too much logging
log.info("Entering method");
log.info("Validation passed");
log.info("Saving to database");
log.info("Saved successfully");
log.info("Returning result");
```

### ❌ Not Using Appropriate Log Levels

```java
// BAD: Using INFO for debugging
log.info("Debug: variable X = " + x);

// GOOD: Use DEBUG for debugging
log.debug("Variable X = {}", x);
log.trace("Entering method execution");
```

### ❌ Logging Sensitive Data

```java
// BAD: Security risk
log.info("User created: {}", user);  // user might contain password
log.info("Auth token: {}", token);
```

---

## Logging Configuration

### Logback (Java/Spring Boot)

```xml
<!-- logback-spring.xml -->
<configuration>
    <property name="LOG_PATTERN" 
        value="%d{yyyy-MM-dd HH:mm:ss} [%thread] [%X{correlationId}] %-5level %logger{36} - %msg%n"/>
    
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>${LOG_PATTERN}</pattern>
        </encoder>
    </appender>
    
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/application.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs/application-%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>30</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>${LOG_PATTERN}</pattern>
        </encoder>
    </appender>
    
    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
        <appender-ref ref="FILE"/>
    </root>
</configuration>
```

### Go (Zap)

```go
// zap-config.go
func init() {
    config := zap.NewProductionConfig()
    config.EncoderConfig.TimeKey = "timestamp"
    config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
    
    logger, _ := config.Build()
    zap.ReplaceGlobals(logger)
}

// Usage
zap.Info("Order created",
    zap.String("orderId", orderId),
    zap.String("customerId", customerId),
)
```

### Python (structlog)

```python
# logging_config.py
import structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ],
    logger_factory=structlog.PrintLoggerFactory(),
)

# Usage
logger = structlog.get_logger()
logger.info("order_created", order_id=order_id, customer_id=customer_id)
```

---

## Commands

```bash
# Java/Spring Boot - Set log level
logging.level.root=INFO
logging.level.com.example=DEBUG
logging.level.org.hibernate=DEBUG

# Show SQL with parameters
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE
```

---

## Resources

- **SLF4J Manual**: https://www.slf4j.org/manual.html
- **Logback Configuration**: https://logback.qos.ch/manual/configuration.html
- **Go Zap**: https://github.com/uber-go/zap
- **Python structlog**: https://www.structlog.org/
