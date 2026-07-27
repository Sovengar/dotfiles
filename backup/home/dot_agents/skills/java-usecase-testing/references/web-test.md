# Web Layer Tests (HTTP Controller Tests)

Web tests verify the REST API layer: contract testing, request mapping, validation, exception mapping, and security isolation.

---

## Test Runner

```java
@{TestRunnerAnnotation}              // Disable security filters for test isolation
@{WebMvcTest}({ControllerClass}.class)
@{Import}({UseCaseDsl}.class)
public class {UseCase}HttpControllerTest extends {BaseInitializer} {
  @{MockBean}
  private {UseCaseService} mock;
  
  @{Autowired}
  private {UseCase}Dsl api;
}
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Security Isolation** | Disable security filters for fast unit tests |
| **Web Context** | Load only controller and related beans |
| **Mock Service** | Mock service dependencies |
| **DSL Import** | Import DSL configuration |

---

## Contract Testing

Verify response JSON matches expected contract file.

```java
@Test
void should_match_contract() throws Exception {
  // Build mock response with all fields
  var mockResult = {Response}.builder()
    .{field1}("{value1}")
    .{field2}({value2})
    .{nested}({Nested}.builder()
      .{field}("{value}")
      .build())
    // ... complete response structure
    .build();

  when(mock.{method}(anyString())).thenReturn(mockResult);

  api.call{Action}("{id}")
    .andExpect(matchesContract("{response}.json"));
}
```

Contract files location:
```
src/test/resources/contracts/{usecase}/
└── {query}-response.json
```

---

## Request Mapping

Verify JSON correctly deserializes to request object.

```java
@Test
void should_map_request_correctly() throws Exception {
  // Just verify the endpoint accepts and processes the request
  api.call{Action}("{param1}", "{param2}")
    .andExpect(status().isNoContent());
}
```

---

## Validation Tests

Test Bean Validation annotations (`@NotBlank`, `@NotNull`, `@Size`, etc.).

```java
@Nested
class ShouldFailGiven {
  @Test
  void {field}_has_no_value() throws Exception {
    var request = api.call{Action}(" ", "{code}");
    thenVerifyValidationErrorReported(request, "{field} or {anotherField} has no value");
  }

  @Test
  void {field}_is_blank() throws Exception {
    var request = api.call{Action}("{value}", " ");
    thenVerifyValidationErrorReported(request, "{field} or {anotherField} has no value");
  }
}
```

### Common Validation Annotations

| Annotation | Purpose |
|------------|---------|
| `@NotBlank` | Field cannot be blank/empty string |
| `@NotNull` | Field cannot be null |
| `@Size` | String length constraints |
| `@Pattern` | Regex validation |
| `@Valid` | Nested object validation |

---

## Domain Exception Mapping

Map domain exceptions to appropriate HTTP error codes.

```java
@Nested
class ShouldFailGiven {
  @Test
  void {field}_is_invalid() throws Exception {
    // Domain validation exception maps to 400 Bad Request
    when(mock.{action}(request.build()))
      .thenThrow(new IllegalArgumentException("{error message}"));

    var result = api.call{Action}(request);
    thenVerifyBadRequest(result, "{error message}");
  }

  @Test
  void {entity}_not_found() throws Exception {
    // Not found exception maps to 404
    when(mock.{query}("{id}"))
      .thenThrow(new {Entity}NotFound("{message}"));

    var request = api.call{Query}("{id}");
    thenVerifyNotFound(request, "{message}");
  }

  @Test
  void query_error_occurs() throws Exception {
    // Generic exceptions map to 500 with error code
    when(mock.{query}("{id}"))
      .thenThrow(new {Query}Exception("{error}"));

    var request = api.call{Query}("{id}");
    thenVerifyInternalError(request, "Error {querying} the {entity}", "{error}", "{code}");
  }

  @Test
  void external_service_fails() throws Exception {
    when(mock.{query}("{id}"))
      .thenThrow(new {Service}Exception("{error}"));

    var request = api.call{Query}("{id}");
    thenVerifyInternalError(request, "Error {querying} the {entity}", "{error}", "{code}");
  }
}
```

### Exception Mapping Table

| Domain Exception | HTTP Status | Error Code | DSL Method |
|------------------|-------------|------------|------------|
| `IllegalArgumentException` | 400 Bad Request | - | `thenVerifyBadRequest()` |
| `NotFoundException` | 404 Not Found | - | `thenVerifyNotFound()` |
| `ValidationException` | 400 Bad Request | Custom | `thenVerifyValidationError()` |
| `QueryException` | 500 Internal Server Error | Custom | `thenVerifyInternalError()` |
| `ServiceException` | 500 Internal Server Error | Custom | `thenVerifyInternalError()` |

---

## DSL Verification Methods

Common verification methods used in HTTP controller tests:

```java
// 400 Bad Request
public static void thenVerifyBadRequest(ResultActions result, String expectedDetail) {
  result
    .andExpect(status().isBadRequest())
    .andExpect(jsonPath("$.type", is("about:blank")))
    .andExpect(jsonPath("$.title", is("Bad Request")))
    .andExpect(jsonPath("$.status", is(400)))
    .andExpect(jsonPath("$.detail", is(expectedDetail)));
}

// 404 Not Found
public static void thenVerifyNotFound(ResultActions result, String detail) throws Exception {
  result
    .andExpect(status().isNotFound())
    .andExpect(jsonPath("$.title", is("{Entity} not found")))
    .andExpect(jsonPath("$.status", is(404)))
    .andExpect(jsonPath("$.detail", is(detail)));
}

// 500 Internal Server Error with error code
public static void thenVerifyInternalError(
    ResultActions result, String title, String detail, String errorCode) throws Exception {
  result
    .andExpect(status().isInternalServerError())
    .andExpect(jsonPath("$.title", is(title)))
    .andExpect(jsonPath("$.detail", is(detail)))
    .andExpect(jsonPath("$.errorCode", is(errorCode)));
}

// 400 Validation Error
public static void thenVerifyValidationErrorReported(ResultActions result, String detail) throws Exception {
  result
    .andExpect(status().isBadRequest())
    .andExpect(jsonPath("$.type", is("about:blank")))
    .andExpect(jsonPath("$.title", is("Bad Request")))
    .andExpect(jsonPath("$.status", is(400)))
    .andExpect(jsonPath("$.detail", is(detail)));
}
```

---

## Complete HTTP Controller Test Example

```java
@{TestRunnerAnnotation}
@{WebMvcTest}({Action}{Usecase}HttpController.class)
@{Import}({Action}{Usecase}Dsl.class)
final class {Action}{Usecase}HttpControllerTest extends {BaseInitializer} {
  @{MockBean}
  private {Action}{Usecase} mock;

  @{Autowired}
  private {Action}{Usecase}Dsl api;

  @{Test}
  void should_return_{identifier}_when_{action}_a_{entity}() throws Exception {
    var {identifier} = {IdentifierType}.randomUUID();
    when(mock.{action}(any())).thenReturn({identifier});

    api.call{Action}(fromFile("create-{entity}-{type}.json").withoutId())
      .andExpect(status().isCreated())
      .andExpect(header().exists("Location"))
      .andExpect(jsonPath("$").value({identifier}.toString()));
  }

  @{Nested}
  class ShouldFailGiven {
    @{Test}
    void {field}_is_invalid() throws Exception {
      var request = fromFile("create-{entity}-{type}.json")
        .with{Field}("INVALID");

      when(mock.{action}(request.build()))
        .thenThrow(new IllegalArgumentException("The {field} INVALID is not valid"));

      var result = api.call{Action}(request);
      thenVerifyBadRequest(result, "The {field} INVALID is not valid");
    }

    @{Test}
    void {another_field}_is_invalid() throws Exception {
      var request = fromFile("create-{entity}-{type}.json")
        .with{AnotherField}("INVALID");

      when(mock.{action}(request.build()))
        .thenThrow(new IllegalArgumentException("The {another_field} INVALID is not valid"));

      var result = api.call{Action}(request);
      thenVerifyBadRequest(result, "The {another_field} INVALID is not valid");
    }
  }
}
```

---

## Related References

- [structure.md](structure.md) - Naming conventions and @Nested patterns
- [arrange.md](arrange.md) - Test data building (Object Mothers, Data Builders, DSLs)
- [system-test.md](system-test.md) - System/Integration tests
- [service-test.md](service-test.md) - Application Service tests
- [domain-test.md](domain-test.md) - Domain model tests
