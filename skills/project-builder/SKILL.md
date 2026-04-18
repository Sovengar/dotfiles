---
name: project-builder
description: >
  Build automation skill that auto-detects build system (Maven/Gradle/npm), guides user interactively through configuration, and executes builds.
  Trigger: When user asks to build a project, run maven, build with gradle, npm build, or any build-related command.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## Purpose

This skill automates the build process for Java and Node.js projects by:
1. Auto-detecting the build system
2. Discovering project configuration
3. Interactively guiding the user through decisions
4. Executing the build with appropriate parameters

## When to Use

- User says "build", "compila", "mvn", "build with maven", "npm install", "build the project"
- Running CI/CD builds locally
- Needing to adjust JVM parameters, Spring Profiles, or build goals
- Working with multi-module projects

---

## Critical Patterns

### 1. ALWAYS Auto-Detect First

Before anything else, detect the build system by checking files in order:

| Priority | File to Check | Build System | Detection Command |
|----------|--------------|--------------|-------------------|
| 1 | `pom.xml` | Maven | `mvn --version` |
| 2 | `build.gradle` | Gradle | `gradle --version` |
| 3 | `package.json` | Node.js | `node --version` && `npm --version` |
| 4 | `pom.xml` + `package.json` | Mixed (Maven + Node.js) | Run both |

Do NOT assume. Ask the user if detection is ambiguous.

### 2. ALWAYS Scan for Configuration

After detecting build system, scan for project-specific configuration:

```bash
# Find Spring Profiles
glob "**/application*.yml"      # YAML files
glob "**/application*.yaml"    # Alternative YAML
glob "**/application*.properties"

# Extract profile names from filenames
# application-dev.yml   → profile: dev
# application-prod.yml  → profile: prod
```

If MULTIPLE profiles found → ASK user which to use.

### 3. ALWAYS Ask Before Assuming

The skill must NEVER assume user intent. Ask questions when:

- Multiple Spring Profiles exist
- JVM settings need adjustment
- Build goals need selection
- Tests should be skipped/included

### 4. Config File Loading

Check for `.project-builder.yaml` in project root:

```yaml
# Example .project-builder.yaml
build:
  system: auto
  profile: dev
  skipTests: false
  jvm:
    heap: "-Xmx2g"
    gc: "-XX:+UseG1GC"
  goals: ["clean", "package"]

ci:
  java: "mvn clean package -Pprod -DskipTests"
  node: "npm run build"
```

If config exists → use as defaults, but still ask for confirmation.

---

## Execution Flow

### Phase 1: Detection

```
1. Check for pom.xml → Maven?
2. Check for build.gradle → Gradle?
3. Check for package.json → Node.js?
4. Check for .project-builder.yaml → Load config
5. Scan for application*.yml → Find Spring Profiles
```

### Phase 2: Interactive Guidance

Present findings to user with questions:

> **Detected:**
> - Build System: Maven
> - Project: my-app (pom.xml)
> - Spring Profiles: dev, test, prod
> - JVM: No custom config
>
> **Questions:**
> 1. Which Spring Profile? (dev/test/prod) [default: dev]
> 2. Skip tests? (yes/no) [default: no]
> 3. JVM heap size? (512m/1g/2g/custom) [default: 1g]

### Phase 3: Execution

Build the command and execute:

```bash
# Maven example
mvn clean package -Pdev -DskipTests -Xmx1g

# Node.js example  
npm run build
```

### Phase 4: CI Output

After execution, show the CI-ready command:

> **CI Command (copy-paste):**
> ```bash
> mvn clean package -Pprod -DskipTests -Xmx2g -XX:+UseG1GC
> ```

---

## Build System Adapters

### Maven Adapter

```bash
# Detection
test -f pom.xml && echo "Maven detected"

# Version
mvn --version

# Common goals
clean compile
clean package
clean install
clean verify

# With profile
-P{profile}

# Skip tests
-DskipTests

# JVM args (before mvn)
MAVEN_OPTS="-Xmx2g"

# Full example
mvn clean package -Pprod -DskipTests -Dmaven.test.skip=true
```

### Gradle Adapter

```bash
# Detection
test -f build.gradle && echo "Gradle detected"

# Version
gradle --version

# Tasks
compileJava
build
build -x test
jar
assemble

# Profiles (via properties)
-Pprofile=prod

# Tests
-x test

# JVM (in gradle.properties)
org.gradle.jvmargs=-Xmx2g

# Full example
gradle build -x test -Pprofile=prod
```

### Node.js Adapter

```bash
# Detection
test -f package.json && echo "Node.js detected"

# Version
node --version
npm --version

# Scripts available
npm run
npm run build
npm run dev
npm run test

# Install
npm install

# Production
npm ci --omit=dev

# Full example
npm run build
```

---

## Interactive Questions Format

When asking questions, use this format:

```markdown
## Detected Configuration

- **Build System**: {system}
- **Project**: {name}
- **Spring Profiles**: {profiles found}
- **Config File**: {found/not found}

## Questions

| # | Question | Options | Default |
|---|----------|--------|---------|
| 1 | Which Spring Profile? | dev, test, prod | dev |
| 2 | Skip tests? | yes, no | no |
| 3 | JVM heap size? | 512m, 1g, 2g, custom | 1g |
```

Wait for user response before executing.

---

## Commands Reference

| User Input | Action |
|------------|--------|
| "build" | Run interactive build wizard |
| "build --ci" | Use config, no prompts |
| "build --dry-run" | Show command without executing |
| "build --debug" | Verbose output with all detections |
| "mvn clean package" | Run Maven directly (auto-detect) |
| "npm run build" | Run Node.js directly |

---

## Resources

- **Config Schema**: See [assets/config-schema.json](assets/config-schema.json)
- **Maven Adapter**: See [assets/maven-adapter.md](assets/maven-adapter.md)
- **Node.js Adapter**: See [assets/nodejs-adapter.md](assets/nodejs-adapter.md)
- **Examples**: See [references/examples.md](references/examples.md)