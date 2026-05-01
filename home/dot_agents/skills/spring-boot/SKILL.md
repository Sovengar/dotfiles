---
name: spring-boot
description: >
  Spring Boot development best practices and anti-patterns.
  Trigger: When writing Java Spring Boot code, reviewing Spring Boot applications, or discussing Spring Boot architecture.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- Writing new Spring Boot controllers, services, or repositories
- Reviewing Spring Boot code for quality and performance
- Designing Spring Boot application architecture
- Configuring Spring Boot applications
- Handling transactions in Spring Boot
- Writing unit and integration tests

## Quick Reference

| Area | Best Practice |
|------|---------------|
| **Configuration** | `@ConfigurationProperties` with validation, disable `open-in-view`, secrets in env vars |
| **Security** | Method-level security with `@PreAuthorize`, don't expose entities, BCrypt |
| **Error Handling** | `@ControllerAdvice` centralization, consistent error responses |
| **Controllers** | Log at entry points, use DTOs, use `@Valid`, parameterized logging |
| **Services** | Constructor injection, stateless, `@Transactional` in service layer, minimal logging |
| **Data Layer** | Domain Repo (port) + PostgreAdapter (impl), QueryDSL for queries |
| **Testing** | Abstract base class for integration tests, test slices, Testcontainers |
| **Logging** | See [logging skill](../logging/SKILL.md) and [logging reference](references/logging.md) |

## Key Principles

### Logging Strategy

> ⚠️ **See [logging skill](../logging/SKILL.md)** for comprehensive logging guide.

| Layer | What to Log |
|-------|-------------|
| **Controllers** | Entry points, success, errors, request IDs |
| **Schedulers** | Start/end of scheduled jobs, errors |
| **Services** | Only errors and abnormal flows (e.g., zero totals, large orders) |
| **Repositories** | No logging |

### Data Layer

- **Hexagonal Architecture**: Domain Repository (interface/port) + Infrastructure Adapter (PostgreAdapter, etc.)
- **QueryDSL by default** for queries (unless MyBatis or other alternative exists - see [data-layer.md](references/data-layer.md))
- **Spring Data JPA** only for the underlying JpaRepository implementation
- **Use projections** (interface/class) whenever possible for both QueryDSL and Spring Data JPA
- Avoid N+1 queries with `@EntityGraph` or fetch joins

### Transaction & DI

- **`@Transactional` goes on SERVICE methods, not controllers**
- Use `rollbackFor = Exception.class` for explicit rollback
- Disable `spring.jpa.open-in-view` in new applications
- Use `readOnly = true` for query methods
- **ALWAYS use constructor injection** (never field injection with `@Autowired`)

---

## Detailed References

See [references/](references/) for comprehensive guides:

- **[logging.md](references/logging.md)**: Spring Boot logging summary (see [logging skill](../logging/SKILL.md) for full guide)
- **[configuration.md](references/configuration.md)**: Configuration properties, validation, open-in-view, secrets management, docker-compose
- **[security.md](references/security.md)**: Authentication, authorization, sensitive data
- **[error-handling.md](references/error-handling.md)**: Exception handling, error responses
- **[controller-api.md](references/controller-api.md)**: REST controllers, DTOs, logging entry points, @Valid
- **[service.md](references/service.md)**: Service layer patterns, transaction management, component stereotypes, statelessness
- **[data-layer.md](references/data-layer.md)**: Repositories, queries, N+1 optimization
- **[testing.md](references/testing.md)**: Unit tests, integration tests, test slices, Testcontainers, abstract base class
- **[observability.md](references/observability.md)**: Actuator, health checks, Micrometer metrics, distributed tracing

---

## Critical Anti-Patterns

### ❌ Never Do This

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| `@EnableAsync`, `@EnableScheduling` en `@SpringBootApplication` | Test slices cargan configuraciones innecesarias | Crear `@Configuration` clase separada (ej. `ApplicationConfig`) |
| `@Value` scattered | No validation, hard to maintain | Use `@ConfigurationProperties` |
| `@Transactional` on controller | Wrong layer | Move to service |
| `spring.open-in-view=true` (new apps) | Wasted connections, hidden N+1 | Set to `false` |
| Logging in services | Too much noise | Log only at entry points |
| N+1 queries | Performance killer | Use `@EntityGraph` or fetch joins |
| Return raw entities | Exposes internal structure | Use DTOs |
| Multiple `@ExceptionHandler` | Inconsistent errors | Use single `@ControllerAdvice` |

---

## Project Setup

### EditorConfig

When starting a new Spring Boot project or working in a fresh backend:

1. **Check if `.editorconfig` exists** in project root
2. **If missing**, call the `editorconfig` skill to generate one

> The `editorconfig` skill analyzes your project and generates a comprehensive `.editorconfig` with proper Java/Spring Boot settings.

### Quick Setup Checklist

- [ ] `.editorconfig` exists (run `editorconfig` skill if missing)
- [ ] `pom.xml` has correct Spring Boot version
- [ ] `application.yml` configured with active profile
- [ ] Flyway migrations in `src/main/resources/db/migrations`

---

## Commands

> ⚠️ **Note:** For Maven commands, wrapper usage, and troubleshooting, see [maven skill](../tools-maven/SKILL.md).

```bash
# Disable open-in-view in application.yml
spring.jpa.open-in-view=false

# Enable transaction logging
logging.level.org.springframework.transaction=DEBUG

# Enable SQL logging (dev)
logging.level.org.hibernate.SQL=DEBUG
```

---

## Resources

- **Spring Boot Reference**: https://docs.spring.io/spring-boot/docs/current/reference/
- **Spring Data JPA**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/
- **Spring Security**: https://docs.spring.io/spring-security/reference/


