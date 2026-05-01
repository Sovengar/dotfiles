---
name: tools-portless
description: >
  Portless setup for local development - replace localhost:3000 with stable 
  https://myapp.localhost URLs. Trigger: portless, localhost without port, 
  https local, proxy development.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- Setting up local development with stable HTTPS URLs
- Working with APIs that require HTTPS (OAuth, webhooks, external services)
- Running multiple services locally with consistent URLs
- Needing stable localhost URLs for development
- When port numbers cause issues or are hard to remember

## What is Portless

Portless is a local development proxy by **Vercel Labs** that replaces:

```
http://localhost:3000  →  https://myapp.localhost
```

Features:
- Auto-generated HTTPS certificates (local CA)
- Stable URLs that persist across restarts
- Git worktree detection (auto prefixes branch name)
- Subdomain support for multiple services
- No port management needed

## Installation

```bash
# Per-project (recommended - version locked per project)
npm install -D portless
# or
pnpm add -D portless
```

Requirements: Node.js 20+, Windows/macOS/Linux

## Basic Configuration

### Step 1: Install portless

```bash
npm install -D portless
```

### Step 2: Update package.json scripts

Change your dev script:

```json
{
  "scripts": {
    "dev": "portless run next dev"
  }
}
```

The project name is auto-detected from:
1. `package.json` name field
2. Git remote URL
3. Current directory name

### Step 3: Run your app

```bash
npm run dev
# → https://myapp.localhost (random port 4000-4999)
```

## New Projects

### Complete workflow

```bash
# 1. Create project
npm create vite@latest my-app -- --template react

# 2. Go to directory
cd my-app

# 3. Install dependencies
npm install

# 4. Install portless
npm install -D portless

# 5. Update package.json dev script
#    Change "dev": "vite" → "dev": "portless run vite"

# 6. Run
npm run dev
# → https://my-app.localhost
```

## Existing Projects

Migrating an existing project:

```bash
# 1. Install portless
npm install -D portless

# 2. Update dev script in package.json
#    Old: "dev": "next dev"
#    New: "dev": "portless run next dev"
```

## Git Worktrees

Portless automatically detects git worktrees and prefixes with branch name:

```
Main branch:    https://myapp.localhost
Feature branch: https://feature-myapp.localhost
```

No extra configuration needed.

## Subdomains

Organize multiple services:

```bash
# Backend API
portless api pnpm start
# → https://api.myapp.localhost

# Frontend
portless web next dev
# → https://web.myapp.localhost

# Docs
portless docs docusaurus start
# → https://docs.myapp.localhost
```

## Commands Reference

### Run an app

```bash
portless run <cmd> [args]     # Auto-detect name
portless run --name myapp <cmd>  # Override name
portless myapp <cmd>           # Explicit name, no inference
```

### List routes

```bash
portless list
```

Shows active routes and assigned ports.

### Get service URL

```bash
portless get <name>
```

Prints URL for wiring services:

```bash
BACKEND_URL=$(portless get backend)
```

### Trust CA (first run only)

```bash
portless trust
```

Adds local CA to system trust store for HTTPS.

### Proxy control

```bash
portless proxy start          # Start proxy manually
portless proxy start --no-tls  # HTTP only
portless proxy start --lan  # Allow LAN access
```

### Clean up

```bash
portless clean             # Stop proxy, remove CA, clean state
portless hosts clean      # Remove /etc/hosts entries
```

## Disable/Enable

### Bypass portless

```bash
PORTLESS=0 npm run dev     # Run directly, no proxy
```

### Disable for specific command

```bash
PORTLESS=0 pnpm dev     # Bypasses portless entirely
```

## Framework Tips

### Next.js

```json
{
  "scripts": {
    "dev": "portless run next dev"
  }
}
```

Works out of the box. Respects `PORT` environment variable.

### Vite

```json
{
  "scripts": {
    "dev": "portless run vite"
  }
}
```

Portless auto-injects `--port` and `--host` flags if needed.

### Express

```json
{
  "scripts": {
    "dev": "portless run node server.js"
  }
}
```

Ensure your server respects the `PORT` environment variable:

```javascript
const PORT = process.env.PORT || 3000;
app.listen(PORT);
```

### Nuxt

```json
{
  "scripts": {
    "dev": "portless run nuxt dev"
  }
}
```

### Astro

```json
{
  "scripts": {
    "dev": "portless run astro dev"
  }
}
```

### Vue

```json
{
  "scripts": {
    "dev": "portless run vite"
  }
}
```

## Troubleshooting

### 508 Loop Detected

Problem: Browser shows "508 Loop Detected"

Solution: Your app is ignoring the `PORT` environment variable. Update to:

```javascript
const PORT = process.env.PORT || 3000;
app.listen(PORT);
```

### HTTPS not working

First run:

```bash
portless trust
```

Re-trust the CA if needed.

### Wrong port assigned

Check your framework respects `PORT`:

```bash
# Verify
echo $PORT

# If empty, framework isn't reading it
```

### Proxy won't start

```bash
# Check if another process uses port 443
netstat -ano | findstr :443

# Or run with --no-tls for HTTP only
portless run --no-tls vite
```

### LAN access not working

For Next.js, add to `next.config.js`:

```javascript
module.exports = {
  allowedDevOrigins: ['myapp.local', '*.myapp.local'],
}
```

### Reset everything

```bash
portless clean
portless trust
npm run dev
```

## Resources

- Official docs: https://portless.sh
- NPM: https://www.npmjs.com/package/portless
- GitHub: https://github.com/vercel-labs/portless