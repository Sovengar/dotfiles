# Project Builder Examples

## Example 1: Basic Maven Build

### User Input
> "build the project"

### Detection Phase
```
✓ Found: pom.xml
✓ Project: my-spring-app
✓ Version: 1.0.0-SNAPSHOT
✓ Spring Profiles: application-dev.yml, application-prod.yml
✓ Config: No .project-builder.yaml found
```

### Interactive Questions
> **Detected:** Maven project with 2 Spring Profiles
>
> **Questions:**
> 1. Which Spring Profile? (dev/test/prod) → **dev**
> 2. Skip tests? (yes/no) → **no**
> 3. JVM heap size? (512m/1g/2g/custom) → **1g**

### Execution
```bash
mvn clean package -Pdev -DskipTests
```

### CI Output
> **Ready for CI:**
> ```bash
> mvn clean package -Pprod -DskipTests -Xmx2g -XX:+UseG1GC
> ```

---

## Example 2: Node.js Project

### User Input
> "npm build"

### Detection Phase
```
✓ Found: package.json
✓ Project: my-frontend-app
✓ Package Manager: npm
✓ Scripts: build, dev, test, lint
```

### Interactive Questions
> **Detected:** Node.js project
>
> **Questions:**
> 1. Which script? (build/dev/test) → **build**
> 2. Production build? (yes/no) → **yes**

### Execution
```bash
NODE_ENV=production npm run build
```

---

## Example 3: Mixed Project (Java + Node.js)

### User Input
> "build"

### Detection Phase
```
✓ Found: pom.xml
✓ Found: package.json
✓ Build System: Mixed (Maven + Node.js)
```

### Interactive Questions
> **Detected:** Mixed Java + Node.js project
>
> **Questions:**
> 1. Build Java? (yes/no) → **yes**
> 2. Build Node.js? (yes/no) → **yes**
> 3. Build order: Java first, then Node.js? (yes/no) → **yes**

### Execution
```bash
mvn clean package -Pdev && npm run build
```

---

## Example 4: Using Config File

### .project-builder.yaml (in project root)
```yaml
build:
  system: auto
  profile: dev
  skipTests: false
  jvm:
    heap: "-Xmx2g"
    gc: "G1GC"
  goals:
    - clean
    - package

ci:
  java: "mvn clean package -Pprod -DskipTests -Xmx4g"
```

### User Input
> "build --ci"

### Execution (no questions, uses config)
```bash
mvn clean package -Pdev -DskipTests -Xmx2g
```

---

## Example 5: Gradle Project

### User Input
> "build with gradle"

### Detection Phase
```
✓ Found: build.gradle
✓ Project: my-gradle-app
✓ Gradle: 8.5
```

### Interactive Questions
> **Detected:** Gradle project
>
> **Questions:**
> 1. Build task? (build/jar/assemble) → **build**
> 2. Skip tests? (yes/no) → **no**
> 3. JVM heap size? (512m/1g/2g/custom) → **1g**

### Execution
```bash
./gradlew build
```

---

## Example 6: Dry Run

### User Input
> "build --dry-run"

### Output
```
DRY RUN - Command to execute:

  mvn clean package -Pdev -DskipTests

(Add --debug to see full detection output)
```