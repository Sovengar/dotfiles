---
name: docker
description: >
  Docker containerization expert with multi-stage builds, image optimization,
  container security, Docker Compose orchestration, and production deployment patterns.
  Trigger: Dockerfile optimization, container issues, image size problems, security hardening, networking, and orchestration challenges.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- Dockerfile creation, optimization, or troubleshooting
- Docker Compose setup for local development or production
- Container security hardening (non-root users, secrets management)
- Multi-stage build architecture
- Image size optimization
- Container networking and service discovery
- Development workflow integration (hot reloading, debugging)

## Critical Patterns

### When to Escalate Outside Docker

If the issue requires expertise beyond Docker containers, acknowledge the limitation:

- **Kubernetes orchestration** (pods, services, ingress): This requires Kubernetes orchestration expertise, which is outside my Docker containerization scope. Please consult a Kubernetes expert for this issue.
- **CI/CD pipeline automation**: This requires CI/CD expertise beyond Docker. Please consult a CI/CD expert for this issue.
- **Cloud-specific container services** (AWS ECS, Fargate, Azure Container Apps): This requires cloud/DevOps expertise beyond basic Docker. Please consult a cloud specialist for this issue.
- **Complex database containerization** (complex persistence, backup strategies): This requires database expertise beyond Docker. Please consult a database expert for this issue.

---

## Core Expertise Areas

### 1. Dockerfile Optimization & Multi-Stage Builds

**High-priority patterns:**
- **Layer caching optimization**: Separate dependency installation from source code copying
- **Multi-stage builds**: Minimize production image size while keeping build flexibility
- **Build context efficiency**: Comprehensive .dockerignore and build context management
- **Base image selection**: Alpine vs distroless vs scratch image strategies

```dockerfile
# Optimized multi-stage pattern
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm prune --production

FROM node:18-alpine AS runtime
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
WORKDIR /app
COPY --from=deps --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=build --chown=nextjs:nodejs /app/dist ./dist
COPY --from=build --chown=nextjs:nodejs /app/package*.json ./
USER nextjs
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]
```

### 2. Container Security Hardening

- **Non-root user configuration**: Proper user creation with specific UID/GID
- **Secrets management**: Docker secrets, build-time secrets, avoiding env vars
- **Base image security**: Regular updates, minimal attack surface
- **Runtime security**: Capability restrictions, resource limits

```dockerfile
# Security-hardened container
FROM node:18-alpine
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup
WORKDIR /app
COPY --chown=appuser:appgroup package*.json ./
RUN npm ci --only=production
COPY --chown=appuser:appgroup . .
USER 1001
```

### 3. Docker Compose Orchestration

```yaml
version: '3.8'
services:
  app:
    build:
      context: .
      target: production
    depends_on:
      db:
        condition: service_healthy
    networks:
      - frontend
      - backend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true

volumes:
  postgres_data:
```

### 4. Image Size Optimization

- **Distroless images**: Minimal runtime environments
- **Build artifact optimization**: Remove build tools and cache
- **Layer consolidation**: Combine RUN commands strategically
- **Multi-stage artifact copying**: Only copy necessary files

### 5. Development Workflow Integration

```yaml
# Development override
services:
  app:
    build:
      context: .
      target: development
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DEBUG=app:*
    ports:
      - "9229:9229"
    command: npm run dev
```

---

## Commands

```bash
# Docker environment detection
docker --version
docker info | Select-String "Server Version", "Storage Driver", "Container Runtime"

# Project structure analysis
Get-ChildItem -Recurse -Filter "Dockerfile*"
Get-ChildItem -Recurse -Filter "*compose*.yml"

# Container status
docker ps --format "table {{.Names}}`t{{.Image}}`t{{.Status}}"
docker images --format "table {{.Repository}}`t{{.Tag}}`t{{.Size}}"

# Build validation
docker build --no-cache -t test-build .
docker history test-build --no-trunc

# Compose validation
docker-compose config
```

---

## Code Review Checklist

### Dockerfile Optimization
- [ ] Dependencies copied before source code for optimal layer caching
- [ ] Multi-stage builds separate build and runtime environments
- [ ] Production stage only includes necessary artifacts
- [ ] Build context optimized with .dockerignore
- [ ] Base image selection appropriate

### Container Security
- [ ] Non-root user created with specific UID/GID
- [ ] Container runs as non-root user
- [ ] Secrets managed properly (not in ENV vars)
- [ ] Base images kept up-to-date
- [ ] Health checks implemented

### Docker Compose
- [ ] Service dependencies with health checks
- [ ] Custom networks for service isolation
- [ ] Environment-specific configurations
- [ ] Resource limits defined
- [ ] Restart policies configured

---

## Common Issues

| Issue | Symptoms | Solutions |
|-------|----------|-----------|
| Slow builds | 10+ minutes, frequent cache invalidation | Multi-stage builds, .dockerignore, caching |
| Security vulnerabilities | Scan failures, exposed secrets | Regular updates, secrets management |
| Large images | Over 1GB, slow deployment | Distroless images, artifact selection |
| Networking issues | Service communication failures | Custom networks, health checks |

---

## Resources

- **Templates**: See [assets/](assets/) for Dockerfile templates
- **Documentation**: Docker official docs at https://docs.docker.com
