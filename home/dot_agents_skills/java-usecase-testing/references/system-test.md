# System Tests (Integration Tests)

System tests verify the entire application flow with a real database and mocked external services.

---

## Test Runner Base Class

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@ActiveProfiles("test")              // Use test profile with local database
@Transactional                       // Rollback after each test
@Tag("integration")
@{ModuleTag}                         // Module-specific tag
@{Import}({TestConfig}.class)
public abstract class {Module}AbstractSystemRunner {
  @{MockBean}
  protected {ExternalService} {externalService};

  @{MockBean}
  protected {AnotherExternalService} {anotherService};

  @{Autowired}
  protected {Usecase}Dsl api;

  @{Autowired}
  protected {QueryLoader} result;

  @{BeforeAll}
  static void init() {
    System.setProperty("application.defaultLanguage", "ca-ES");
  }
}
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Full Spring Context** | Load entire application context |
| **Test Database** | Use local/test database profile (not production) |
| **Transaction Rollback** | Each test runs in transaction that rolls back |
| **Mock External Services** | Mock integrations that call external systems |
| **DSL Import** | Import DSL configuration for test fluency |

---

## Complete System Test Example

```java
@{AutoConfigureMockMvc}(addFilters = false)
class {Action}{Usecase}SystemTest extends {Module}AbstractSystemRunner {
  @{Autowired}
  private {Entity}Repository repo;

  @{BeforeEach}
  void setUp() {
    repo.deleteAll();
  }

  @{Nested}
  class Should{Action}Given {
    @{Test}
    void a_non_closed_{entity}() throws Exception {
      api.{action}{Usecase}FromFile("create-{entity}-{type}.json");
      api.{action}{Usecase}({DEFAULT_EXPEDIENT});

      thenVerifyIs{State}(api.load{Usecase}({DEFAULT_ID}));
    }
  }

  @{Test}
  void do_nothing_when_{action}_on_closed_{entity}() throws Exception {
    api.{action}{Usecase}FromFile("create-{entity}-{type}.json");
    api.{action}{Usecase}({DEFAULT_EXPEDIENT});
    api.{action}{Usecase}({DEFAULT_EXPEDIENT});

    thenVerifyIs{State}(api.load{Usecase}({DEFAULT_ID}));
  }

  @{Nested}
  class ShouldFailGiven {
    @{Test}
    void an_unexisting_{field}_code() throws Exception {
      api.{action}{Usecase}FromFile("create-{entity}-{type}.json");

      api.call{Action}{Usecase}({DEFAULT_EXPEDIENT}, "INVALID")
        .andExpect(status().isBadRequest());
    }

    @{Test}
    void an_unexisting_{entity}() throws Exception {
      api.{action}{Usecase}FromFile("create-{entity}-{type}.json");

      api.call{Action}{Usecase}("XXXXX", "CODE")
        .andExpect(status().isNotFound());
    }
  }
}
```

---

## Query System Test Example

```java
@{AutoConfigureMockMvc}(addFilters = false)
class {Query}SystemTest extends {Module}AbstractSystemRunner {

  @{Autowired}
  private MockMvc mockMvc;

  @{Autowired}
  private {Entity}Repository repo;

  @{Test}
  @{DisplayName}("should_return_result_of_{state}_{entity}")
  void should_return_result_of_{state}_{entity}() throws Exception {
    var {entity} = a{Entity}()
      .thatHasArrived()
      .andHasBeen{State}({params})
      .andDevolutivaHasArrived({params})
      .thatIsPersistedIn(repo);

    when(externalService.get{Data}By{Entity}And{Type}(
      {entity}.get{Id}(),
      {entity}.get{Type}Id(),
      {FORMULARI_TYPE})
    ).thenReturn(expectedData());

    mockMvc.perform(get("/{endpoint}/{id}", "{expedient}")
        .accept(MediaType.APPLICATION_JSON))
      .andExpect(result.matches("{query}/{response}.json"));
  }

  // Helper methods for expected data
  private Map<String, Object> expectedData() {
    var map = new HashMap<String, Object>();
    map.put({FIELD}.getFieldName(), {value});
    // ... more fields
    return map;
  }
}
```

---

## Key Characteristics

1. **Real Database**: Uses local/test database
2. **Mocked External Services**: External integrations are mocked
3. **Transaction Rollback**: Each test runs in a transaction that rolls back
4. **Full Stack**: Tests entire flow from HTTP endpoint to DB persistence
5. **Slower than Unit Tests**: Should be tagged with `@Tag("integration")`

---

## Related References

- [structure.md](structure.md) - Naming conventions and @Nested patterns
- [arrange.md](arrange.md) - Test data building (Object Mothers, Data Builders, DSLs)
- [web-test.md](web-test.md) - HTTP Controller tests
- [service-test.md](service-test.md) - Application Service tests
- [domain-test.md](domain-test.md) - Domain model tests
