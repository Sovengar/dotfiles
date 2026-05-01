---
name: tools-selenium
description: >
  Selenium - browser automation for E2E testing.
  Trigger: When writing end-to-end browser tests, UI testing, or testing user workflows.
decisionFramework: "New project → consider Playwright instead (see playwright skill). Existing project → if no mature solution, use Selenium. Otherwise keep existing."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Selenium

> Browser automation for E2E testing.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **New project** | → Consider **Playwright** instead (see Desktop/Skills/playwright) |
| **Existing project without mature solution** | → Use Selenium |
| **Existing project with mature solution** | → Keep existing solution |
| **Doubts** | → Ask user |

---

## When to Use

- End-to-end browser testing
- User workflow testing
- Cross-browser testing

---

## Maven Dependencies

```xml
<dependency>
    <groupId>org.seleniumhq.selenium</groupId>
    <artifactId>selenium-java</artifactId>
    <scope>test</scope>
</dependency>
```

---

## Resources

- **Official**: https://www.selenium.dev/
