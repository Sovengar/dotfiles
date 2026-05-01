---
description: Build the project (Maven/Gradle/npm). Auto-detects build system, guides interactively.
agent: general
skills: [project-builder, tools-maven]
---

# Build Command

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Arguments: $arguments

TASK:
Use the project-builder skill to build the project:

1. LOAD skill: project-builder
2. DETECT build system
   - pom.xml → Maven
   - build.gradle → Gradle
   - package.json → Node.js
3. SCAN for Spring Profiles (application*.yml)
4. IF multiple profiles → ASK user which to use
5. IF .project-builder.yaml exists → use as defaults
6. IF --ci flag → skip prompts, use config
7. IF --dry-run flag → show command without executing
8. IF --debug flag → verbose output
9. EXECUTE build with user choices
10. OUTPUT CI-ready command for copy-paste

## Arguments

| Argument | Descripción | Ejemplo |
|----------|-------------|---------|
| (none) | Modo interactivo | `build` |
| --ci | Sin prompts, usa config | `build --ci` |
| --dry-run | Solo muestra comando | `build --dry-run` |
| --debug | Verbose output | `build --debug` |
| --profile=prod | Usa profile específico | `build --profile=prod` |
| --skip-tests | Skip tests | `build --skip-tests` |

## Ejemplo de Ejecución

```
> build
✓ Detectado: Maven
✓ Profiles: dev, prod
❓ ¿Qué profile? (dev/prod) → prod
❓ ¿Skip tests? (y/n) → y
▶ Ejecutando: mvn clean package -Pprod -DskipTests

✅ Build completado
📋 CI Command: mvn clean package -Pprod -DskipTests
```

## Detección de Build System

| Archivo | Build System |
|---------|------------|
| pom.xml | Maven |
| build.gradle | Gradle |
| package.json | Node.js |

## Errores Comunes

| Error | Solución |
|-------|----------|
| "mvn not found" | Verificar Maven instalado |
| "node not found" | Verificar Node.js instalado |
| "heap space" | Aumentar JVM heap: MAVEN_OPTS="-Xmx2g" |
| "module not found" | npm install