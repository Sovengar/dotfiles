# Spring Boot - Configuration Best Practices

## Decision Framework

> **Rule:** Apply this logic for configuration tooling decisions:

### Database Migrations (Flyway)

| Scenario | Action |
|----------|--------|
| **New project** | → Use Flyway |
| **Existing project without mature solution** | → Use Flyway |
| **Existing project uses Liquibase** | → Keep Liquibase, don't introduce Flyway |
| **Doubts** | → Ask user |

→ See [tools-flyway skill](../tools-flyway/SKILL.md)

### Integration Testing (TestContainers)

| Scenario | Action |
|----------|--------|
| **New project** | → Use TestContainers |
| **Existing project without mature solution** | → Use TestContainers |
| **Existing project with mature solution** (e.g., H2 in-memory, custom test db) | → Keep existing |
| **Doubts** | → Ask user |

→ See [tools-testcontainers skill](../tools-testcontainers/SKILL.md)

### SQL Logging (P6Spy)

| Scenario | Action |
|----------|--------|
| **New project** | → Use P6Spy |
| **Existing project without mature solution** | → Use P6Spy |
| **Existing project with SQL logging** (e.g., custom solution, Hibernate statistics) | → Keep existing |
| **Doubts** | → Ask user |

→ See [tools-p6spy skill](../tools-p6spy/SKILL.md)

---

## When to Use

- Configuring Spring Boot applications
- Setting up application properties
- Using `@ConfigurationProperties`
- Migration from legacy configurations

---

## Critical Patterns

### 1. @ConfigurationProperties with Validation

**DO:** Use `@ConfigurationProperties` with Bean Validation for type-safe, validated configuration.

```java
// GOOD: Centralized, validated configuration
@ConfigurationProperties(prefix = "app.external-api")
@Validated
public class ExternalApiProperties {
    
    @NotBlank
    private String baseUrl;
    
    @Min(1000)
    @Max(60000)
    private int timeout = 5000;
    
    @NotNull
    private Credentials credentials;
    
    public static class Credentials {
        @NotBlank
        private String apiKey;
    }
}
```

**Enable with:**
```java
@Configuration
@EnableConfigurationProperties(ExternalApiProperties.class)
// or with Spring Boot 2.2+: 
// @ConfigurationPropertiesScan
public class AppConfig { }
```

**DON'T:** Scatter `@Value` annotations across multiple classes.

```java
// BAD: Scattered, hard to maintain, no validation
@RestController
public class BadController {
    @Value("${external.api.url}")
    private String apiUrl;
    
    @Value("${external.api.timeout:5000}")
    private int timeout;
    
    @Value("${external.api.key}")
    private String apiKey;
}
```

### 2. Disable spring.open-in-view for New Applications

**CRITICAL:** If the application doesn't exist yet, DISABLE `spring.open-in-view`.

**What it does:** By default, `spring.open-in-view=true` (enabled) creates a transaction for EVERY request in the controller, which:
- Wastes database connections
- Hides N+1 query problems
- Creates unexpected transaction boundaries
- Causes performance issues in production

**How to disable:**
```yaml
# application.yml
spring:
  jpa:
    open-in-view: false  # DISABLE THIS!
```

**OR in application.properties:**
```properties
spring.jpa.open-in-view=false
```

**Why:** This is especially critical for new applications. It forces you to properly manage transactions in service layer and exposes N+1 queries immediately during development.

### 3. Use spring-boot-compose for Docker Compose Support

**DO:** Add `spring-boot-compose` dependency when using Docker Compose with Spring Boot.

**Prerequisites:**
- Spring Boot 3.1+ (for native compose support)
- Or use the `spring-boot-compose` starter for earlier versions

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-compose</artifactId>
    <scope>runtime</scope>
</dependency>
```

**Use `start-only` by default (unless already defined):**

```yaml
# docker-compose.yml
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password

  redis:
    image: redis:7
    ports:
      - "6379:6379"
```

```yaml
# application.yml
spring:
  docker:
    compose:
      file: docker-compose.yml
      enabled: true
      mode: start-only  # Start services on startup, don't stop on shutdown
      # Only override if you need different behavior:
      # mode: inherit (default - starts and stops with the application)
      # mode: start (start on startup, manual stop)
```

**Why `start-only`:**
- Services start automatically with the application
- Services remain running after the application stops (useful for debugging)
- Prevents accidental service termination during development

**When NOT to use:**
- If you need clean startup/shutdown (use `inherit` or `start`)
- In production environments where you manage containers separately

---

## Configuration Organization

### Hierarchical Properties

```yaml
# application.yml
app:
  external-api:
    base-url: https://api.example.com
    timeout: 5000
    credentials:
      api-key: ${EXTERNAL_API_KEY}
  
  payment:
    gateway: stripe
    retry:
      max-attempts: 3
      backoff-ms: 1000
```

### Use Relaxed Binding

```java
@ConfigurationProperties(prefix = "app.external-api")
public class ExternalApiProperties {
    // Works with: app.external-api.base-url, app.external-api.baseUrl, app.external-api.BASE_URL
    private String baseUrl;
}
```

---

## Profile-Specific Configuration

```java
@Configuration
@ConfigurationProperties(prefix = "app")
@Profile("!test")
public class AppProperties { }
```

### Use Specific Profiles for Secrets

```yaml
# application-prod.yml
app:
  database:
    password: ${DB_PASSWORD}  # From environment variable, never in config files
```

---

## Secrets Management

**DO:** Never hardcode secrets. Use environment variables or dedicated secret management tools.

### Environment Variables (Preferred for Simple Cases)

```java
@ConfigurationProperties(prefix = "app.external-api")
public class ExternalApiProperties {
    
    // Spring automatically resolves ${VAR} from environment
    @NotBlank
    private String apiKey = System.getenv("EXTERNAL_API_KEY");
    
    // Or use SpEL
    @Value("${DB_PASSWORD}")
    private String dbPassword;
}
```

```yaml
# application.yml - NEVER commit actual secrets
app:
  external-api:
    api-key: ${EXTERNAL_API_KEY}  # Resolved from environment
```

### Secrets Management Tools

**For production, use dedicated tools:**

| Tool | Use Case |
|------|----------|
| **HashiCorp Vault** | Enterprise secret management |
| **AWS Secrets Manager** | AWS-native deployments |
| **Azure Key Vault** | Azure deployments |
| **GCP Secret Manager** | GCP deployments |

```java
// Example: AWS Secrets Manager with Spring Cloud AWS
@Configuration
public class SecretsConfig {
    
    @Value("${aws.secretsmanager.secret-name}")
    private String secretName;
    
    @Bean
    public AWSSecretsManager secretsManager() {
        return AWSSecretsManagerBuilder.defaultClient();
    }
}
```

### ❌ NEVER Do This

```java
// BAD: Hardcoded secrets
@Value("${external.api.key:my-secret-key-123}")
private String apiKey;
```

```yaml
# BAD: Secrets in config files
app:
  api-key: "sk-1234567890abcdef"  # NEVER commit this!
```

---

## Validation at Startup

```java
@SpringBootApplication
@ConfigurationPropertiesScan
@Validated
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

This will fail fast at startup if configuration is invalid.

---

## Commands

### Linux/Mac (Bash)

```bash
# Validate configuration on startup
./mvnw spring-boot:run

# Test configuration loading
java -jar app.jar --spring.config.location=file:./config/
```

### Windows (PowerShell)

```powershell
# Validate configuration on startup
mvnw.cmd spring-boot:run

# Test configuration loading
java -jar app.jar --spring.config.location=file:./config/
```

---

## Resources

- **Spring Boot Config Docs**: https://docs.spring.io/spring-boot/docs/current/reference/html/howto-properties-and-configuration.html
- **Configuration Properties**: https://docs.spring.io/spring-boot/docs/current/reference/html/spring-boot-features.html#boot-features-external-config-typesafe-configuration-properties
