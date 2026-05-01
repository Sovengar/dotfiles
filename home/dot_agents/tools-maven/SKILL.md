---
name: tools-maven
description: >
  Maven wrapper execution, fallback logic, and settings.xml management.
  Trigger: When executing Maven commands, building Java projects, or troubleshooting Maven issues.
decisionFramework: "mvn + snip → use snip mvn | mvnw exists → use mvnw | mvn exists → use mvn | else create wrapper"
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **mvn + snip available** | → Use `snip mvn` (optimized output) |
| **mvnw exists, no snip** | → Use `mvnw` (Linux: `./mvnw`, Windows: `mvnw.cmd`) |
| **mvn exists, no snip** | → Use `mvn` |
| **No mvn/mvnw** | → Create wrapper: `mvn wrapper:wrapper -Dmaven=3.9.0` |
| **Uses Gradle** | → Keep Gradle, don't introduce Maven |

---

## When to Use

- Executing Maven commands (build, test, run)
- Creating Maven wrapper
- Troubleshooting Maven build failures
- Setting up Maven settings

---

## Critical Patterns

### 1. Use snip + mvn When Available

**snip optimizes Maven output, saving ~97% of tokens:**

| OS | Command |
|----|---------|
| All | `snip mvn test` |
| All | `snip mvn clean install` |
| All | `snip mvn verify` |

```bash
# Optimal - uses snip (saves ~97% tokens)
snip mvn test
snip mvn clean package

# Fallback - if snip not available, use mvnw
mvnw.cmd test
./mvnw test
```

### 2. Create Maven Wrapper If Not Exists

**If wrapper doesn't exist, create it:**

```bash
# Linux/Mac
./mvnw wrapper:wrapper -Dmaven=3.9.0

# Windows
mvnw.cmd wrapper:wrapper -Dmaven=3.9.0

# Or use Maven directly if available (one-time only)
mvn wrapper:wrapper -Dmaven=3.9.0
```

### 3. If Maven Fails → Check settings.xml

**Check if settings.xml exists:**

```bash
# Check project settings
ls -la .mvn/settings.xml

# Check user settings
ls -la ~/.m2/settings.xml
```

**If missing, possible issues:**
- Missing repository credentials
- Proxy configuration missing
- Mirror settings not configured

**Fallback: Use MAVEN_SETTINGS environment variable:**

```bash
MAVEN_SETTINGS=/path/to/settings.xml ./mvnw clean install
```

### 4. Protect Credentials in .gitignore

**IMPORTANT:** Add `.mvn/` to `.gitignore` to protect sensitive credentials in settings.xml

```bash
# Check if .mvn/ is in .gitignore
grep -q ".mvn/" .gitignore && echo "protected" || echo "NOT PROTECTED"
```

**If NOT protected:**

```bash
# Add to .gitignore
echo ".mvn/" >> .gitignore
echo ".mvn/" >> .gitignore 2>/dev/null || echo ".mvn/" >> .gitignore
```

**Warning message to user:**
"WARNING: .mvn/ is not in .gitignore - credentials may be exposed! Add .mvn/ to .gitignore"

---

## Fallback Algorithm

**Follow this decision tree for any Maven command:**

```
1. IF mvn AND snip exist
   → USE: snip mvn test

2. ELSE IF mvnw or mvnw.cmd exists
   → USE IT (Linux: ./mvnw, Windows: mvnw.cmd)

3. ELSE IF mvn exists
   → USE: mvn test

4. ELSE
   → RUN: mvn wrapper:wrapper -Dmaven=3.9.0
   → IF FAILS
      → "Maven wrapper could not be created. Check pom.xml"

5. IF maven execution FAILS
   → CHECK: Does .mvn/settings.xml exist?
      → IF NOT: "Build may fail. Check if settings.xml is in .mvn/ or %USERPROFILE%\.m2\"
   → CHECK: Is .mvn/ in .gitignore?
      → IF NOT: "WARNING: Add .mvn/ to .gitignore to protect credentials"
   → CHECK: MAVEN_SETTINGS environment variable
      → IF set: Use it
   → ELSE: Report actual error with suggestion to check settings
```

---

## Commands

### Linux/Mac (Bash)

```bash
# Check if snip + mvn available (optimal)
which snip && which mvn

# Optimal - uses snip
snip mvn test
snip mvn clean install

# Fallback - use mvnw if snip not available
./mvnw test

# Create maven wrapper
./mvnw wrapper:wrapper -Dmaven=3.9.0

# Check settings locations
ls -la .mvn/settings.xml ~/.m2/settings.xml
```

### Windows (PowerShell)

```powershell
# Check if snip + mvn available (optimal)
Get-Command snip -ErrorAction SilentlyContinue
Get-Command mvn -ErrorAction SilentlyContinue

# Optimal - uses snip
snip mvn test
snip mvn clean install

# Fallback - use mvnw if snip not available
mvnw.cmd test

# Create maven wrapper
mvnw.cmd wrapper:wrapper -Dmaven=3.9.0

# Check settings locations
Get-ChildItem .mvn\settings.xml -ErrorAction SilentlyContinue
Get-ChildItem $env:USERPROFILE\.m2\settings.xml -ErrorAction SilentlyContinue
```

### Cross-Platform Notes

| Task | Linux/Mac | Windows |
|------|-----------|---------|
| Execute wrapper | `./mvnw` | `mvnw.cmd` |
| Settings env var | `MAVEN_SETTINGS=` | `$env:MAVEN_SETTINGS=` |
| Path separator | `/` | `\` |

---

## Common Issues

| Issue | Solution |
|-------|----------|
| `mvn: command not found` | Check if `mvnw` exists → use `snip mvnw.cmd test` |
| `snip: command not found` | Use `mvn` or `mvnw` directly (no token optimization) |
| `settings.xml not found` | Check `.mvn/settings.xml` or `~/.m2/settings.xml` |
| `credentials exposed` | Add `.mvn/` to `.gitignore` |
| `connection timeout` | Check settings.xml for mirrors/proxies |
| `wrapper not found` | Run `mvn wrapper:wrapper -Dmaven=3.9.0` to create |

---

## Resources

- **Maven Wrapper**: https://maven.apache.org/wrapper/
- **Maven Settings**: https://maven.apache.org/settings.html