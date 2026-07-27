---
name: tools-testcontainers
description: >
  TestContainers - real databases in Docker containers for integration tests.
  Trigger: When writing integration tests that need real databases, testing database migrations, or need CI/CD compatible test databases.
decisionFramework: "New project → use TestContainers. Existing project → if no mature solution, use TestContainers. Otherwise keep existing."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# TestContainers

> Real databases in Docker containers for integration tests.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Use TestContainers |
| **Existing project without mature solution** | → Use TestContainers |
| **Existing project with mature solution** | → Keep existing solution, don't introduce TestContainers |
| **Doubts** | → Ask user |

---

## When to Use

- Integration tests requiring real databases
- Testing JPA repositories
- Verifying database migrations (Flyway)
- Testing reactive databases (R2DBC)
- CI/CD environments needing isolated databases

---

## Critical Patterns

### @Testcontainers Annotation

```java
@Testcontainers
class UserRepositoryIT {
    
    @Container
    private static PostgreSQLContainer<?> postgres = 
        new PostgreSQLContainer<>("postgres:15")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");
    
    @DynamicPropertySource
    static void properties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
    
    @Test
    void shouldSaveAndFindUser() {
        User user = new User("test@example.com");
        User saved = repository.save(user);
        
        Optional<User> found = repository.findById(saved.getId());
        assertThat(found).isPresent();
    }
}
```

### Shared Container (Faster)

```java
@Testcontainers
class SharedDatabaseIT {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");
    
    // All tests in class use same container
}
```

---

## Supported Databases

| Database | Container Class |
|----------|----------------|
| PostgreSQL | `PostgreSQLContainer` |
| MySQL | `MySQLContainer` |
| MariaDB | `MariaDBContainer` |
| Oracle | `OracleContainer` |
| SQL Server | `MsSqlServerContainer` |
| Redis | `RedisContainer` |
| MongoDB | `MongoDBContainer` |
| Kafka | `KafkaContainer` |

---

## Maven Dependencies

```xml
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>testcontainers</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>junit-jupiter</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>postgresql</artifactId>
    <scope>test</scope>
</dependency>
<!-- Add more for other databases -->
```

---

## Configuration

```properties
# testcontainers.properties
ryuk.container.enabled=false
testcontainers.reuse.enabled=true
testcontainers.reusecontainers.enabled=true
```

---

## Commands

```bash
# No specific commands
# Tests run with: ./mvnw test
# Docker must be running
```

---

## Best Practices

| Practice | Description |
|----------|-------------|
| Use static containers | Share across tests for speed |
| Reuse containers | Enable in testcontainers.properties |
| Clean between tests | Use `@Transactional` or cleanup |
| Use specific versions | Pin database versions |

---

## Resources

- **Official**: https://www.testcontainers.org/
- **Modules**: https://www.testcontainers.org/modules/
- **Guide**: https://www.testcontainers.org/quickstart/
