# Spring Boot - Observability Best Practices

## When to Use

- Setting up application monitoring
- Implementing distributed tracing
- Configuring health checks
- Setting up metrics collection

---

## Critical Patterns

### 1. Spring Boot Actuator

**DO:** Enable and configure Spring Boot Actuator for production-ready monitoring.

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus,loggers
      base-path: /actuator
  endpoint:
    health:
      show-details: when_authorized
      probes:
        enabled: true
  health:
    livenessstate:
      enabled: true
    readinessstate:
      enabled: true
  info:
    env: true
    java:
      enabled: true
  metrics:
    export:
      simple:
        enabled: true
```

### 2. Health Checks (Liveness & Readiness)

**DO:** Implement proper health checks for Kubernetes/containers.

```java
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    
    private final DataSource dataSource;
    
    @Override
    public Health health() {
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(5)) {
                return Health.up()
                    .withDetail("database", "UP")
                    .withDetail("timeout", "5s")
                    .build();
            }
        } catch (Exception e) {
            return Health.down()
                .withDetail("error", e.getMessage())
                .build();
        }
        return Health.down().build();
    }
}
```

```java
@Component
public class CustomHealthContributor implements ReactiveHealthContributor {
    
    private final ExternalService externalService;
    
    @Override
    public Health health() {
        return Health.custom()
            .withDetail("service", "external")
            .status(externalService.isAvailable() ? Status.UP : Status.DOWN)
            .build();
    }
}
```

### 3. Micrometer Metrics

**DO:** Use Micrometer for application metrics.

```java
// Counter - for counting events
@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final MeterRegistry registry;
    
    public void createOrder(Order order) {
        // Counters
        registry.counter("orders.created", "type", "standard").increment();
        
        // Timers
        Timer.Sample sample = Timer.start(registry);
        // ... process order ...
        sample.stop(Timer.builder("orders.processing.time")
            .tag("type", order.getType())
            .register(registry));
        
        // Gauges - for current values
        registry.gauge("orders.in-progress", ordersInProgress);
    }
}
```

```java
// Custom metrics with @Timed
@Service
@RequiredArgsConstructor
public class PaymentService {
    
    @Timed(value = "payment.processing.time", 
           percentiles = {0.5, 0.95, 0.99},
           histogram = true)
    public PaymentResult processPayment(Payment payment) {
        // ...
    }
}
```

### 4. Distributed Tracing (OpenTelemetry/Zipkin)

**DO:** Add tracing for microservices.

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-tracing-bridge-otel</artifactId>
</dependency>
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-exporter-otlp</artifactId>
</dependency>
```

```yaml
# application.yml
management:
  tracing:
    sampling:
      probability: 0.1  # 10% of traces
    baggage:
      correlation:
        fields:
          - correlationId
          - userId
      propagation:
        type: w3c
  otlp:
    tracing:
      endpoint: http://localhost:4317
```

```java
// Custom span attributes
@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final Tracer tracer;
    
    public Order createOrder(CreateOrderRequest request) {
        Span span = tracer.startSpan("createOrder");
        try {
            span.setAttribute("order.type", request.getType());
            span.setAttribute("customer.id", request.getCustomerId().toString());
            
            // Business logic
            return orderRepo.save(request.toOrder());
        } finally {
            span.end();
        }
    }
}
```

### 5. Logging Correlation IDs

**DO:** Add correlation ID to all logs for tracing.

```java
// Configuration
@Configuration
public class TracingConfig {
    
    @Bean
    public BaggageField correlationIdField() {
        return BaggageField.of("correlationId");
    }
}

// Usage with MDC
@Slf4j
@RestController
public class OrderController {
    
    @GetMapping("/orders/{id}")
    public Order getOrder(@PathVariable Long id) {
        // Correlation ID automatically added to logs
        log.info("Fetching order: orderId={}", id);
        return orderService.findById(id);
    }
}
```

```yaml
# Log pattern with correlation ID
logging:
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] [%X{correlationId}] %-5level %logger{36} - %msg%n"
```

---

## Kubernetes Probes

```yaml
# deployment.yaml
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

```java
// Custom probe indicators
@Component
public class LivenessIndicator implements HealthIndicator {
    
    @Override
    public Health health() {
        // Check if app can handle requests
        if (appReady) {
            return Health.up().build();
        }
        return Health.down().build();
    }
}
```

---

## Prometheus Integration

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'spring-boot-app'
    metrics_path: '/actuator/prometheus'
    scrape_interval: 10s
    static_configs:
      - targets: ['localhost:8080']
```

```java
// Custom Prometheus metrics
@Service
public class MetricsService {
    
    private final Counter orderCounter;
    
    public MetricsService(MeterRegistry registry) {
        this.orderCounter = Counter.builder("orders_total")
            .description("Total orders processed")
            .tag("service", "order-service")
            .register(registry);
    }
    
    public void recordOrder() {
        orderCounter.increment();
    }
}
```

---

## Best Practices Summary

| Area | Practice |
|------|----------|
| **Actuator** | Enable `/actuator/health`, `/actuator/metrics`, `/actuator/prometheus` |
| **Health Checks** | Implement Liveness & Readiness probes |
| **Metrics** | Use Micrometer with counters, timers, gauges |
| **Tracing** | Add OpenTelemetry/Zipkin for distributed tracing |
| **Logging** | Always include correlation ID in logs |
| **Kubernetes** | Configure proper probes for container orchestration |

---

## Commands

```bash
# Check health
curl http://localhost:8080/actuator/health

# Check metrics
curl http://localhost:8080/actuator/metrics

# Prometheus endpoint
curl http://localhost:8080/actuator/prometheus

# Enable debug logging for actuator
logging.level.org.springframework.boot.actuator=DEBUG
```

---

## Resources

- **Spring Boot Actuator**: https://docs.spring.io/spring-boot/docs/current/actuator/html/
- **Micrometer**: https://micrometer.io/docs
- **OpenTelemetry**: https://opentelemetry.io/
- **Spring Cloud Sleuth**: https://spring.io/projects/spring-cloud-sleuth