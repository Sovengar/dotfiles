---
name: tools-flyway
description: >
  Flyway - database schema migration tool with version control.
  Trigger: When setting up database migrations, managing schema changes, or deploying database updates.
decisionFramework: "New project → use Flyway. Existing project → if no mature solution, use Flyway. Otherwise keep existing."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Flyway

> Database schema migration with version control.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Use Flyway |
| **Existing project without mature solution** | → Use Flyway |
| **Existing project with mature solution** | → Keep existing solution (e.g., Liquibase) |
| **Doubts** | → Ask user |

---

## When to Use

- Setting up database schema for new applications
- Managing database schema changes over time
- Team environments with shared databases
- CI/CD pipelines requiring database migrations
- Need rollback capabilities for database changes

---

## Critical Patterns

### Naming Convention

```
V1__create_users_table.sql
V2__add_email_column.sql
V3__create_orders_table.sql
V4__add_status_to_orders.sql
```

| Prefix | Use |
|--------|-----|
| `V` | Versioned migration |
| `R` | Repeatable migration (runs every time) |
| `U` | Undo migration (deprecated in Flyway 10+) |

### Migration Location

```
src/main/resources/db/migration/
    V1__create_users_table.sql
    V2__create_orders_table.sql
```

---

## Code Examples

### Basic Migration

```sql
-- V1__create_users_table.sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- V2__add_status_column.sql
ALTER TABLE users ADD COLUMN status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE';
```

### Rollback (before Flyway 10)

```sql
-- U2__add_status_column.sql
ALTER TABLE users DROP COLUMN status;
```

---

## Maven Dependencies

```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-postgresql</artifactId>
</dependency>
<!-- For MySQL use flyway-mysql -->
```

---

## Configuration

```yaml
spring:
  flyway:
    enabled: true
    baseline-on-migrate: true
    locations: classpath:db/migration
    baseline-version: 1
    validate-on-migrate: true
```

---

## Commands

```bash
# Run migrations
./mvnw flyway:migrate

# Clean (drops all tables - DANGER!)
./mvnw flyway:clean

# Info (show current state)
./mvnw flyway:info

# Validate (check consistency)
./mvnw flyway:validate

# Repair (repair failed migrations)
./mvnw flyway:repair
```

---

## Resources

- **Official**: https://flywaydb.org/
- **Documentation**: https://flywaydb.org/documentation/
- **Commands**: https://flywaydb.org/documentation/usage/mvn/
