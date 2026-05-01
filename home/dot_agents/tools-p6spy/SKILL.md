---
name: tools-p6spy
description: >
  P6Spy - SQL query logging and debugging interceptor.
  Trigger: When debugging SQL queries, analyzing query performance, or logging all database statements.
decisionFramework: "New project → use P6Spy. Existing project → if no mature solution, use P6Spy. Otherwise keep existing."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# P6Spy

> SQL query logging and debugging interceptor.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Use P6Spy |
| **Existing project without mature solution** | → Use P6Spy |
| **Existing project with mature solution** | → Keep existing solution, don't introduce P6Spy |
| **Doubts** | → Ask user |

---

## When to Use

- Debugging SQL queries in development
- Analyzing query performance (timing)
- Logging all database statements
- Inspecting prepared statement parameters
- Finding N+1 query problems

---

## Critical Patterns

### How It Works

P6Spy sits between your application and the JDBC driver, intercepting all SQL statements.

```
Application → P6Spy Driver → Real JDBC Driver → Database
```

### Key Features

| Feature | Description |
|---------|-------------|
| **SQL Logging** | Logs all SQL statements |
| **Timing** | Shows execution time per query |
| **Parameter Logging** | Shows bound parameter values |
| **Connection Info** | Shows connection ID and details |

---

## Maven Dependencies

```xml
<dependency>
    <groupId>p6spy</groupId>
    <artifactId>p6spy</artifactId>
    <version>3.9.1</version>
    <scope>runtime</scope>
</dependency>
```

---

## Configuration

### Application Properties

```yaml
spring:
  datasource:
    driver-class-name: com.p6spy.engine.spy.P6SpyDriver
    url: jdbc:p6spy:postgresql://localhost:5432/mydb
```

### Log Configuration (logback.xml)

```xml
<appender name="spy" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>spy.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <fileNamePattern>spy.%d{yyyy-MM-dd}.log</fileNamePattern>
        <maxHistory>7</maxHistory>
    </rollingPolicy>
    <encoder>
        <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %5p --- %m%n</pattern>
    </encoder>
</appender>

<logger name="p6spy" level="DEBUG" additivity="false">
    <appender-ref ref="spy"/>
</logger>
```

---

## Code Examples

### Example Output

```
2024-01-15 10:30:45.123 DEBUG --- | took 15ms | connection: 5 | statement:1 | 
  select * from users where email = 'test@example.com'

2024-01-15 10:30:45.456 DEBUG --- | took 3ms | connection: 5 | statement:2 | 
  insert into orders (id, status) values (1, 'PENDING')
```

### Log Format Customization

```properties
logMessageFormat=com.p6spy.engine.spy.appender.CustomMessageFormat
customLogMessageFormat=%(executionTime)ms | %(connectionId) | %(sql)
```

---

## Commands

```bash
# No specific commands - runs automatically when configured
# Just tail the spy.log file
tail -f spy.log
```

---

## Resources

- **Official**: https://p6spy.readthedocs.io/
- **GitHub**: https://github.com/p6spy/p6spy
- **Configuration**: https://p6spy.readthedocs.io/en/latest/configandusage.html
