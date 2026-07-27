# Entity Template

## Basic Entity

```java
@Entity
@Table(name = "entity_name", schema = "schema_name")
@Getter
@NoArgsConstructor(access = PRIVATE)  // For Hibernate
@AllArgsConstructor(access = PACKAGE) // For internal use, tests
@SQLRestriction("deleted <> true")
public class EntityName {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @Embedded
    private FieldName fieldName;
    
    // Optional field - getter returns Optional
    @Embedded
    @Getter(PRIVATE)
    private FieldName optionalField;
    
    // Collection - return immutable
    @OneToMany(mappedBy = "entity")
    private List<ChildEntity> children = new ArrayList<>();
    
    @Enumerated(EnumType.STRING)
    private Status status;
    
    @ManyToOne
    @JoinColumn(name = "reference_id")
    private ReferenceEntity reference;
    
    private boolean deleted = false;
    
    // Factory method - validation here, use AllArgsConstructor
    public static EntityName create(FieldName fieldName, Status status) {
        requireNonNull(fieldName);
        requireNonNull(status);
        
        return new EntityName(null, fieldName, null, status, null, false);
    }
    
    // Custom getter for optional field - domain logic controls visibility
    // If condition is met, field IS present (use of), otherwise empty
    public Optional<FieldName> getOptionalField() {
        if (someDomainCondition) {
            return Optional.of(optionalField);  // Field is guaranteed present
        }
        return Optional.empty();
    }
    
    // Custom getter for immutable collection
    public List<ChildEntity> getChildren() {
        return List.copyOf(children);
    }
}
```

## Value Object (Embedded)

```java
@Embeddable
@Value  // Immutable - NOT a record for Hibernate
@NoArgsConstructor(access = PACKAGE, force = true)
@RequiredArgsConstructor(staticName = "of")
public class ValueObjectName implements Serializable, MicroType {
    String value;
    
    static ValueObjectName of(String value) {
        return new ValueObjectName(requireNonNull(value));
    }
}
```

## Enum

```java
@Getter
public enum Status {
    DRAFT,
    ACTIVE,
    INACTIVE;
}
```

## With Domain Events (Optional)

> Note: Only extend BaseAggregateRoot if your application uses domain events.

```java
// If you DON'T need domain events:
@Entity
public class SimpleEntity { }

// If you DO need domain events:
@Entity
@AggregateRoot
public class EntityWithEvents extends BaseAggregateRoot<EntityWithEvents> {
    
    public void doSomething() {
        this.registerEvent(new DomainEvent(...));
    }
}
```
