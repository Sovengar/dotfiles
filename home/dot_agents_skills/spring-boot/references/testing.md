# Spring Boot - Testing Best Practices

## Decision Framework

> **Rule:** Apply this logic for testing tooling decisions:

### API Testing (RestAssured)

| Scenario | Action |
|----------|--------|
| **New project** | → Use RestAssured |
| **Existing project without mature solution** | → Use RestAssured |
| **Existing project with mature solution** | → Keep existing |
| **Doubts** | → Ask user |

→ See [tools-rest-assured skill](../tools-rest-assured/SKILL.md)

### Async Testing (Awaitility)

| Scenario | Action |
|----------|--------|
| **New project** | → Use Awaitility |
| **Existing project without mature solution** | → Use Awaitility |
| **Existing project with mature solution** | → Keep existing |
| **Doubts** | → Ask user |

→ See [tools-awaitility skill](../tools-awaitility/SKILL.md)

> ⚠️ For database integration testing (TestContainers), see [configuration.md](configuration.md)

---

## When to Use

- Writing unit tests for services
- Writing integration tests
- Using test slices
- Using Testcontainers for database testing

---

## Critical Patterns

### 1. Abstract Base Class for Integration Tests

**DO:** Create a shared abstract base class for integration tests to avoid loading Spring context multiple times.

```java
// Abstract integration test base - shared context
@ExtendWith(SpringExtension.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public abstract class AbstractIntegrationTest {
    
    @LocalServerPort
    private int port;
    
    @BeforeEach
    void setUp() {
        RestAssured.port = port;
    }
}

// All integration tests extend this base class
public class OrderIntegrationTest extends AbstractIntegrationTest {
    
    @Test
    @Order(1)
    void createOrder_shouldReturn201() {
        // Test implementation
        given()
            .contentType(ContentType.JSON)
            .body(createOrderRequest)
        .when()
            .post("/orders")
        .then()
            .statusCode(201);
    }
    
    @Test
    @Order(2)
    void getOrder_shouldReturnOrder() {
        // Test implementation
    }
}
```

**WHY:** Each new `@SpringBootTest` context takes time to start. By extending a common base class, Spring only loads the context once.

### 2. Test Slices

**DO:** Use test slices to test specific parts of the application in isolation.

| Test Slice | Use For | Annotation |
|------------|---------|------------|
| `@WebMvcTest` | Controllers only | `mockMvc` |
| `@DataJpaTest` | JPA repositories | `TestEntityManager` |
| `@RestClientTest` | REST clients | `RestTemplate` |
| `@JsonTest` | JSON serialization | - |
| `@BootTest` | Full integration | - |

#### @WebMvcTest - Controller Testing

```java
@WebMvcTest(OrderController.class)
class OrderControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private OrderService orderService;
    
    @Test
    void createOrder_shouldReturn201() throws Exception {
        // Given
        CreateOrderRequest request = new CreateOrderRequest(...);
        doNothing().when(orderService).createOrder(any());
        
        // When & Then
        mockMvc.perform(post("/orders")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated());
    }
}
```

#### @DataJpaTest - Repository Testing

```java
@DataJpaTest
class UserRepoTest {
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepo userRepo;
    
    @Test
    void findByEmail_shouldReturnUser() {
        // Given
        User user = new User("test@example.com", "Test User");
        entityManager.persist(user);
        entityManager.flush();
        
        // When
        Optional<User> found = userRepo.findByEmail("test@example.com");
        
        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getEmail()).isEqualTo("test@example.com");
    }
}
```

### Testcontainers Reuse Configuration

**DO:** Create `testcontainers.properties` to enable container reuse across test runs (faster CI).

```properties
# src/test/resources/testcontainers.properties
ryuk.container.enabled=false
testcontainers.reuse.enabled=true
```

**Why:**
- Containers are reused between test runs (no need to restart for every test)
- Much faster CI pipelines
- Ryuk (cleanup container) disabled to avoid interference

**Warning:** Only use in development/CI. In production-like environments, ensure containers are properly managed.

```yaml
# Alternative: docker-compose for local development
# docker-compose.yml for local test databases
services:
  postgres-test:
    image: postgres:15
    environment:
      POSTGRES_DB: testdb
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
    ports:
      - "5432:5432"
```

### 3. Testcontainers for Real Databases

**DO:** Use Testcontainers for reliable integration tests with real databases.

```java
@Testcontainers
class OrderRepoIT {
    
    @Container
    private static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test");
    
    @DynamicPropertySource
    static void properties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
    
    @Autowired
    private OrderRepo orderRepo;
    
    @Test
    void findByStatus_shouldReturnOrders() {
        // Given
        Order order = new Order();
        order.setStatus(OrderStatus.PENDING);
        orderRepo.save(order);
        
        // When
        List<Order> orders = orderRepo.findByStatus(OrderStatus.PENDING);
        
        // Then
        assertThat(orders).hasSize(1);
    }
}
```

#### Multiple Testcontainers

```java
@Testcontainers
class PaymentServiceIT {
    
    @Container
    private static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");
    
    @Container
    private static RedisContainer<?> redis = new RedisContainer("redis:7");
    
    @DynamicPropertySource
    static void properties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add("spring.data.redis.host", redis::getHost);
        registry.add("spring.data.redis.port", redis::getMappedPort);
    }
}
```

### 4. Unit Testing Services

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
    
    @Mock
    private OrderRepo orderRepo;
    
    @Mock
    private InventoryService inventoryService;
    
    @InjectMocks
    private OrderService orderService;
    
    @Test
    void createOrder_shouldSaveOrder() {
        // Given
        CreateOrderRequest request = new CreateOrderRequest(
            List.of(new OrderItemRequest(1L, 2)),
            1L,
            "address"
        );
        
        when(orderRepo.save(any(Order.class))).thenAnswer(invocation -> {
            Order order = invocation.getArgument(0);
            order.setId(1L);
            return order;
        });
        
        // When
        OrderResponse response = orderService.createOrder(request);
        
        // Then
        assertThat(response.id()).isEqualTo(1L);
        verify(inventoryService).reserveItems(any());
        verify(orderRepo).save(any(Order.class));
    }
}
```

### 5. Parameterized Tests

```java
@ParameterizedTest
@CsvSource({
    "1, true",
    "0, false", 
    "-1, false"
})
void isValidQuantity_shouldReturnExpected(int quantity, boolean expected) {
    assertThat(OrderValidator.isValidQuantity(quantity)).isEqualTo(expected);
}

@ParameterizedTest
@MethodSource("invalidOrderRequests")
void createOrder_shouldThrowException(OrderRequest request) {
    assertThatThrownBy(() -> orderService.createOrder(request))
        .isInstanceOf(ValidationException.class);
}

static List<OrderRequest> invalidOrderRequests() {
    return List.of(
        new OrderRequest(null, List.of()),  // null customer
        new OrderRequest(1L, List.of())     // empty items
    );
}
```

---

## Anti-Patterns to Avoid

### ❌ Each Integration Test Loads Its Own Context

```java
// BAD: Each test loads a new Spring context
@SpringBootTest
class OrderTest1 { }

@SpringBootTest
class OrderTest2 { }

@SpringBootTest
class OrderTest3 { }  // Slow - loads context every time
```

**Solution:** Use a common abstract base class.

### ❌ Using @SpringBootTest When Test Slices Suffice

```java
// BAD: Using full context for controller test
@SpringBootTest
@AutoConfigureMockMvc
class OrderControllerTest { }
```

**Solution:** Use `@WebMvcTest` for faster tests.

```java
// GOOD: Test slice
@WebMvcTest(OrderController.class)
class OrderControllerTest { }
```

### ❌ Testing Without Cleanup

```java
// BAD: Data persists between tests
@Test
void test1() {
    userRepo.save(new User("test@test.com"));
}

@Test
void test2() {
    // May fail due to leftover data from test1
    userRepo.save(new User("test@test.com"));
}
```

**Solution:** Use `@Transactional` for rollback or clean up in `@AfterEach`.

```java
@Transactional  // Rolls back after each test
@Test
void test1() {
    userRepo.save(new User("test@test.com"));
}
```

### ❌ Hardcoded Test Data

```java
// BAD: Hardcoded values
@Test
void testOrder() {
    Order order = new Order();
    order.setId(1L);
    // ...
}
```

**Solution:** Use test factories or builders.

```java
// GOOD: Test factory
@Test
void testOrder() {
    Order order = OrderFactory.createDefault();
    // ...
}
```

---

## Test Configuration

### Test Application Properties

```yaml
# src/test/resources/application.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
  jpa:
    hibernate:
      ddl-auto: create-drop
  security:
    user:
      name: test
      password: test
```

### Test Profiles

```java
@ActiveProfiles("test")
@SpringBootTest
class IntegrationTest { }
```

---

## Commands

```bash
# Run only unit tests (Linux/Mac)
./mvnw test -Dtest=*ServiceTest

# Run integration tests (Linux/Mac)
./mvnw verify -Dtest=*IT

# Run tests with coverage (Linux/Mac)
./mvnw test -Dcoverage

# Skip tests (Linux/Mac)
./mvnw clean package -DskipTests
```

### Windows (PowerShell)

```powershell
# Run only unit tests
mvnw.cmd test -Dtest=*ServiceTest

# Run integration tests
mvnw.cmd verify -Dtest=*IT

# Run tests with coverage
mvnw.cmd test -Dcoverage

# Skip tests
mvnw.cmd clean package -DskipTests
```

---

## Resources

- **Spring Boot Testing**: https://docs.spring.io/spring-boot/docs/current/reference/html/spring-boot-features.html#boot-features-testing
- **Testcontainers**: https://www.testcontainers.org/
- **RestAssured**: https://rest-assured.io/
