# Data Objects

## Traditional DTO (Java 8)

Use when: Legacy systems, JPA entities, libraries needing setters

```java
public class UserDTO {
    private Long id;
    private String name;
    private String email;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
```

## Lombok (Java 11+)

Use when: Quick prototyping, clean code, no reflection issues

```java
@Data
@Builder
public class UserDTO {
    private Long id;
    private String name;
    private String email;
}
```

> **Note**: Requires Lombok annotation processor. May cause issues with some serialization frameworks.

## Java Record (Java 17+)

Use when: Immutable DTOs, data carriers, internal APIs

### Basic Record
```java
public record UserDTO(Long id, String name, String email) {}
```

### With Validation
```java
public record UserDTO(Long id, String name, String email) {
    public UserDTO {
        Objects.requireNonNull(name, "name cannot be null");
        Objects.requireNonNull(email, "email cannot be null");
    }
}
```

### With Custom Methods
```java
public record UserDTO(Long id, String name, String email) {
    public String displayName() {
        return name + " (" + email + ")";
    }
    
    public UserDTO withId(Long newId) {
        return new UserDTO(newId, name, email);
    }
}
```

### Record with Validation and Defaults
```java
public record Config(String name, int timeout, boolean enabled) {
    public Config {
        if (timeout < 0) timeout = 30;  // Default value
    }
    
    public Config() {
        this("default", 30, true);  // Static default
    }
}
```

## Decision Matrix

| Situation | Recommended |
|-----------|-------------|
| JPA Entity | Traditional DTO |
| JSON API response | Record |
| Library/API parameter | Record |
| Quick prototyping | Lombok |
| Needs serialization (Jackson) | Traditional DTO or Record (configure) |

## Common Mistakes

### ❌ DON'T: Using Records for JPA entities
```java
// BAD - JPA needs no-args constructor and setters
@Entity
public record UserEntity(Long id, String name) { }  // WON'T WORK
```

### ❌ DON'T: Lombok with Jackson without config
```java
// BAD - Lombok + Jackson can cause issues
@Data
public class UserDTO { ... }  // Can have problems with serialization
}

// GOOD - configure properly or use explicit getters
@Data
@JsonAutoDetect(fieldVisibility = JsonAutoDetect.Visibility.ANY)
public class UserDTO { ... }
```

### ❌ DON'T: Records with mutable fields
```java
// BAD - Records are immutable!
public record User(Long id, String name) {
    public void setName(String name) {  // WON'T COMPILE
        this.name = name;
    }
}
```

### Consideraciones sobre Entities vs DTOs

```java
// OK - para APIs internas, el entity está bien. Añade una nota:
// Note: Returns entity directly. Add DTO here if you need to 
// decouple API from DB schema in the future.
@GetMapping("/users")
public List<UserEntity> getUsers() { ... }

// Cuando realmente necesites el desacoplamiento:
@GetMapping("/users")
public List<UserDTO> getUsers() { ... }
```

> **Philosophy**: YAGNI - Don't create DTOs upfront unless you need them.
> - APIs internas → entity suele estar bien
> - APIs externas/públicas → considera DTOs desde el inicio
> - Añade DTO cuando necesites desacoplar

## Antipatterns

| Antipattern | Why Bad | Better Alternative |
|-------------|---------|-------------------|
| Record as JPA entity | Records need special configuration | Traditional Entity |
| Lombok without configuration | Can cause serialization issues | Use explicit getters or configure |
| Getters/setters for Records | Not needed, misleading | Let compiler generate |

> **Philosophy - YAGNI**: Don't create DTOs upfront unless you need them.
> - **Internal APIs**: entities are usually fine
> - **External/public APIs**: consider DTOs from the start
> - **When needed**: Add DTO to decouple API from DB schema
