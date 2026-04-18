# Maven Adapter

## Detection

### File Signatures
- `pom.xml` - Maven POM file (primary)
- `mvnw` - Maven Wrapper

### Commands
```bash
# Verify Maven is detected
test -f pom.xml && echo "Maven detected"

# Get version
mvn --version

# Get project info
mvn help:effective-pom -f pom.xml
```

## Common Commands

### Build Phases
```bash
mvn clean           # Clean target directory
mvn compile         # Compile source code
mvn test            # Run unit tests
mvn package         # Package as JAR/WAR
mvn install         # Install to local repo
mvn verify          # Run integration tests
```

### With Profiles
```bash
mvn package -Pdev   # Build with dev profile
mvn package -Ptest  # Build with test profile
mvn package -Pprod # Build with prod profile
```

### Skip Tests
```bash
mvn package -DskipTests              # Skip test execution
mvn package -Dmaven.test.skip=true   # Skip test compilation
mvn package -Dtest=SomeTest           # Run specific test
mvn package -Dtest=*Test             # Run tests matching pattern
```

### JVM Options
```bash
# Set heap via MAVEN_OPTS
MAVEN_OPTS="-Xmx2g" mvn package

# Or inline (less common)
mvn package -J-Xmx2g
```

### Multi-module
```bash
mvn clean package    # Builds all modules
mvn package -pl module1 -am  # Build module1 and its dependencies
```

## Configuration

### pom.xml Extraction
```bash
# Get artifactId
grep -A1 '<artifactId>' pom.xml | head -2

# Get version
grep -A1 '<version>' pom.xml | head -2

# Get Spring profiles (from application.yml files)
ls src/main/resources/application*.yml
```

## Common Issues

### Out of Memory
```
Error: Java heap space
```
**Solution:** Increase heap with `MAVEN_OPTS="-Xmx4g" mvn package`

### PermGen/Metaspace
```
Error: PermGen space / Metaspace
```
**Solution:** Add `-XX:MaxMetaspaceSize=512m` to MAVEN_OPTS

### Slow Builds
**Solutions:**
1. Use parallel threads: `mvn -T 4 package`
2. Skip tests: `mvn package -DskipTests`
3. Use offline: `mvn -o package`

## CI Examples

### GitHub Actions
```yaml
- name: Build
  run: mvn clean package -Pprod -DskipTests
  env:
    MAVEN_OPTS: -Xmx2g
```

### GitLab CI
```yaml
build:
  stage: build
  script:
    - mvn clean package -Pprod -DskipTests
  variables:
    MAVEN_OPTS: "-Xmx2g"
```

### Jenkins
```sh
sh 'mvn clean package -Pprod -DskipTests -Xmx2g'
```