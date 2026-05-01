---
name: jpa-ddd-modeling
description: >
  JPA/Hibernate entity modeling with DDD patterns.
  Trigger: When creating JPA entities, aggregates, value objects, or domain models in Java.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# JPA Entity Modeling

This skill captures the entity modeling conventions with JPA/Hibernate.

## When to Use

- Creating JPA entities
- Building aggregates
- Modeling value objects (Embedded)
- Implementing soft-delete patterns

---

## Critical Patterns

### Model Structure Template

```java
@Entity
@Table(name = "users", schema = "auth")
@Getter
@NoArgsConstructor(access = PRIVATE)  // For Hibernate
@AllArgsConstructor(access = PACKAGE)   // For internal use, tests
@SQLRestriction("deleted <> true")     // Soft delete filter
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @Embedded
    private UserName username;
    
    @Embedded
    private Email email;
    
    // Optional field - getter returns Optional
    @Embedded
    @Getter(PRIVATE)  // Don't expose directly
    private Email internalEmail;
    
    // Nullable collection - expose as immutable
    @OneToMany(mappedBy = "user")
    @Getter
    private List<PhoneNumber> phoneNumbers = new ArrayList<>();
    
    @Enumerated(EnumType.STRING)
    private UserStatus status;
    
    @ManyToOne
    @JoinColumn(name = "role_code")
    private Role role;
    
    private boolean deleted = false;
    
    // Factory methods (static) - with validation
    public static User register(UserName username, Email email, 
                                UserPassword password, Role role) {
        requireNonNull(username);
        requireNonNull(email);
        requireNonNull(password);
        requireNonNull(role);
        
        return new User(username, email, null, password, 
                       UserStatus.DRAFT, role, false);
    }
    
    public static User createAdmin(UserName username, Email email,
                                   Email internalEmail, UserPassword password) {
        requireNonNull(username);
        requireNonNull(email);
        requireNonNull(password);
        
        return new User(username, email, internalEmail, password,
                       UserStatus.ACTIVE, Role.admin(), false);
    }
    
    // Custom getter for optional field - domain logic controls visibility
    public Optional<Email> getInternalEmail() {
        // If user is admin, they HAVE an internalEmail (not null)
        if (role.isAdmin()) {
            return Optional.of(internalEmail);
        }
        return Optional.empty();
    }
    
    // Custom getter for immutable collection
    public List<PhoneNumber> getPhoneNumbers() {
        return List.copyOf(phoneNumbers);
    }
    
    // Domain methods
    public void markAsDeleted() {
        this.deleted = true;
        this.username = null;
        this.email = null;
    }
}
```

### With Domain Events (Optional)

```java
// Only extend BaseAggregateRoot if using domain events
@AggregateRoot
public class UserWithEvents extends BaseAggregateRoot<UserWithEvents> {
    
    public void changeRole(Role newRole) {
        requireNonNull(newRole);
        
        if (this.deleted) {
            throw new IllegalStateException("Cannot change role of deleted user");
        }
        
        this.role = newRole;
        this.registerEvent(new RoleChangedEvent(this.id, newRole));
    }
}
```

### Constructor Accessibility

| Constructor | Access | Purpose |
|-------------|--------|---------|
| No-args | `PRIVATE` | Hibernate only - never call directly |
| All-args | `PACKAGE` | Internal use, tests, repositories |
| Static factory | `public` | Primary creation mechanism |

### Value Objects (Embedded)

```java
@Embeddable
@Value  // Lombok immutable - NOT a record for Hibernate
@NoArgsConstructor(access = PACKAGE, force = true)
@RequiredArgsConstructor(staticName = "of")
public class Email implements Serializable, MicroType {
    String email;
    
    static Email of(String email) {
        return new Email(requireNonNull(email));
    }
}
```

> **Note**: Use `@Value` (immutable), NOT `@Data`. Value objects should be immutable.

### Soft Delete Pattern

```java
@Entity
@SQLRestriction("deleted <> true")  // Automatically filters deleted
public class User {
    private boolean deleted = false;
    
    public void markAsDeleted() {
        this.deleted = true;
        // GDPR - clear personal data
        this.username = null;
        this.email = null;
    }
}
```

### Factory Pattern (Alternative)

```java
@NoArgsConstructor(access = PRIVATE)
public static class Factory {
    public static User register(UserName username, Email email, 
                                UserPassword password, Role role) {
        requireNonNull(username);
        requireNonNull(email);
        requireNonNull(password);
        requireNonNull(role);
        
        return new User(username, email, null, password, 
                       UserStatus.DRAFT, role, false);
    }
}
```

---

## Custom Getters Pattern

### Optional Fields

```java
// Field is stored but access depends on domain rules (e.g., permissions)
// If user is admin, they HAVE a backupEmail (not null)
@Embedded
@Getter(PRIVATE)
private Email backupEmail;

public Optional<Email> getBackupEmail() {
    if (role.isAdmin()) {
        return Optional.of(backupEmail);
    }
    return Optional.empty();
}
```

### Immutable Collections

```java
// Don't expose mutable list directly
@OneToMany(mappedBy = "user")
private List<Address> addresses = new ArrayList<>();

// Return immutable copy
public List<Address> getAddresses() {
    return List.copyOf(addresss);
}

// Or use unmodifiable
public List<Address> getAddresses() {
    return Collections.unmodifiableList(addresss);
}
```

### Filtering in Getters

```java
// Only return active addresses
public List<Address> getActiveAddresses() {
    return addresses.stream()
        .filter(Address::isActive)
        .toList();
}
```

---

## Decision Matrix

| Situation | Pattern |
|-----------|---------|
| Entity ID | Simple `@Id` with `@GeneratedValue(UUID)` |
| Optional field | `@Getter(PRIVATE)` + getter returns `Optional` |
| Collection | Return `List.copyOf()` or immutable |
| Soft delete | `deleted` field + `@SQLRestriction` |
| Creation logic | Static factory method with validation |
| Domain events | Extend `BaseAggregateRoot` |

---

## Common Mistakes

### ❌ DON'T: Public constructors
```java
// BAD - use Lombok's @AllArgsConstructor
public User(Long id, String name) { }
```

### ❌ DON'T: Validation in constructor
```java
// BAD - constructor should be simple
User(UUID id, UserName name) {
    this.id = requireNonNull(id);  // Don't do this
}

// GOOD - validate in factory method, use AllArgsConstructor
public static User create(UserName name) {
    requireNonNull(name);
    return new User(null, name);  // Use constructor
}
```

### ❌ DON'T: Exposing collections directly
```java
// BAD - caller can modify internal list
public List<Address> getAddresses() {
    return addresses;
}

// GOOD - return immutable copy
public List<Address> getAddresses() {
    return List.copyOf(addresss);
}
```

### ❌ DON'T: Using records as @Embeddable
```java
// BAD - JPA issues with records
public record Email(String email) { }

// GOOD - @Value with @NoArgsConstructor
@Embeddable
@Value
@NoArgsConstructor(access = PACKAGE, force = true)
public class Email { }
```

### ❌ DON'T: Using @Data for value objects
```java
// BAD - mutable
@Data
@Embeddable
public class Email { }

// GOOD - immutable
@Value
@Embeddable
public class Email { }
```

### ❌ DON'T: Forgetting @SQLRestriction for soft delete
```java
// BAD
@Entity
public class User { }

// GOOD
@Entity
@SQLRestriction("deleted <> true")
public class User { }
```

---

## Resources

- **Templates**: See [assets/](assets/) for entity templates
- **Related Skills**: java, java-springboot
