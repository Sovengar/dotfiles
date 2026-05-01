---
name: testing-principles
description: >
  Testing principles - test behavior not implementation, mocking guidelines.
  Trigger: When writing tests, deciding mocking strategy, or reviewing test quality.
tags: [testing, principles, mocks, test-quality, behavior-testing]
triggers: [testing-principles, test-behavior, mocking, test-review, how-to-test]
---

# Testing Principles

> Test behavior, not implementation.

---

## When to Use

- Writing new tests
- Reviewing test quality
- Deciding mocking strategy
- Understanding what to assert
- Creating test conventions for a project

---

## Test Structure

- Los nombres siguen camelCase y con un plugin se mostraran bien
- Follow the Arrange-Act-Assert (AAA) pattern. Mas o menos.

---

## Standard Tests

- Keep tests focused on a single behavior.
- Avoid testing multiple conditions in one test method.
- Make tests independent and idempotent (can run in any order).
- Avoid test interdependencies.

---

## Critical Patterns

### Test Behavior, Not Implementation

| ❌ Test IMPLEMENTATION | ✅ Test BEHAVIOR |
|------------------------|-------------------|
| `assertEquals(2, result.size())` | `assertThat(result).hasSize(2)` |
| `verify(mock).callMethod()` | `assertThat(response.isValid()).isTrue()` |
| Testing internal state | Testing observable outcomes |
| Testing "how it does it" | Testing "what it does" |

### Name Tests by Behavior

| ❌ Wrong (implementation) | ✅ Correct (behavior) |
|-------------------------|----------------------|
| `testCalculateTotalWithTax()` | `test_total_includes_tax()` |
| `testVerifyUserIsInList()` | `test_user_can_be_found_by_email()` |
| `testMockServiceReturnsList()` | `test_returns_all_active_users()` |

### Assert Outcomes, Not Internal State

- Test the output that the caller sees
- Don't test private methods or internal fields
- Don't assert on objects you don't own
- Focus on observable behavior

---

## Code Examples

### Behavior Testing

```java
// ❌ BAD: Testing implementation
@Test
void testHashMapPutsValue() {
    Map<String, String> map = new HashMap<>();
    map.put("key", "value");
    assertThat(map).containsKey("key");
}

// ✅ GOOD: Testing behavior
@Test
void test_can_retrieve_stored_value() {
    Map<String, String> map = new HashMap<>();
    map.put("key", "value");
    
    assertThat(map.get("key")).isEqualTo("value");
}
```

### Independent Tests

```java
// ❌ BAD: Tests depend on each other
@Test
void testCreate() {
    entity = createEntity();
    assertThat(entity.getId()).isNotNull();
}

@Test
void testUpdate() {
    entity.setName("new"); // depends on testCreate running first
    entityRepository.save(entity);
}

// ✅ GOOD: Each test is self-contained
@Test
void test_can_create_entity() {
    Entity entity = entityService.create(Entity.builder().name("test").build());
    assertThat(entity.getId()).isNotNull();
}

@Test
void test_can_update_entity() {
    Entity entity = entityService.create(Entity.builder().name("test").build());
    entity.setName("updated");
    Entity updated = entityService.update(entity);
    assertThat(updated.getName()).isEqualTo("updated");
}
```

---

## Mocking Guidelines

For detailed mocking guidance, see [references/mocking.md](references/mocking.md):

- When to use mocks
- When NOT to use mocks
- Where to place mocks (stable API layer)

---

## Resources

- **Mocking Details**: See [references/mocking.md](references/mocking.md)
- **JUnit Best Practices**: See [tools-junit](../tools-junit/SKILL.md)
