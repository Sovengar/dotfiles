---
name: tools-rest-assured
description: >
  RestAssured - fluent API for testing REST APIs.
  Trigger: When writing integration tests for REST APIs, testing HTTP endpoints, or verifying API responses.
decisionFramework: "New project → use RestAssured. Existing project → if no mature solution, use RestAssured. Otherwise keep existing."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# RestAssured

> Fluent API for testing REST APIs.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Use RestAssured |
| **Existing project without mature solution** | → Use RestAssured |
| **Existing project with mature solution** | → Keep existing solution, don't introduce RestAssured |
| **Doubts** | → Ask user |

---

## When to Use

- Testing REST API endpoints
- Integration testing HTTP endpoints
- Verifying JSON responses
- Testing with authentication
- API contract testing

---

## Code Examples

### Basic GET Request

```java
@Test
void getUser_shouldReturn200() {
    given()
        .contentType(ContentType.JSON)
    .when()
        .get("/api/users/1")
    .then()
        .statusCode(200)
        .body("id", equalTo(1))
        .body("name", equalTo("John"));
}
```

### POST Request with Body

```java
@Test
void createUser_shouldReturn201() {
    UserRequest request = new UserRequest("john", "john@example.com");
    
    given()
        .contentType(ContentType.JSON)
        .body(request)
    .when()
        .post("/api/users")
    .then()
        .statusCode(201)
        .body("id", notNullValue());
}
```

### With Authentication

```java
@Test
void protectedEndpoint_withToken() {
    String token = given()
        .contentType(ContentType.JSON)
        .body(new LoginRequest("admin", "password"))
    .when()
        .post("/api/login")
    .then()
        .statusCode(200)
        .extract().path("token");
    
    given()
        .header("Authorization", "Bearer " + token)
    .when()
        .get("/api/admin/users")
    .then()
        .statusCode(200);
}
```

---

## Maven Dependencies

```xml
<dependency>
    <groupId>io.rest-assured</groupId>
    <artifactId>rest-assured</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>io.rest-assured</groupId>
    <artifactId>json-schema-validator</artifactId>
    <scope>test</scope>
</dependency>
```

---

## Commands

```bash
# No specific commands
# Tests run with: ./mvnw test
```

---

## Best Practices

| Pattern | Example |
|---------|---------|
| Extract values | `.extract().path("token")` |
| JSON validation | `.body("id", equalTo(1))` |
| Schema validation | `.matchesJsonSchemaInClasspath("user-schema.json")` |
| Reusable spec | `RequestSpecBuilder` / `ResponseSpecBuilder` |

---

## Resources

- **Official**: https://rest-assured.io/
- **Documentation**: https://rest-assured.io/documentation.html
