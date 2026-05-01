---
name: tools-pitest
description: >
  Pitest - mutation testing for Java.
  Trigger: When verifying test quality, mutation testing, or ensuring tests catch bugs.
decisionFramework: "New project → use Pitest. Existing project → if no mature solution, use Pitest. Otherwise keep existing."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Pitest

> Mutation testing for Java.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Use Pitest |
| **Existing project without mature solution** | → Use Pitest |
| **Existing project with mature solution** | → Keep existing solution, don't introduce Pitest |
| **Doubts** | → Ask user |

---

## When to Use

- Verifying test quality
- Ensuring tests catch bugs
- Measuring test effectiveness

---

## Maven Plugin

```xml
<plugin>
    <groupId>org.pitest</groupId>
    <artifactId>pitest-maven</artifactId>
    <version>1.15.8</version>
</plugin>
```

---

## Run

```bash
./mvnw org.pitest:pitest-maven:mutationCoverage
```

---

## Resources

- **Official**: https://pitest.org/
