# Test Data Building: Arrange Phase

This reference covers how to build test data using Object Mothers, Data Builders, and DSLs.

---

## Object Mothers (for Catalogs)

### Purpose

Object Mothers provide **fixed test data** for catalog entities (countries, genders, civil status, etc.). They ensure deterministic tests while also supporting random data generation for robustness testing.

### Structure

```java
public class {Catalog}Mother {
  // Fixed catalog instances
  public static {Catalog} {value1}() { ... }
  public static {Catalog} {value2}() { ... }
  
  // Random for fuzz testing
  public static {Catalog} random() { ... }
}
```

### Usage in Tests

```java
import static {package}.{Catalog}Mother.{value1};
import static {package}.{Catalog}Mother.{value2};

// In test - stub catalog lookup
when(catalogRepository.get{Catalog}ByCodi(any())).thenReturn({value1}(), {value2}());
```

### Shared Mothers Location

```
src/test/java/{package}/_fixtures/
├── {Catalog}Mother.java           # Shared catalog mothers
├── {AnotherCatalog}Mother.java
└── ...
```

### Use Case-Specific Mothers

```
src/test/java/{package}/{usecase}/_fixtures/mothers/
├── {EntitySpecific}Mother.java
├── {AnotherEntity}Mother.java
└── ...
```

---

## Data Builders (for Domain Models & Requests)

### Purpose

Data Builders construct complex test objects (domain models, API requests) with a fluent API. They support both fixed data (from JSON files) and random data generation.

### Example: Request Builder

```java
public class Create{Entity}RequestBuilder {
  private final Create{Entity}Request request;

  private Create{Entity}RequestBuilder(Create{Entity}Request request) {
    this.request = request;
  }

  public static Create{Entity}RequestBuilder fromFile(String jsonFileName) {
    return new Create{Entity}RequestBuilder(fromJsonFile(jsonFileName));
  }

  // Fluent modifiers
  public Create{Entity}RequestBuilder withoutId() {
    request.setId(null);
    return this;
  }

  public Create{Entity}RequestBuilder with{Field}(String {field}) {
    request.get{SubObject}().set{Field}({field});
    return this;
  }

  public Create{Entity}Request build() {
    return request;
  }
}
```

### Usage

```java
// From JSON file for deterministic tests
var request = fromFile("create-{entity}-{type}.json")
  .with{Field}("value")
  .build();

// Random for robustness testing
var randomRequest = Create{Entity}RequestBuilder.random{Type}();
```

### Example: Domain Model Builder

```java
public class {Entity}Builder {
  private {Field1} {field1};
  private {Field2} {field2};
  // ... other fields

  public static {Entity}Builder a{Entity}() {
    return new {Entity}Builder();
  }

  public {Entity}Builder thatHasArrived() {
    // Sets up initial state
    return this;
  }

  public {Entity}Builder andHasBeen{Action}({params}) {
    // Adds action/state
    return this;
  }

  public {Entity}Builder thatIsPersistedIn({Repository} repo) {
    // Persists to database
    return this;
  }

  public {Entity} build() { ... }
}
```

### Usage in System Tests

```java
var {entity} = a{Entity}()
  .thatHasArrived()
  .andHasBeen{Action}({params})
  .andHasBeen{AnotherAction}()
  .thatIsPersistedIn(repo);
```

---

## DSL Pattern (Domain Specific Language)

### Philosophy

The DSL pattern abstracts technical testing details into a **business-readable language** that domain experts can understand. It enables code reuse between different test scopes (system, HTTP, unit).

### Core DSL Structure

Each use case has a **Facade DSL** that composes smaller, focused DSLs:

```
{Usecase}Dsl (Facade - main entry point)
├── {Action1}Dsl (specific action)
├── {Action2}Dsl (specific action)
└── thenVerify* (static verification methods)
```

### Example: Facade DSL

```java
@Facade
@RequiredArgsConstructor
public final class {Usecase}Dsl {
  private final {Repository} {repo};
  private final {Action1}Dsl {action1}Dsl;
  private final {Action2}Dsl {action2}Dsl;

  // Business-language methods
  public {ReturnType} {action1}{Usecase}FromFile(String jsonPath) throws Exception {
    // Abstracts HTTP call, status checks, location extraction
  }

  public void {action2}{Usecase}(String {parameter}) throws Exception {
    // Abstracts the entire {action} flow
  }

  public {Entity} load{Usecase}({IdType} {id}) {
    return {repo}.findBy{IdField}({id}).orElseThrow();
  }
}
```

### Example: Action DSL

```java
public final class {Action}{Usecase}Dsl {
  @Autowired
  private MockMvc mockMvc;

  public ResultActions call{Action}{Usecase}({Request}Builder builder) 
      throws Exception {
    return mockMvc.perform(post("/{endpoint}")
      .contentType(MediaType.APPLICATION_JSON)
      .accept(MediaType.APPLICATION_PROBLEM_JSON_VALUE)
      .content(builder.toJson()));
  }

  // Reusable verification methods (technology-agnostic names)
  public static void thenVerify{Action}IsRejectedBecause(ResultActions result, String expectedDetail) {
    result
      .andExpect(status().isBadRequest())  // Technical detail in DSL only
      .andExpect(jsonPath("$.detail", is(expectedDetail)));
  }

  public static void thenVerify{Entity}IsCorrectlySaved(final {Entity} {entity}) {
    assertThat({entity}.get{Field}()).isEqualTo("expectedValue");
    // ... comprehensive assertions
  }
}
```

### DSL Location

```
src/test/java/{package}/{usecase}/_fixtures/dsl/
├── {Usecase}Dsl.java           # Main facade DSL
├── {Action1}Dsl.java           # Action-specific DSL
├── {Action2}Dsl.java           # Another action DSL
└── {Helper}Dsl.java            # Helper verification methods
```

---

## Test Data Files

### JSON Request Files

```
src/test/resources/messages/commands/{usecase}/
└── create-{entity}-{type}.json
```

### Contract Response Files

```
src/test/resources/contracts/{usecase}/
└── {query}-response.json
```

### Query Response Files

```
src/test/resources/messages/queries/{usecase}/{query}/
└── {query}/{response}.json
```

---

## Related References

- [structure.md](structure.md) - Naming conventions and @Nested patterns
- [system-test.md](system-test.md) - System/Integration tests
- [web-test.md](web-test.md) - HTTP Controller tests
- [service-test.md](service-test.md) - Application Service tests
- [domain-test.md](domain-test.md) - Domain model tests
