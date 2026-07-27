# Node.js Adapter

## Detection

### File Signatures
- `package.json` - NPM package manifest
- `package-lock.json` - NPM lock file
- `pnpm-lock.yaml` - PNPM lock file
- `yarn.lock` - Yarn lock file

### Commands
```bash
# Verify Node.js is detected
test -f package.json && echo "Node.js detected"

# Get versions
node --version
npm --version
pnpm --version
yarn --version
```

## Package Managers

### npm
```bash
npm install          # Install dependencies
npm ci              # Clean install from lockfile
npm run build       # Run build script
npm run dev        # Run dev script
npm run test       # Run test script
```

### pnpm
```bash
pnpm install
pnpm build
pnpm dev
```

### yarn
```bash
yarn install
yarn build
yarn dev
```

## Common Scripts (from package.json)

```bash
npm run build      # Build for production
npm run dev        # Development server
npm run start     # Start production server
npm run test      # Run tests
npm run lint      # Run linter
npm run format   # Format code
```

## Environment Variables

```bash
NODE_ENV=production npm run build
NODE_ENV=development npm run dev
```

## Common Issues

### Missing dependencies
```
ERR_MODULE_NOT_FOUND
```
**Solution:** Run `npm install`

### Node version mismatch
```
node: bad option: --version
```
**Solution:** Check node version with `node --version` and compare with `engines` in package.json

### Out of memory
```
FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed
```
**Solution:** `NODE_OPTIONS="--max-old-space-size=4096" npm run build`

## CI Examples

### GitHub Actions (npm)
```yaml
- name: Install dependencies
  run: npm ci

- name: Build
  run: npm run build
```

### GitHub Actions (pnpm)
```yaml
- name: Setup pnpm
  uses: pnpm/action-setup@v2
  with:
    version: 8

- name: Install dependencies
  run: pnpm install --frozen-lockfile

- name: Build
  run: pnpm build
```

### GitHub Actions (yarn)
```yaml
- name: Install dependencies
  run: yarn install --frozen-lockfile

- name: Build
  run: yarn build
```