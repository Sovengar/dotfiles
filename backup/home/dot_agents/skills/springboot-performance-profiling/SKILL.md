---
name: springboot-performance-profiling
description: >
  Spring Boot / Java backend performance profiling - JVM analysis, database queries,
  HTTP endpoint timing, GC analysis. Measure, analyze, optimize - in that order.
tags: [springboot, java, performance, profiling, jvm, backend]
triggers: [springboot-performance, java-performance, jvm-profiling, slow-query, memory-leak, backend-performance]
---

# Spring Boot Performance Profiling

> Measure, analyze, optimize - in that order.

---

## 1. JVM Profiling

### Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| **VisualVM** | GUI profiling | `jvisualvm` |
| **JProfiler** | Commercial profiler | IDE plugin |
| **async-profiler** | Low-overhead | `async-profiler.sh` |
| **JConsole** | JMX monitoring | `jconsole` |

### Key Metrics

| Metric | What to Watch |
|--------|---------------|
| CPU usage | High CPU = expensive operations |
| Memory heap | Growing heap = potential leak |
| Thread count | Thread explosion |
| GC frequency | Too many GC = memory pressure |

---

## 2. Thread Dumps

### Capture

```bash
# Get PID
jps -l

# Thread dump
jstack <pid>

# Thread dump with timestamp
jstack -l <pid> > threaddump.txt
```

### Analysis

| Pattern | Meaning |
|---------|---------|
| RUNNABLE but stuck | Infinite loop, busy wait |
| WAITING on lock | Contention |
| BLOCKED | Deadlock risk |
| Many threads same stack | Thread starvation |

---

## 3. Heap Analysis

### Capture Heap Dump

```bash
# jmap
jmap -dump:format=b,file=heap.hprof <pid>

# JVisualVM
Right click on process → Heap Dump
```

### Analyze

| Tool | Purpose |
|------|---------|
| **MAT (Eclipse Memory Analyzer)** | Leak detection |
| **VisualVM** | Heap overview |
| **jcmd** | `jcmd <pid> GC.heap_info` |

### Common Issues

| Pattern | Meaning |
|---------|---------|
| Growing heap | Memory leak |
| Large retained size | Retained objects |
| Many String objects | String concatenation |

---

## 4. Spring Boot Actuator

### Enable

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,trace,prometheus
  endpoint:
    health:
      show-details: always
```

### Key Endpoints

| Endpoint | Shows |
|----------|-------|
| `/actuator/health` | Application health |
| `/actuator/metrics` | All metrics |
| `/actuator/metrics/{name}` | Specific metric |
| `/actuator/trace` | Request traces |
| `/actuator/prometheus` | Prometheus format |

### Useful Metrics

| Metric | Meaning |
|--------|---------|
| `jvm.memory.used` | Heap memory used |
| `process.cpu.usage` | CPU usage |
| `http.server.requests` | Request timing |

---

## 5. Database Performance

### Slow Query Log

```properties
# application.properties
spring.jpa.properties.hibernate.generate_statistics=true
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE
```

### EXPLAIN Analysis

```sql
-- PostgreSQL
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- MySQL
EXPLAIN FORMAT=JSON SELECT * FROM users WHERE email = 'test@example.com';
```

### What to Look For

| Issue | Indicator |
|-------|-----------|
| Full table scan | Seq Scan in PostgreSQL |
| Missing index | Using filesort |
| N+1 queries | Multiple queries in logs |
| Large result set | LIMIT missing |

---

## 6. GC Analysis

### Enable GC Logs

```bash
# JVM args
-Xlog:gc*:file=gc.log:time,uptime,level,tags
```

### Analyze

| Tool | Purpose |
|------|---------|
| **GCViewer** | GC log analysis |
| **GCEasy** | Online GC analysis |
| **jstat** | `jstat -gc <pid>` |

### GC Patterns

| Pattern | Meaning | Action |
|---------|---------|--------|
| Frequent GC | Memory pressure | Increase heap |
| Full GC pauses | Stop-the-world | Tune GC |
| Old gen growing | Memory leak | Find leak source |

---

## 7. HTTP Endpoint Timing

### Actuator Timing

```bash
# Request timing via actuator
curl "http://localhost:8080/actuator/metrics/http.server.requests"
```

### Custom Timing

```java
// Using Micrometer
@Timed("my.endpoint.time")
@GetMapping("/api/users")
public List<User> getUsers() { ... }
```

### Timing Categories

| Category | Target | Action if Slow |
|----------|--------|----------------|
| Database | < 100ms | Query optimization |
| External API | < 200ms | Caching, async |
| Business logic | < 50ms | Algorithm optimization |

---

## 8. Common Bottlenecks

| Symptom | Likely Cause | Solution |
|---------|--------------|-----------|
| Slow response | N+1 queries | Batch fetch |
| High memory | Large collections | Pagination |
| Thread starvation | Blocking I/O | Async |
| GC pauses | Memory pressure | Tune heap/GC |
| DB timeout | Slow query | Index, optimize |

---

## 9. Quick Win Priorities

| Priority | Action | Impact |
|----------|--------|--------|
| 1 | Add database indexes | High |
| 2 | Enable query caching | High |
| 3 | Async for blocking ops | Medium |
| 4 | Tune JVM heap/GC | Medium |
| 5 | Pagination for large results | Medium |

---

## 10. Anti-Patterns

| ❌ Don't | ✅ Do |
|----------|-------|
| Guess at problems | Profile first |
| Increase heap blindly | Find root cause |
| Sync for external calls | Async |
| Load all in memory | Pagination |
| Ignore logs | Read GC/logs |

---

> **Remember:** The fastest code is code that doesn't run. Optimize queries before scaling.
