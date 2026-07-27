# Spring Boot - Error Handling Best Practices

## When to Use

- Handling exceptions in Spring Boot applications
- Designing error responses
- Creating global exception handlers

---

## Critical Patterns

### 1. Use @ControllerAdvice for Centralized Exception Handling

**DO:** Centralize all exception handling in one place.

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> handleValidation(MethodArgumentNotValidException ex) {
        List<String> errors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(FieldError::getDefaultMessage)
            .toList();
        
        return ResponseEntity.badRequest()
            .body(ApiError.validation(errors));
    }
    
    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ApiError> handleNotFound(EntityNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(ApiError.notFound(ex.getMessage()));
    }
    
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiError> handleBusiness(BusinessException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(ApiError.business(ex.getMessage()));
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> handleGeneral(Exception ex) {
        log.error("Unexpected error", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(ApiError.internal("An unexpected error occurred"));
    }
}
```

### 2. Consistent Error Response Structure

**DO:** Use a consistent error response wrapper.

```java
public record ApiError(
    String code,
    String message,
    List<String> details,
    LocalDateTime timestamp
) {
    public static ApiError validation(List<String> errors) {
        return new ApiError("VALIDATION_ERROR", "Validation failed", errors, LocalDateTime.now());
    }
    
    public static ApiError notFound(String message) {
        return new ApiError("NOT_FOUND", message, null, LocalDateTime.now());
    }
    
    public static ApiError business(String message) {
        return new ApiError("BUSINESS_ERROR", message, null, LocalDateTime.now());
    }
    
    public static ApiError internal(String message) {
        return new ApiError("INTERNAL_ERROR", message, null, LocalDateTime.now());
    }
}
```

### 3. Don't Catch Exceptions Without Proper Handling in @Transactional

**CRITICAL:** Checked exceptions do NOT rollback by default.

```java
// GOOD: Explicit rollback for all exceptions
@Transactional(rollbackFor = Exception.class)
public Order createOrder(OrderRequest request) {
    // This WILL rollback on any exception
    return orderRepository.save(request.toOrder());
}
```

**BAD:** Catching exceptions without rethrowing prevents rollback.

```java
// BAD: Exception swallowed, no rollback
@Transactional
public Order createOrder(OrderRequest request) {
    try {
        return orderRepository.save(request.toOrder());
    } catch (Exception e) {
        log.error("Error creating order", e);
        return null;  // BAD: No rollback, silent failure
    }
}
```

---

## Anti-Patterns to Avoid

### ❌ Multiple @ExceptionHandler in Different Controllers

```java
// BAD: Exception handling scattered across controllers
@RestController
public class UserController {
    
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<UserError> handleUserNotFound(UserNotFoundException ex) {
        return ResponseEntity.notFound().build();
    }
}

@RestController
public class OrderController {
    
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<OrderError> handleUserNotFound(UserNotFoundException ex) {
        return ResponseEntity.badRequest().build();
    }
}
```

### ❌ Return null on Error

```java
// BAD: Null returns hide errors
@PostMapping("/users")
public User createUser(@RequestBody User user) {
    try {
        return userRepository.save(user);
    } catch (Exception e) {
        log.error("Error", e);
        return null;  // Client receives null, no error info
    }
}
```

### ❌ Generic Exception Mapping

```java
// BAD: Too generic, hides specific errors
@ExceptionHandler(Exception.class)
public ResponseEntity<?> handleAll(Exception ex) {
    return ResponseEntity.ok(Map.of("error", ex.getMessage()));
}
```

---

## Custom Business Exceptions

```java
// Custom exception
public class BusinessException extends RuntimeException {
    private final String errorCode;
    
    public BusinessException(String message, String errorCode) {
        super(message);
        this.errorCode = errorCode;
    }
    
    public String getErrorCode() {
        return errorCode;
    }
}
```

---

## Commands

```bash
# Enable stack trace in errors (dev only)
server.error.include-stacktrace=always

# Hide stack trace in production
server.error.include-stacktrace=never
server.error.include-message=never
```

---

## Resources

- **Exception Handling**: https://docs.spring.io/spring-boot/docs/current/reference/web/spring-web.html#web.exception-handling
