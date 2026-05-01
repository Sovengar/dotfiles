# Null Safety

## Optional (Java 8)

Use when: Single-value return types, NOT as field type

### Basic Usage
```java
public Optional<User> findById(Long id) {
    return Optional.ofNullable(repository.find(id));
}

public String getUserName(Optional<User> user) {
    return user.map(User::getName).orElse("Anonymous");
}
```

### Chaining
```java
public String getUserCity(User user) {
    return Optional.ofNullable(user)
        .map(User::getAddress)
        .map(Address::getCity)
        .orElse("Unknown");
}
```

## Optional (Java 9+)

Use when: Handling both present and empty cases

### ifPresentOrElse
```java
public void processUser(Optional<User> user) {
    user.ifPresentOrElse(
        u -> log.info("Processing {}", u.getName()),
        () -> log.warn("No user found")
    );
}
```

### orElseThrow
```java
public User getUserOrThrow(Long id) {
    return findById(id).orElseThrow(() -> new UserNotFoundException(id));
}
```

### Optional.stream()
```java
// Combine Optionals with Streams
public List<String> getUserNames(List<Optional<User>> optionals) {
    return optionals.stream()
        .flatMap(Optional::stream)
        .map(User::getName)
        .toList();
}
```

### or()
```java
// Provide fallback Optional
public Optional<User> findById(Long id) {
    return repository.findById(id)
        .or(() -> Optional.of(cache.get(id)));
}
```

## Best Practices

| Do | Don't |
|----|-------|
| Use Optional as return type | Use Optional as field type |
| Use orElseThrow() for exceptional cases | Use isPresent() + get() |
| Use map/flatMap for transformation | Chain multiple if (x != null) |
| Use orElse() with non-expensive defaults | Use orElse() with expensive computations (use orElseGet()) |

## Common Mistakes

### ❌ DON'T: Optional as field
```java
// BAD
public class User {
    private Optional<String> nickname;  // WRONG!
}

// GOOD - use null or regular field
public class User {
    private String nickname;  // nullable field
}
```

### ❌ DON'T: isPresent() + get()
```java
// BAD
if (opt.isPresent()) {
    return opt.get();
}
return defaultValue;

// GOOD
return opt.orElse(defaultValue);
```

### ❌ DON'T: Optional in constructor
```java
// BAD
public User(Optional<String> name) { ... }

// GOOD - accept nullable or use Optional at API boundary
public User(String name) { ... }  // name can be null
```

### ❌ DON'T: Optional.orElse() with expensive call
```java
// BAD - expensiveComputation() ALWAYS runs
String name = opt.orElse(expensiveComputation());

// GOOD - use orElseGet() for lazy evaluation
String name = opt.orElseGet(() -> expensiveComputation());
```

### ❌ DON'T: Returning null from Optional-returning method
```java
// BAD
public Optional<User> findById(Long id) {
    if (exists(id)) {
        return Optional.of(user);
    }
    return null;  // WRONG - breaks Optional contract
}

// GOOD
public Optional<User> findById(Long id) {
    return repository.findById(id);  // Already returns Optional
    // or
    return Optional.ofNullable(repository.find(id));
}
```

## Antipatterns

| Antipattern | Why Bad | Better Alternative |
|-------------|---------|-------------------|
| Optional as field | Adds complexity, no benefit | Use null with proper documentation |
| isPresent() + get() | Verbose, error-prone | orElse() / orElseThrow() |
| orElse() with method call | Always executes | orElseGet() |
| Returning null from Optional method | Breaks Optional contract | Return Optional.empty() |

## Migration from null

```java
// Before
public String getCity(User user) {
    if (user == null) return "Unknown";
    if (user.getAddress() == null) return "Unknown";
    return user.getAddress().getCity();
}

// After
public String getCity(User user) {
    return Optional.ofNullable(user)
        .flatMap(u -> Optional.ofNullable(u.getAddress()))
        .map(a -> a.getCity())
        .orElse("Unknown");
}
```
