# Application Service Tests (Unit Tests)

Application Service tests verify use case logic with mocked dependencies. These are unit tests focused on business logic.

---

## Test Setup

```java
@{ExtendWith}(MockitoExtension.class)
final class {Action}{Usecase}Test {
  private {Repository} {repo};

  @{Mock}
  private {Handler} {handler};

  @{Mock}
  private {ExternalService} {service};

  @{Mock}
  private {Builder}.CatalogRepository catalogRepository;

  private {UseCase} when;

  @{BeforeEach}
  void setUp() {
    var {inMemoryRepo} = new {InMemoryRepository}();
    {repo} = Mockito.spy({inMemoryRepo});

    var builder = new {Builder}(catalogRepository);
    var {em} = Mockito.mock(EntityManager.class);
    when = new {UseCase}({repo}, builder, {handler}, {em}, {service});
  }
}
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Mockito Extension** | Enable Mockito annotations |
| **Mock Dependencies** | Create mocks for service dependencies |
| **Catalog Stubbing** | Mock catalog lookups |
| **In-Memory Repository** | Use in-memory implementation for testing |

---

## Catalog Stubbing

Helper method to stub catalog responses:

```java
private void stubCatalogs() {
  when(catalogRepository.get{Catalog}ByCodi(any())).thenReturn({value1}(), {value2}());
  when(catalogRepository.get{AnotherCatalog}ByCodi(any())).thenReturn({value}());
  when(catalogRepository.get{State}ByCodi(any())).thenReturn({state}());
  // ... more catalog stubs
}
```

---

## Complete Application Service Test Example

```java
@{ExtendWith}(MockitoExtension.class)
final class {Action}{Usecase}Test {
  private {Repository} {repo};

  @{Mock}
  private {Handler} {handler};

  @{Mock}
  private {ExternalService} {service};

  @{Mock}
  private {Builder}.CatalogRepository catalogRepository;

  private {UseCase} when;

  @{BeforeEach}
  void setUp() {
    var {inMemoryRepo} = new {InMemoryRepository}();
    {repo} = Mockito.spy({inMemoryRepo});

    var builder = new {Builder}(catalogRepository);
    var {em} = Mockito.mock(EntityManager.class);
    when = new {UseCase}({repo}, builder, {handler}, {em}, {service});
  }

  @{Nested}
  class Should{Action}Given {
    @{BeforeEach}
    void setUp() {
      stubCatalogs();
    }

    @{Test}
    void of_{type}() throws Exception {
      when(catalogRepository.get{Type}ByCodi(any())).thenReturn({type}());
      when.{action}(fromJsonFile("create-{entity}-{type}.json"));
      thenVerify{Entity}IsCorrectlySaved(load{Entity}({DEFAULT_ID}));
    }

    @{Test}
    void of_{another_type}() throws Exception {
      when(catalogRepository.get{Type}ByCodi(any())).thenReturn({anotherType}());
      when.{action}(fromJsonFile("create-{entity}-{anotherType}.json"));
      thenVerify{Entity}IsCorrectlySaved(load{Entity}({ANOTHER_ID}));
    }

    @{Test}
    @Tag("robustness")
    @Tag("fuzz")
    void of_{type}_with_random_data() {
      when(catalogRepository.get{Type}ByCodi(any())).thenReturn({type}());
      when.{action}(random{Type}());
      verify({repo}).create(any());
    }
  }

  @{Test}
  void should_return_early_when_same_request_arrives_twice() throws Exception {
    stubCatalogs();
    when(catalogRepository.get{Type}ByCodi(any())).thenReturn({type}());
    when.{action}(fromJsonFile("create-{entity}-{type}.json"));
    when.{action}(fromJsonFile("create-{entity}-{type}.json"));

    verify({repo}, atMostOnce()).create(any());
    verify({handler}, atMostOnce()).{handleMethod}(any());
  }

  @{Test}
  void should_generate_{field}_when_not_given() throws Exception {
    stubCatalogs();
    when(catalogRepository.get{Type}ByCodi(any())).thenReturn({type}());

    var generatedKey = when.{action}(fromFile("create-{entity}-{type}.json").withoutId().build());

    assertThat(generatedKey).isNotEqualTo({DEFAULT_ID});
  }

  @{Test}
  void should_invoke_{handler}() throws Exception {
    stubCatalogs();
    when(catalogRepository.get{Type}ByCodi(any())).thenReturn({type}());
    when.{action}(fromJsonFile("create-{entity}-{type}.json"));
    verify{Handler}IsCalled();
  }

  @{Test}
  @Tag("Technical")
  void should_invoke_external_service() throws Exception {
    stubCatalogs();
    when(catalogRepository.get{Type}ByCodi(any())).thenReturn({type}());
    when.{action}(fromJsonFile("create-{entity}-{type}.json"));
    verify{ExternalService}IsCalled();
  }

  @{Test}
  void should_cleanup_when_external_service_fails() {
    stubCatalogs();
    when(catalogRepository.get{Type}ByCodi(any())).thenReturn({type}());

    Mockito.doThrow(new RuntimeException("error"))
      .when({service}).{method}(any());

    assertThatThrownBy(() -> when.{action}(fromJsonFile("create-{entity}-{type}.json")))
      .isInstanceOf(RuntimeException.class);
    verify({handler}, atMostOnce()).delete{Entity}(load{Entity}({DEFAULT_ID}).get{Id}());
  }

  @{Nested}
  class ShouldFailGiven {
    @{Test}
    void {field}_is_invalid() {
      when(catalogRepository.get{Catalog}ByCodi(any())).thenReturn(null);

      assertThatThrownBy(() -> when.{action}(requestWithInvalid{Field}()))
        .isInstanceOf(IllegalArgumentException.class);
    }
  }

  // Helper methods
  private void stubCatalogs() {
    when(catalogRepository.get{Catalog1}ByCodi(any())).thenReturn({value1}(), {value2}());
    when(catalogRepository.get{Catalog2}ByCodi(any())).thenReturn({value}());
    // ... more catalog stubs
  }

  private {Entity} load{Entity}(final {IdType} {id}) {
    return {repo}.findBy{IdField}({id}).orElseThrow();
  }

  private void verify{Handler}IsCalled() {
    var {entity} = load{Entity}({DEFAULT_ID});
    verify({handler}, atMostOnce()).{handleMethod}({entity});
  }

  private void verify{ExternalService}IsCalled() {
    var {entity} = load{Entity}({DEFAULT_ID});
    var {json} = {Mapper}.INSTANCE.entityToJson({entity}.get{BaseEntity}());
    verify({service}, atMostOnce()).{method}({json});
  }
}
```

---

## In-Memory Repository

For unit testing, use in-memory implementations of repositories:

```java
public class {InMemoryRepository} implements {Repository} {
  private final Map<{IdType}, {Entity}> store = new ConcurrentHashMap<>();

  @{Override}
  public Optional<{Entity}> findBy{IdField}({IdType} {id}) {
    return store.values().stream()
      .filter(e -> e.get{IdField}().equals({id}))
      .findFirst();
  }

  @{Override}
  public {Entity} create({Entity} {entity}) {
    store.put({entity}.get{Id}(), {entity});
    return {entity};
  }

  // ... other methods
}
```

---

## Key Characteristics

1. **Mocked Dependencies**: All external dependencies are mocked
2. **Fast Execution**: No database or external services
3. **Focused Testing**: Tests single use case logic
4. **In-Memory Storage**: Uses in-memory repository for testing
5. **Catalog Stubbing**: Mocks catalog lookups

---

## Related References

- [structure.md](structure.md) - Naming conventions and @Nested patterns
- [arrange.md](arrange.md) - Test data building (Object Mothers, Data Builders, DSLs)
- [system-test.md](system-test.md) - System/Integration tests
- [web-test.md](web-test.md) - HTTP Controller tests
- [domain-test.md](domain-test.md) - Domain model tests
